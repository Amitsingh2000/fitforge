import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitforge/models/member_entitlements.dart';
import 'package:fitforge/providers/entitlements_provider.dart';
import 'package:fitforge/dashboard/widgets/premium_gate.dart';

void main() {
  testWidgets('PremiumGate shows child when entitled', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          entitlementsProvider.overrideWith(
            (ref) async => const MemberEntitlements(
              tier: 'PREMIUM',
              aiPlans: true,
              trainerChat: true,
              nutritionAnalysis: true,
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: PremiumGate(
              feature: _aiPlans,
              featureLabel: 'AI plans',
              child: Text('Unlocked feature'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Unlocked feature'), findsOneWidget);
    expect(find.textContaining('premium feature'), findsNothing);
  });

  testWidgets('PremiumGate shows lock when not entitled', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          entitlementsProvider.overrideWith(
            (ref) async => MemberEntitlements.free(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: PremiumGate(
              feature: _aiPlans,
              featureLabel: 'AI plans',
              child: Text('Hidden feature'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.textContaining('AI plans is a premium feature'), findsOneWidget);
  });
}

bool _aiPlans(MemberEntitlements e) => e.aiPlans;
