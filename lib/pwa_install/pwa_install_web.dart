import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';

@JS('pulsePwa.canInstall')
external bool _canInstall();

@JS('pulsePwa.isInstalled')
external bool _isInstalled();

@JS('pulsePwa.install')
external JSPromise<JSString> _install();

PwaInstallController createPwaInstallController() => PwaInstallController();

class PwaInstallController extends ChangeNotifier {
  Timer? _timer;
  bool _canInstallValue = false;
  bool _isInstalledValue = false;

  bool get canInstall => _canInstallValue;
  bool get isInstalled => _isInstalledValue;

  void start() {
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _refresh());
  }

  void _refresh() {
    final nextCanInstall = _canInstall();
    final nextInstalled = _isInstalled();
    if (nextCanInstall == _canInstallValue &&
        nextInstalled == _isInstalledValue) {
      return;
    }
    _canInstallValue = nextCanInstall;
    _isInstalledValue = nextInstalled;
    notifyListeners();
  }

  Future<void> install() async {
    await _install().toDart;
    _refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
