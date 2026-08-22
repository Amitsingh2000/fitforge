import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitforge/models/daily_task.dart';
import 'package:fitforge/models/dashboard_today.dart';
import 'package:fitforge/providers/member_flow_providers.dart';
import 'package:fitforge/dashboard/screens/home_dashboard.dart';

void main() {
  testWidgets('Home dashboard shows API task title', (tester) async {
    const fakeToday = DashboardToday(
      date: '2026-08-22',
      streakDays: 3,
      calories: CalorieMetric(consumed: 1000, target: 2500),
      water: WaterMetric(currentLiters: 1, targetLiters: 4),
      steps: StepsMetric(current: 2000, target: 10000),
      tasks: [
        DailyTask(id: 'water_goal', title: 'Drink 4L Water', xp: 50),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayDashboardProvider.overrideWith((ref) async => fakeToday),
        ],
        child: const MaterialApp(home: HomeDashboard()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Drink 4L Water'), findsOneWidget);
    expect(find.text('3 days'), findsOneWidget);
  });
}
