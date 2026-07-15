import 'dart:js_interop';

@JS('pulseNotifications.show')
external JSPromise<JSBoolean> _showNotification(
  JSString title,
  JSString body,
  JSString? link,
);

Future<bool> showBrowserNotification({
  required String title,
  required String body,
  String? link,
}) async =>
    (await _showNotification(title.toJS, body.toJS, link?.toJS).toDart).toDart;
