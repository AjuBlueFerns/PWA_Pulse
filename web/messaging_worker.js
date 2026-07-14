(function () {
  const namespace = (window.pulseMessaging = window.pulseMessaging || {});

  function activeWorkerUrl(registration) {
    return (
      registration?.active?.scriptURL ||
      registration?.waiting?.scriptURL ||
      registration?.installing?.scriptURL ||
      ''
    );
  }

  function waitForActiveWorker(registration) {
    if (registration.active) {
      return Promise.resolve(registration.active.scriptURL);
    }

    const worker = registration.installing || registration.waiting;
    if (!worker) {
      return navigator.serviceWorker.ready.then((readyRegistration) => {
        if (!readyRegistration.active) {
          throw new Error('Service worker is ready but not active.');
        }
        return readyRegistration.active.scriptURL;
      });
    }

    return new Promise((resolve, reject) => {
      const timeout = window.setTimeout(() => {
        reject(new Error('Timed out waiting for Firebase service worker.'));
      }, 10000);

      worker.addEventListener('statechange', () => {
        if (worker.state === 'activated') {
          window.clearTimeout(timeout);
          resolve(worker.scriptURL);
        } else if (worker.state === 'redundant') {
          window.clearTimeout(timeout);
          reject(new Error('Firebase service worker became redundant.'));
        }
      });
    });
  }

  namespace.ensureServiceWorkerActive = async function (scriptPath) {
    if (!('serviceWorker' in navigator)) {
      throw new Error('Service workers are not supported by this browser.');
    }

    const baseUrl = new URL(document.baseURI);
    const scopeUrl = new URL('.', baseUrl).href;
    const scriptUrl = new URL(scriptPath, baseUrl).href;
    const registrations = await navigator.serviceWorker.getRegistrations();
    const existing = registrations.find((registration) => {
      const workerUrl = activeWorkerUrl(registration);
      return (
        registration.scope === scopeUrl &&
        workerUrl.includes('firebase-messaging-sw.js')
      );
    });

    const registration =
      existing ||
      (await navigator.serviceWorker.register(scriptUrl, { scope: scopeUrl }));

    const activeUrl = await waitForActiveWorker(registration);
    return activeUrl || scriptUrl;
  };
})();
