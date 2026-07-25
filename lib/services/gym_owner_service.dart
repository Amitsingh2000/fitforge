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
  /// Matches backend `CreateGymDto` exactly — sending unknown fields (e.g.
  /// `upiId`, which is only settable via `updateGym` after creation, or the
  /// old `address` name instead of `addressLine`) 400s under the backend's
  /// strict unknown-property validation.
  Future<Map<String, dynamic>> createGym({
    required String name,
    String? phone,
    String? email,
    String? addressLine,
    String? city,
    String? state,
    String? pincode,
    String? referralCode,
  }) async {
    final res = await dio.post('/gyms', data: {
      'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      if (addressLine != null && addressLine.isNotEmpty) 'addressLine': addressLine,
      if (city != null && city.isNotEmpty) 'city': city,
      if (state != null && state.isNotEmpty) 'state': state,
      if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
      if (referralCode != null && referralCode.isNotEmpty) 'referralCode': referralCode,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Update gym profile — name/contact/address/logo/UPI payout details.
  Future<Map<String, dynamic>> updateGym(
    String gymId, {
    String? name,
    String? phone,
    String? email,
    String? addressLine,
    String? city,
    String? state,
    String? pincode,
    String? logoUrl,
    String? upiId,
    String? upiQrCodeUrl,
  }) async {
    final res = await dio.patch('/gyms/$gymId', data: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (addressLine != null) 'addressLine': addressLine,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (upiId != null) 'upiId': upiId,
      if (upiQrCodeUrl != null) 'upiQrCodeUrl': upiQrCodeUrl,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Get a gym's full profile (owner/staff view).
  Future<Map<String, dynamic>> getGym(String gymId) async {
    final res = await dio.get('/gyms/$gymId');
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

  /// List members for a gym, optionally filtered by role.
  /// Backend `ListMembersQueryDto` only whitelists `page`, `limit`, `role` —
  /// any other query param (the previous `search`/`status`) 400s under the
  /// backend's strict unknown-property validation. Text search is done
  /// client-side over the fetched page (see [GymMember] filtering in the UI).
  Future<List<GymMember>> getMembers(
    String gymId, {
    String? role,
    int page = 1,
    int limit = 100,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (role != null) query['role'] = role;

    final res = await dio.get('/gyms/$gymId/members', queryParameters: query);
    final list = _extractList(res.data);
    return list
        .map((e) => GymMember.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Get 360° detail for a single gym member (profile + recent enrollments +
  /// recent attendance).
  Future<GymMember> getMemberDetail(String gymId, String membershipId) async {
    final res = await dio.get('/gyms/$gymId/members/$membershipId');
    return GymMember.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Add a single walk-in member.
  Future<GymMember> addMember(
    String gymId, {
    required String firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    final res = await dio.post('/gyms/$gymId/members', data: {
      'firstName': firstName,
      if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    return GymMember.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Staff edits to a member's record: photo/ID-proof/emergency-contact.
  /// (Distinct from the member's own goal-intake profile.)
  Future<void> updateMemberRecord(
    String gymId,
    String membershipId, {
    String? photoUrl,
    String? idProofType,
    String? idProofNumber,
    String? idProofUrl,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    await dio.patch('/gyms/$gymId/members/$membershipId/profile', data: {
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (idProofType != null) 'idProofType': idProofType,
      if (idProofNumber != null) 'idProofNumber': idProofNumber,
      if (idProofUrl != null) 'idProofUrl': idProofUrl,
      if (emergencyContactName != null) 'emergencyContactName': emergencyContactName,
      if (emergencyContactPhone != null) 'emergencyContactPhone': emergencyContactPhone,
    });
  }

  /// Private staff-only notes about a member.
  Future<void> updateMemberNotes(
    String gymId,
    String membershipId, {
    required String staffNotes,
  }) async {
    await dio.patch('/gyms/$gymId/members/$membershipId/notes', data: {
      'staffNotes': staffNotes,
    });
  }

  /// Configure a trainer's own shift schedule / commission rate.
  /// (Not "assign this trainer to that member" — there's no such endpoint in
  /// this backend release; PT-session assignment is a later section.)
  Future<void> updateTrainerConfig({
    required String gymId,
    required String membershipId,
    String? shiftSchedule,
    double? commissionPercent,
  }) async {
    await dio.patch('/gyms/$gymId/members/$membershipId/trainer-config', data: {
      if (shiftSchedule != null) 'shiftSchedule': shiftSchedule,
      if (commissionPercent != null) 'commissionPercent': commissionPercent,
    });
  }

  /// Remove a member/staff person from the gym.
  Future<void> removeMember(String gymId, String membershipId) async {
    await dio.delete('/gyms/$gymId/members/$membershipId');
  }

  /// Bulk-import members from parsed CSV/Excel rows. `dryRun: true` previews
  /// without writing; returns the per-row report either way.
  Future<Map<String, dynamic>> importMembers(
    String gymId, {
    required List<Map<String, dynamic>> rows,
    bool dryRun = false,
  }) async {
    final res = await dio.post('/gyms/$gymId/members/import', data: {
      'dryRun': dryRun,
      'rows': rows,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // INVITES
  // ────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getInvites(String gymId) async {
    final res = await dio.get('/gyms/$gymId/invites');
    final list = _extractList(res.data);
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> createInvite(
    String gymId, {
    required String role,
    int? maxUses,
    String? expiresAt,
  }) async {
    final res = await dio.post('/gyms/$gymId/invites', data: {
      'role': role,
      if (maxUses != null) 'maxUses': maxUses,
      if (expiresAt != null) 'expiresAt': expiresAt,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> revokeInvite(String gymId, String inviteId) async {
    await dio.post('/gyms/$gymId/invites/$inviteId/revoke');
  }

  // ────────────────────────────────────────────────────────────────────────────
  // MEMBERSHIP PLANS
  // ────────────────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getPlans(
    String gymId, {
    bool includeInactive = false,
  }) async {
    final res = await dio.get('/gyms/$gymId/plans', queryParameters: {
      if (includeInactive) 'includeInactive': 'true',
    });
    final list = _extractList(res.data);
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> createPlan(
    String gymId, {
    required String name,
    String? description,
    required String type,
    int? durationDays,
    int? sessionCount,
    required double priceInr,
  }) async {
    final res = await dio.post('/gyms/$gymId/plans', data: {
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
      'type': type,
      if (durationDays != null) 'durationDays': durationDays,
      if (sessionCount != null) 'sessionCount': sessionCount,
      'priceInr': priceInr,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> updatePlan(
    String gymId,
    String planId, {
    String? name,
    String? description,
    double? priceInr,
  }) async {
    final res = await dio.patch('/gyms/$gymId/plans/$planId', data: {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (priceInr != null) 'priceInr': priceInr,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Retire (soft-deactivate) a plan — history on past enrollments survives.
  Future<void> retirePlan(String gymId, String planId) async {
    await dio.delete('/gyms/$gymId/plans/$planId');
  }

  // ────────────────────────────────────────────────────────────────────────────
  // QR CHECK-IN TOKEN
  // ────────────────────────────────────────────────────────────────────────────

  /// Rotate the gym's printed check-in QR secret, invalidating the old poster.
  /// Returns the new token/QR payload.
  Future<Map<String, dynamic>> rotateCheckInToken(String gymId) async {
    final res = await dio.post('/gyms/$gymId/qr-check-in-token/rotate');
    return Map<String, dynamic>.from(res.data as Map);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // GYM SAAS SUBSCRIPTION
  // ────────────────────────────────────────────────────────────────────────────

  /// Current gym-level SaaS subscription/trial state, or null if none started.
  Future<Map<String, dynamic>?> getGymSubscription(String gymId) async {
    try {
      final res = await dio.get('/gyms/$gymId/subscription');
      if (res.data == null) return null;
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Start the gym's SaaS trial (owner only).
  Future<void> startGymTrial(String gymId, {String planCode = 'GYM_PRO'}) async {
    await dio.post('/gyms/$gymId/subscription/trial', data: {'planCode': planCode});
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
