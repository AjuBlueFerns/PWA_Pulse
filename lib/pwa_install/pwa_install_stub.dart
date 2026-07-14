import 'package:flutter/foundation.dart';

PwaInstallController createPwaInstallController() => PwaInstallController();

class PwaInstallController extends ChangeNotifier {
  bool get canInstall => false;
  bool get isInstalled => false;

  void start() {}
  Future<void> install() async {}
}
