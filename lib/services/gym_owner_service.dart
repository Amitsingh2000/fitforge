import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gym_dashboard_data.dart';
import '../models/gym_member.dart';
import '../models/gym_trainer.dart';
import 'api_client.dart';

/// Service layer for Gym Owner / Manager / Front Desk API calls.
///
/// Every method takes plain Dart params (gymId, membershipId, etc.),
/// calls the backend via Dio, and returns clean Dart models.
class GymOwnerService {
  final Dio dio;
  GymOwnerService(this.dio);

  // ────────────────────────────────────────────────────────────────────────────
  // GYM MANAGEMENT
  // ────────────────────────────────────────────────────────────────────────────

  /// Create a new gym profile (for fresh gym owner registration).
  Future<Map<String, dynamic>> createGym({
    required String name,
    required String address,
    String? phone,
    String? upiId,
  }) async {
    final res = await dio.post('/gyms', data: {
      'name': name,
      'address': address,
      if (phone != null) 'phone': phone,
      if (upiId != null) 'upiId': upiId,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // DASHBOARD
  // ────────────────────────────────────────────────────────────────────────────

  /// Get today's stats: check-ins, collections, new joins, expiring soon, dues.
  Future<GymDashboardToday> getTodayDashboard(String gymId) async {
    try {
      final res = await dio.get('/gyms/$gymId/dashboard/today');
      if (res.data == null) return const GymDashboardToday();
      return GymDashboardToday.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (_) {
      return const GymDashboardToday();
    }
  }

  /// Get monthly stats: total revenue, active members, renewals, churn.
  Future<GymDashboardMonthly> getMonthlyDashboard(String gymId) async {
    try {
      final res = await dio.get('/gyms/$gymId/dashboard/monthly');
      if (res.data == null) return const GymDashboardMonthly();
      return GymDashboardMonthly.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (_) {
      return const GymDashboardMonthly();
    }
  }

  /// Get trainer roster with active client counts.
  Future<List<GymTrainer>> getTrainersRoster(String gymId) async {
    try {
      final res = await dio.get('/gyms/$gymId/dashboard/trainers');
      if (res.data is List) {
        return (res.data as List)
            .map((e) => GymTrainer.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (_) {
      // Fallback to members list filtered by TRAINER
      return getTrainersFromMembers(gymId);
    }
  }

  /// Fallback: fetch members with role=TRAINER.
  Future<List<GymTrainer>> getTrainersFromMembers(String gymId) async {
    try {
      final res = await dio.get('/gyms/$gymId/members', queryParameters: {'role': 'TRAINER'});
      final list = _extractList(res.data);
      return list
          .map((e) => GymTrainer.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // MEMBERS
  // ────────────────────────────────────────────────────────────────────────────

  /// List members for a gym with optional search, status, and role filter.
  Future<List<GymMember>> getMembers(
    String gymId, {
    String? role,
    String? search,
    String? status,
  }) async {
    final query = <String, dynamic>{};
    if (role != null) query['role'] = role;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (status != null) query['status'] = status;

    final res = await dio.get('/gyms/$gymId/members', queryParameters: query);
    final list = _extractList(res.data);
    return list
        .map((e) => GymMember.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Get 360° detail for a single gym member.
  Future<GymMember> getMemberDetail(String gymId, String membershipId) async {
    final res = await dio.get('/gyms/$gymId/members/$membershipId');
    return GymMember.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Update a member's status (ACTIVE, EXPIRED, FROZEN, etc.) or profile.
  Future<void> updateMemberStatus(
    String gymId,
    String membershipId, {
    required String status,
  }) async {
    await dio.patch('/gyms/$gymId/members/$membershipId', data: {
      'status': status,
    });
  }

  /// Assign a trainer to a gym member.
  Future<void> assignTrainer({
    required String gymId,
    required String membershipId,
    required String trainerId,
  }) async {
    await dio.post('/gyms/$gymId/members/$membershipId/assign-trainer', data: {
      'trainerId': trainerId,
    });
  }

  static List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['items'] is List) return data['items'] as List;
    if (data is Map && data['members'] is List) return data['members'] as List;
    return [];
  }
}

/// Riverpod provider for [GymOwnerService].
final gymOwnerServiceProvider = Provider<GymOwnerService>((ref) {
  return GymOwnerService(ref.read(dioProvider));
});
