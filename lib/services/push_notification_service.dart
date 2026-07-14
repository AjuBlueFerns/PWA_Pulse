import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../firebase_options.dart';

class PushNotificationService extends ChangeNotifier {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _foregroundMessages;
  StreamSubscription<String>? _tokenRefresh;

  bool isBusy = false;
  bool isEnabled = false;
  bool isSupported = true;
  String? token;
  String? lastMessage;
  String statusMessage =
      'Allow notifications to receive updates from Firebase.';

  Future<void> initialize() async {
    isSupported = await _messaging.isSupported();
    if (!isSupported) {
      statusMessage =
          'This browser does not support Firebase web push notifications.';
      notifyListeners();
      return;
    }

    await _syncPermissionState(loadTokenIfAllowed: true);

    _foregroundMessages = FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      lastMessage = notification == null
          ? message.data.toString()
          : '${notification.title ?? 'Notification'} — ${notification.body ?? ''}';
      statusMessage = 'A new notification arrived while Pulse was open.';
      notifyListeners();
    });

    _tokenRefresh = _messaging.onTokenRefresh.listen((newToken) {
      token = newToken;
      isEnabled = true;
      notifyListeners();
    });
  }

  Future<void> enableNotifications() async {
    isBusy = true;
    statusMessage = 'Checking browser notification permission...';
    notifyListeners();

    try {
      final settings = await _messaging.getNotificationSettings();
      if (_isAllowed(settings)) {
        await _loadToken();
      } else {
        statusMessage = 'Waiting for browser permission...';
        notifyListeners();

        final requested = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        await _applyPermissionSettings(requested, loadTokenIfAllowed: true);
      }
    } catch (error) {
      statusMessage = 'Could not enable notifications: $error';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> _syncPermissionState({required bool loadTokenIfAllowed}) async {
    final settings = await _messaging.getNotificationSettings();
    await _applyPermissionSettings(
      settings,
      loadTokenIfAllowed: loadTokenIfAllowed,
    );
  }

  Future<void> _applyPermissionSettings(
    NotificationSettings settings, {
    required bool loadTokenIfAllowed,
  }) async {
    isEnabled = _isAllowed(settings);

    if (!isEnabled) {
      token = null;
      statusMessage = settings.authorizationStatus == AuthorizationStatus.denied
          ? 'Notifications are blocked. Enable them in your browser site settings, then press Enable notifications again.'
          : 'Press Enable notifications so the browser can ask for permission.';
      return;
    }

    if (loadTokenIfAllowed) {
      await _loadToken();
    } else {
      statusMessage = 'Notifications are allowed. Generate a token to test.';
    }
  }

  bool _isAllowed(NotificationSettings settings) =>
      settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;

  Future<void> _loadToken() async {
    try {
      token = await _messaging.getToken(
        vapidKey: DefaultFirebaseOptions.vapidKey,
        serviceWorkerScriptPath: 'firebase-messaging-sw.js',
      );
      statusMessage = token == null
          ? 'Permission granted, but Firebase did not return a token. Reload the page and try again.'
          : 'Notifications are ready. Copy the token to send a Firebase test message.';
    } catch (error) {
      token = null;
      final errorText = error.toString();
      statusMessage = errorText.contains('Failed to fetch')
          ? 'Could not reach Firebase to generate a device token. Open the deployed HTTPS site in Chrome or Edge and press Refresh notification token.'
          : 'Could not generate a Firebase device token: $error';
    }
  }

  Future<void> copyToken() async {
    final currentToken = token;
    if (currentToken == null) {
      statusMessage = 'No device token is available yet.';
      notifyListeners();
      return;
    }

    try {
      await Clipboard.setData(ClipboardData(text: currentToken));
      statusMessage = 'FCM token copied to the clipboard.';
    } catch (error) {
      statusMessage = 'Could not copy the FCM token: $error';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _foregroundMessages?.cancel();
    _tokenRefresh?.cancel();
    super.dispose();
  }
}
