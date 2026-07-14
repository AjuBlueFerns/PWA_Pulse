import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'firebase_options.dart';
import 'pwa_install/pwa_install.dart';
import 'services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PushNotificationService? notifications;
  Object? startupError;
  var versionLabel = '1.0.1+2';

  try {
    final packageInfo = await PackageInfo.fromPlatform();
    versionLabel = packageInfo.buildNumber.isEmpty
        ? packageInfo.version
        : '${packageInfo.version}+${packageInfo.buildNumber}';
  } catch (_) {
    // Keep the fallback version visible if platform metadata is unavailable.
  }

  if (DefaultFirebaseOptions.isConfigured) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      notifications = PushNotificationService();
      await notifications.initialize();
    } catch (error) {
      startupError = error;
    }
  }

  runApp(
    PwaPushApp(
      notifications: notifications,
      startupError: startupError,
      versionLabel: versionLabel,
    ),
  );
}

class PwaPushApp extends StatelessWidget {
  const PwaPushApp({
    super.key,
    this.notifications,
    this.startupError,
    this.versionLabel = '1.0.1+2',
  });

  final PushNotificationService? notifications;
  final Object? startupError;
  final String versionLabel;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0B172A);
    const cyan = Color(0xFF35D0BA);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pulse PWA',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: cyan,
          brightness: Brightness.dark,
          primary: cyan,
          surface: const Color(0xFF132238),
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -1.4,
          ),
          headlineSmall: TextStyle(fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(height: 1.55, color: Color(0xFFC4D1E1)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      home: HomePage(
        notifications: notifications,
        startupError: startupError,
        versionLabel: versionLabel,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.notifications,
    required this.startupError,
    required this.versionLabel,
  });

  final PushNotificationService? notifications;
  final Object? startupError;
  final String versionLabel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PwaInstallController _installer;

  @override
  void initState() {
    super.initState();
    _installer = createPwaInstallController()..start();
  }

  @override
  void dispose() {
    _installer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.notifications;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: -180,
            right: -120,
            child: _Glow(size: 430, color: Color(0x3335D0BA)),
          ),
          const Positioned(
            bottom: -210,
            left: -160,
            child: _Glow(size: 480, color: Color(0x222D73FF)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1060),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        installer: _installer,
                        versionLabel: widget.versionLabel,
                      ),
                      const SizedBox(height: 72),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 780;
                          final intro = _Intro(installer: _installer);
                          final card = _NotificationCard(
                            service: service,
                            startupError: widget.startupError,
                          );
                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(flex: 11, child: intro),
                                const SizedBox(width: 64),
                                Expanded(flex: 9, child: card),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [intro, const SizedBox(height: 42), card],
                          );
                        },
                      ),
                      const SizedBox(height: 76),
                      const _FeatureStrip(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.installer, required this.versionLabel});

  final PwaInstallController installer;
  final String versionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.bolt_rounded, color: Color(0xFF071522)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PULSE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
              ),
            ),
            Text(
              'VERSION $versionLabel',
              key: const ValueKey('app-version'),
              style: const TextStyle(
                color: Color(0xFF8294AA),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const Spacer(),
        ListenableBuilder(
          listenable: installer,
          builder: (context, _) => TextButton.icon(
            onPressed: installer.canInstall ? installer.install : null,
            icon: Icon(
              installer.isInstalled
                  ? Icons.check_circle
                  : Icons.download_rounded,
            ),
            label: Text(installer.isInstalled ? 'Installed' : 'Install app'),
          ),
        ),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.installer});

  final PwaInstallController installer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0x1835D0BA),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: const Color(0x5535D0BA)),
          ),
          child: const Text(
            'PROGRESSIVE WEB APP',
            style: TextStyle(
              color: Color(0xFF67E4D1),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Stay in the loop.\nWherever you are.',
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontSize: 50, height: 1.08),
        ),
        const SizedBox(height: 22),
        Text(
          'Install Pulse on any device and receive timely updates, even when the app is closed.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 30),
        ListenableBuilder(
          listenable: installer,
          builder: (context, _) => FilledButton.icon(
            onPressed: installer.canInstall ? installer.install : null,
            icon: Icon(
              installer.isInstalled
                  ? Icons.check_rounded
                  : Icons.install_desktop_rounded,
            ),
            label: Text(
              installer.isInstalled
                  ? 'App installed'
                  : installer.canInstall
                  ? 'Install Pulse'
                  : 'Use browser menu to install',
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.service, required this.startupError});

  final PushNotificationService? service;
  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xE6132238),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF263B54)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 50,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: service == null
          ? _SetupRequired(startupError: startupError)
          : ListenableBuilder(
              listenable: service!,
              builder: (context, _) {
                final current = service!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _IconTile(
                          icon: Icons.notifications_active_rounded,
                        ),
                        const Spacer(),
                        _StatusPill(enabled: current.isEnabled),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Web push notifications',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      current.statusMessage,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: current.isBusy
                            ? null
                            : current.enableNotifications,
                        icon: current.isBusy
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.notifications_rounded),
                        label: Text(
                          current.isEnabled
                              ? 'Refresh notification token'
                              : 'Enable notifications',
                        ),
                      ),
                    ),
                    if (current.token != null) ...[
                      const SizedBox(height: 22),
                      _TokenField(
                        token: current.token!,
                        onCopy: current.copyToken,
                      ),
                    ],
                    if (current.lastMessage != null) ...[
                      const SizedBox(height: 22),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Latest: ${current.lastMessage}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                );
              },
            ),
    );
  }
}

