(() => {
  let deferredPrompt = null;

  const standalone = () =>
    window.matchMedia('(display-mode: standalone)').matches ||
    window.navigator.standalone === true;

  window.addEventListener('beforeinstallprompt', (event) => {
    event.preventDefault();
    deferredPrompt = event;
  });

  window.addEventListener('appinstalled', () => {
    deferredPrompt = null;
  });

  window.pulsePwa = {
    canInstall: () => deferredPrompt !== null && !standalone(),
    isInstalled: standalone,
    install: async () => {
      if (!deferredPrompt) return 'unavailable';
      deferredPrompt.prompt();
      const choice = await deferredPrompt.userChoice;
      deferredPrompt = null;
      return choice.outcome;
    },
  };
})();
