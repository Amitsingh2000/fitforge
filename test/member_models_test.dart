import 'package:flutter_test/flutter_test.dart';
import 'package:fitforge/models/dashboard_today.dart';
import 'package:fitforge/models/diet_today.dart';
import 'package:fitforge/models/leaderboard_entry.dart';
import 'package:fitforge/models/rewards_overview.dart';

void main() {
  group('DashboardToday', () {
    test('fromJson parses today aggregate', () {
      final today = DashboardToday.fromJson({
        'date': '2026-08-22',
        'streakDays': 5,
        'calories': {'consumed': 1800, 'target': 2500},
        'water': {'currentLiters': 2.5, 'targetLiters': 4},
        'steps': {'current': 5000, 'target': 10000},
        'tasks': [
          {'id': 'water_goal', 'title': 'Drink 4L Water', 'completed': false, 'xp': 50},
        ],
        'unreadNotifications': 2,
      });

      expect(today.date, '2026-08-22');
      expect(today.streakDays, 5);
      expect(today.calories.consumed, 1800);
      expect(today.water.currentLiters, 2.5);
      expect(today.tasks.single.id, 'water_goal');
      expect(today.unreadNotifications, 2);
    });
  });

  group('DietToday', () {
    test('fromJson parses meals and macros', () {
      final diet = DietToday.fromJson({
        'date': '2026-08-22',
        'planId': 'plan-1',
        'targets': {'calories': 2500, 'protein': 140, 'carbs': 220, 'fat': 70},
        'consumed': {'calories': 900, 'protein': 60, 'carbs': 80, 'fat': 25},
        'meals': [
          {
            'id': 'meal-1',
            'name': 'Breakfast',
            'calories': 450,
            'protein': 30,
            'carbs': 40,
            'fat': 12,
            'checked': true,
            'items': [],
          },
        ],
      });

      expect(diet.planId, 'plan-1');
      expect(diet.meals.single.name, 'Breakfast');
      expect(diet.meals.single.checked, isTrue);
      expect(diet.consumed.calories, 900);
    });
  });

  group('LeaderboardResponse', () {
    test('fromJson parses ranks', () {
      final lb = LeaderboardResponse.fromJson({
        'myRank': {'rank': 4, 'userId': 'u1', 'name': 'You', 'score': 4200},
        'leaderboard': [
          {'rank': 1, 'userId': 'u2', 'name': 'Alex', 'score': 5000, 'rankChange': 0},
        ],
      });

      expect(lb.myRank?.rank, 4);
      expect(lb.leaderboard.single.name, 'Alex');
    });
  });

  group('RewardsOverview', () {
    test('fromJson parses gamification overview', () {
      final r = RewardsOverview.fromJson({
        'level': 3,
        'levelTitle': 'Dedicated',
        'currentXp': 250,
        'nextLevelXp': 1000,
        'totalXp': 2250,
        'totalPoints': 120,
        'streakDays': 7,
        'dailyCheckInBoard': [],
        'badges': [],
      });

      expect(r.level, 3);
      expect(r.streakDays, 7);
      expect(r.totalPoints, 120);
    });
  });
}
