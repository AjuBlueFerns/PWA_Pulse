{{flutter_js}}
{{flutter_build_config}}

// Use one root-scoped worker for both Flutter's offline cache and Firebase push.
// firebase-messaging-sw.js imports the generated flutter_service_worker.js.
_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
    serviceWorkerUrl:
      'firebase-messaging-sw.js?v=' + {{flutter_service_worker_version}},
  },
});
