import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Replace the values below with the Web app configuration from:
/// Firebase Console > Project settings > General > Your apps > Web app.
class DefaultFirebaseOptions {
  static const String vapidKey =
      'BCvCJv9V6q9tb5rm3V64_7xKTE5PdndjKBkFwFSz3t7a7ckgTAYdXp8YrIjrmqAwiyLe_hzPwg5IG67bWD8xJ50';

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAXXuhr0Lcp3bBibQU56OMlhri6dG3Fd6c',
    appId: '1:590666906347:web:a73c22cf68e81d09495cae',
    messagingSenderId: '590666906347',
    projectId: 'my-second-project-14356',
    authDomain: 'my-second-project-14356.firebaseapp.com',
    databaseURL: 'https://my-second-project-14356.firebaseio.com',
    storageBucket: 'my-second-project-14356.appspot.com',
    measurementId: 'G-9SEF32L6RK',
  );
  static bool get isConfigured =>
      web.apiKey.isNotEmpty &&
      web.appId.isNotEmpty &&
      web.messagingSenderId.isNotEmpty &&
      web.projectId.isNotEmpty &&
      vapidKey.isNotEmpty &&
      !web.apiKey.contains('YOUR_') &&
      !web.appId.contains('YOUR_') &&
      !vapidKey.contains('YOUR_');

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError('This starter is configured for Flutter Web only.');
  }
}
