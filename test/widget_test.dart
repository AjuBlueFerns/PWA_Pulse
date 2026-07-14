import 'package:flutter_test/flutter_test.dart';
import 'package:pwa_push_starter/main.dart';

void main() {
  testWidgets('shows the PWA landing page and Firebase setup state', (
    tester,
  ) async {
    await tester.pumpWidget(const PwaPushApp());

    expect(find.text('PULSE'), findsOneWidget);
    expect(find.text('VERSION 1.0.1+2'), findsOneWidget);
    expect(find.text('BUILD 1.0.1+2'), findsOneWidget);
    expect(find.text('DEVICE TOKEN'), findsOneWidget);
    expect(find.text('Stay in the loop.\nWherever you are.'), findsOneWidget);
    expect(find.text('Connect your Firebase project'), findsOneWidget);
  });
}
