(function () {
  const namespace = (window.pulseNotifications = window.pulseNotifications || {});

  namespace.show = async function (title, body, link) {
    if (!('Notification' in window) || Notification.permission !== 'granted') {
      return false;
    }

    try {
      const notification = new Notification(title || 'Pulse update', {
        body: body || 'You have a new update.',
        icon: 'icons/Icon-192.png',
        badge: 'icons/Icon-192.png',
        data: { link: link || document.baseURI },
      });

      notification.onclick = function () {
        window.focus();
        const target = notification.data?.link;
        if (target) {
          window.location.href = new URL(target, document.baseURI).href;
        }
        notification.close();
      };

      return true;
    } catch (error) {
      console.warn('Failed to show foreground notification:', error);
      return false;
    }
  };
})();
