import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Replace the values below with the Web app configuration from:
/// Firebase Console > Project settings > General > Your apps > Web app.
class DefaultFirebaseOptions {
  static const String vapidKey = 'YOUR_PUBLIC_VAPID_KEY';

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.firebasestorage.app',
    measurementId: 'YOUR_MEASUREMENT_ID',
  );

  static bool get isConfigured =>
      web.apiKey != 'YOUR_API_KEY' &&
      web.appId != 'YOUR_APP_ID' &&
      vapidKey != 'YOUR_PUBLIC_VAPID_KEY';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError('This starter is configured for Flutter Web only.');
  }
}
