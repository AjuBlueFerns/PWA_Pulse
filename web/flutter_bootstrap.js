{{flutter_js}}
{{flutter_build_config}}

// Use one root-scoped worker for Firebase push and PWA install support.
// Do not import flutter_service_worker.js here; current Flutter web builds may
// generate an unregister stub, which breaks Firebase token subscription.
_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
    serviceWorkerUrl:
      'firebase-messaging-sw.js?v=' + {{flutter_service_worker_version}},
    timeoutMillis: 10000,
  },
});
