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
  String? token;
  String? lastMessage;
  String statusMessage =
      'Allow notifications to receive updates from Firebase.';

  Future<void> initialize() async {
    final settings = await _messaging.getNotificationSettings();
    isEnabled =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

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

    if (isEnabled) await _loadToken();
  }

  Future<void> enableNotifications() async {
    isBusy = true;
    statusMessage = 'Waiting for browser permission…';
    notifyListeners();

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      isEnabled =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!isEnabled) {
        statusMessage =
            settings.authorizationStatus == AuthorizationStatus.denied
            ? 'Notifications are blocked. Enable them in your browser site settings.'
            : 'Notification permission was not granted.';
      } else {
        await _loadToken();
      }
    } catch (error) {
      statusMessage = 'Could not enable notifications: $error';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> _loadToken() async {
    token = await _messaging.getToken(
      vapidKey: DefaultFirebaseOptions.vapidKey,
    );
    statusMessage = token == null
        ? 'Permission granted, but Firebase did not return a token.'
        : 'Notifications are ready. Copy the token to send a Firebase test message.';
  }

  Future<void> copyToken() async {
    final currentToken = token;
    if (currentToken == null) return;
    await Clipboard.setData(ClipboardData(text: currentToken));
    statusMessage = 'FCM token copied to the clipboard.';
    notifyListeners();
  }

  @override
  void dispose() {
    _foregroundMessages?.cancel();
    _tokenRefresh?.cancel();
    super.dispose();
  }
}
