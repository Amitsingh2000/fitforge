import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitforge/onboarding/screens/welcome_screen.dart';

void main() {
  testWidgets('Welcome screen shows branding and CTA', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(onGetStarted: () {}),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('FITFORGE'), findsOneWidget);
    expect(find.text('Build Your\nStrongest Version'), findsOneWidget);
    expect(find.text('Start Your Journey'), findsOneWidget);
  });
}
