import 'package:flutter_test/flutter_test.dart';
import 'package:fitforge/main.dart';

void main() {
  testWidgets('FitForge app launches and shows welcome screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FitForgeApp());

    // Verify the welcome screen is displayed
    expect(find.text('FITFORGE'), findsOneWidget);
    expect(find.text('Build Your\nStrongest Version'), findsOneWidget);
    expect(find.text('Start Your Journey'), findsOneWidget);
  });
}
