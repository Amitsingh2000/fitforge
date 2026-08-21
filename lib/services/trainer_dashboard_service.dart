import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trainer_client.dart';
import '../models/trainer_dashboard.dart';
import '../models/trainer_notification.dart';
import 'api_client.dart';
import 'api_data.dart';
import 'api_failure.dart';

/// § Trainer dashboard — cross-gym, plus its drill-down endpoints.
class TrainerDashboardService {
  final Dio dio;
  TrainerDashboardService(this.dio);

  /// `GET /trainers/me/dashboard` — cross-gym widget counts.
  Future<TrainerDashboard> getDashboard() => apiCall(() async {
        final res = await dio.get('/trainers/me/dashboard');
        return TrainerDashboard.fromJson(asMap(res.data));
      });

  /// `GET /trainers/me/notifications` — trainer's in-app alert feed.
  Future<List<TrainerNotification>> getNotifications() => apiCall(() async {
        final res = await dio.get('/trainers/me/notifications');
        return extractList(res.data)
            .whereType<Map>()
            .map((e) => TrainerNotification.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });

  /// `POST /trainers/me/notifications/:logId/read` — marks one alert read.
  Future<void> markNotificationRead(String logId) => apiCall(() async {
        await dio.post('/trainers/me/notifications/$logId/read');
      });

  /// `GET /gyms/:gymId/trainer/clients` — self-scoped assigned members, each
  /// entry embedding a `progressSummary`. Server derives "mine"; the client
  /// does no filtering (a 403 means the member isn't yours).
  Future<List<TrainerClient>> getClients(String gymId) => apiCall(() async {
        final res = await dio.get('/gyms/$gymId/trainer/clients');
        return extractList(res.data)
            .whereType<Map>()
            .map((e) => TrainerClient.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });
}

/// Riverpod provider for [TrainerDashboardService].
final trainerDashboardServiceProvider = Provider<TrainerDashboardService>((ref) {
  return TrainerDashboardService(ref.watch(dioProvider));
});