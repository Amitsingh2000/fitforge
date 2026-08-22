import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_entry.dart';
import '../models/rewards_overview.dart';
import 'api_client.dart';
import 'api_data.dart';

/// Gamification API — rewards, leaderboards, challenges, store.
class GamificationService {
  final Dio dio;
  GamificationService(this.dio);

  Future<RewardsOverview> getRewardsOverview() async {
    final res = await dio.get('/members/me/rewards/overview');
    return RewardsOverview.fromJson(asMap(res.data));
  }

  Future<DailyCheckInResult> dailyCheckIn() async {
    final res = await dio.post('/members/me/rewards/check-in');
    return DailyCheckInResult.fromJson(asMap(res.data));
  }

  Future<List<RewardStoreItem>> listStoreItems() async {
    final res = await dio.get('/rewards/store');
    return extractList(res.data)
        .whereType<Map>()
        .map((e) => RewardStoreItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<RewardRedemptionResult> redeemStoreItem(String rewardId) async {
    final res = await dio.post('/rewards/store/$rewardId/redeem');
    return RewardRedemptionResult.fromJson(asMap(res.data));
  }

  Future<LeaderboardResponse> getLeaderboard({
    required String type,
    required String scope,
    String? gymId,
    String filter = 'ALL_TIME',
    int limit = 50,
  }) async {
    final res = await dio.get('/leaderboards', queryParameters: {
      'type': type,
      'scope': scope,
      if (gymId != null) 'gymId': gymId,
      'filter': filter,
      'limit': limit,
    });
    return LeaderboardResponse.fromJson(asMap(res.data));
  }

  Future<List<Challenge>> listChallenges({String? gymId}) async {
    final res = await dio.get(
      '/challenges',
      queryParameters: {if (gymId != null) 'gymId': gymId},
    );
    return extractList(res.data)
        .whereType<Map>()
        .map((e) => Challenge.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> joinChallenge(String challengeId) async {
    final res = await dio.post('/challenges/$challengeId/join');
    return asMap(res.data);
  }

  Future<Challenge> getChallenge(String challengeId) async {
    final res = await dio.get('/challenges/$challengeId');
    return Challenge.fromJson(asMap(res.data));
  }
}

final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService(ref.watch(dioProvider));
});
