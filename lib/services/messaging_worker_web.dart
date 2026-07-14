import 'dart:js_interop';

@JS('pulseMessaging.ensureServiceWorkerActive')
external JSPromise<JSString> _ensureServiceWorkerActive(JSString scriptPath);

Future<String> ensureMessagingServiceWorkerActive() async =>
    (await _ensureServiceWorkerActive(
      'firebase-messaging-sw.js'.toJS,
    ).toDart).toDart;
