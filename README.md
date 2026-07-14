# Pulse — Flutter PWA + Firebase web push

Pulse is a responsive Flutter website that can be installed as a Progressive
Web App and can receive Firebase Cloud Messaging (FCM) notifications while in
the foreground, background, or closed.

## 1. Connect your Firebase project

1. Open the [Firebase console](https://console.firebase.google.com/), create or
   select a project, then add a **Web app** from **Project settings > General**.
2. Copy the values from the Firebase web configuration into both:
   - `lib/firebase_options.dart`
   - `web/firebase-messaging-sw.js`
3. Open **Project settings > Cloud Messaging > Web configuration > Web Push
   certificates**, generate a key pair, and copy the **public key** into
   `DefaultFirebaseOptions.vapidKey` in `lib/firebase_options.dart`.

The Firebase web configuration and public VAPID key are browser client values;
they are not server secrets. Never place a service-account private key in this
app.

## 2. Run locally

```sh
flutter pub get
flutter run -d chrome
```

`localhost` is accepted as a secure context for development. On a real domain,
web push and service workers require HTTPS.

Click **Enable notifications** in the app and accept the browser prompt. Copy
the displayed FCM token when you want to target this browser directly.

## 3. Send a test notification from Firebase

1. In Firebase, open **Messaging** and create a notification campaign.
2. Enter a notification title and body.
3. Choose **Send test message**.
4. Paste the FCM token copied from Pulse and send the test.

For the clearest background test, install/open the app once, enable
notifications, and then put the app in the background before sending.

## 4. Build and deploy as a PWA

```sh
flutter build web --release
firebase login
firebase use --add
firebase deploy --only hosting
```

`firebase.json` is already configured to publish `build/web` and route browser
URLs back to Flutter. You can host `build/web` on another HTTPS static host if
you prefer.

### Browser notes

- Chrome and Edge show the in-app install prompt when install criteria are met.
- Safari uses **Share > Add to Home Screen** instead of the custom install
  prompt.
- On iPhone/iPad, web push is available to Home Screen web apps; enable
  notifications after installing the PWA.
- If permission was denied, re-enable notifications in the browser's site
  settings before trying again.

## Project structure

- `lib/services/push_notification_service.dart` — permission, token, foreground
  message, and token-refresh handling.
- `web/firebase-messaging-sw.js` — background/closed-state FCM handling.
- `web/flutter_bootstrap.js` — registers the combined Flutter cache + Firebase
  worker, avoiding competing root service-worker registrations.
- `web/manifest.json` — PWA identity, theme, display mode, and icons.
- `web/pwa_install.js` — captures the browser install event for Flutter.
