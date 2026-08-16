import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trainer_analytics.dart';
import 'api_client.dart';
import 'api_data.dart';
import 'api_failure.dart';

/// § Gym-scoped trainer analytics.
class TrainerAnalyticsService {
  final Dio dio;
  TrainerAnalyticsService(this.dio);

  /// `GET /gyms/:gymId/trainer/analytics`.
  Future<TrainerAnalytics> getAnalytics(String gymId) => apiCall(() async {
        final res = await dio.get('/gyms/$gymId/trainer/analytics');
        return TrainerAnalytics.fromJson(asMap(res.data));
      });
}

/// Riverpod provider for [TrainerAnalyticsService].
final trainerAnalyticsServiceProvider =
    Provider<TrainerAnalyticsService>((ref) {
  return TrainerAnalyticsService(ref.watch(dioProvider));
});