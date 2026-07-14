// Flutter generates this file during `flutter build web`. Importing it makes
// this one worker handle both the offline app shell and Firebase background push.
importScripts('flutter_service_worker.js');

// Keep these values in sync with lib/firebase_options.dart.
// Firebase web configuration is public client configuration, not a server secret.
const firebaseConfig = {
  apiKey: 'AIzaSyAXXuhr0Lcp3bBibQU56OMlhri6dG3Fd6c',
  appId: '1:590666906347:web:a73c22cf68e81d09495cae',
  messagingSenderId: '590666906347',
  projectId: 'my-second-project-14356',
  authDomain: 'my-second-project-14356.firebaseapp.com',
  storageBucket: 'my-second-project-14356.appspot.com',
  measurementId: 'G-9SEF32L6RK',
};

// This version matches the Firebase JS SDK supported by firebase_core_web 3.9.1.
importScripts('https://www.gstatic.com/firebasejs/12.15.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/12.15.0/firebase-messaging-compat.js');

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  // Firebase automatically displays console notification messages. This path
  // provides a notification for data-only messages as well.
  if (payload.notification) return;

  const title = payload.data?.title || 'Pulse update';
  const options = {
    body: payload.data?.body || 'You have a new update.',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: { link: payload.data?.link || '/' },
  };
  self.registration.showNotification(title, options);
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const target = event.notification.data?.link || '/';
  event.waitUntil(clients.openWindow(target));
});