class _TokenField extends StatelessWidget {
  const _TokenField({required this.token, required this.onCopy});

  final String token;
  final Future<void> Function() onCopy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DEVICE TOKEN',
          style: TextStyle(
            color: Color(0xFF8294AA),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0B172A),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFF2B4059)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SelectableText(
                  token,
                  maxLines: 3,
                  style: const TextStyle(
                    color: Color(0xFFB8C7D9),
                    fontFamily: 'monospace',
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: onCopy,
                tooltip: 'Copy device token',
                icon: const Icon(Icons.copy_rounded, size: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Paste this token into Firebase Console → Messaging → Send test message.',
          style: TextStyle(color: Color(0xFF8294AA), fontSize: 11),
        ),
      ],
    );
  }
}

class _SetupRequired extends StatelessWidget {
  const _SetupRequired({required this.startupError});

  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _IconTile(icon: Icons.settings_rounded),
        const SizedBox(height: 24),
        Text(
          'Connect your Firebase project',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(
          startupError == null
              ? 'Add your Firebase web configuration and VAPID public key to activate push notifications.'
              : 'Firebase could not start. Check the configuration and reload the app.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (startupError != null) ...[
          const SizedBox(height: 14),
          SelectableText(
            startupError.toString(),
            maxLines: 4,
            style: const TextStyle(color: Color(0xFFFFA9A9), fontSize: 12),
          ),
        ],
        const SizedBox(height: 22),
        const Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: Color(0xFF67E4D1),
            ),
            SizedBox(width: 9),
            Expanded(child: Text('Setup instructions are in README.md.')),
          ],
        ),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0x2435D0BA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Theme.of(context).colorScheme.primary),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? const Color(0xFF55D6A8) : const Color(0xFFFFC66D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            enabled ? 'ACTIVE' : 'NOT ENABLED',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureStrip extends StatelessWidget {
  const _FeatureStrip();

  @override
  Widget build(BuildContext context) {
    const features = [
      (
        Icons.offline_bolt_rounded,
        'Works offline',
        'App shell cached by Flutter',
      ),
      (Icons.devices_rounded, 'Install anywhere', 'Desktop, Android and iOS'),
      (
        Icons.mark_email_unread_rounded,
        'Firebase push',
        'Console-to-browser delivery',
      ),
    ];
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: features.map((item) {
        return SizedBox(
          width: 310,
          child: Row(
            children: [
              Icon(item.$1, color: const Color(0xFF67E4D1)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$2,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      item.$3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8294AA),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 130, spreadRadius: 40),
          ],
        ),
      ),
    );
  }
}
