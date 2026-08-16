import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_session.dart';
import '../models/member_profile.dart';
import '../models/member_subscription.dart';
import '../models/member_entitlements.dart';
import '../models/presigned_upload.dart';
import '../models/referral_code.dart';
import 'api_client.dart';

/// Service layer for Normal User (Member) API calls.
///
/// Every method takes plain Dart params, calls the backend via Dio,
/// and returns a clean Dart model — screens never see raw JSON.
class MemberService {
  final Dio dio;
  MemberService(this.dio);

  // ────────────────────────────────────────────────────────────────────────────
  // SESSION MANAGEMENT
  // ────────────────────────────────────────────────────────────────────────────

  /// List active sessions for the current user.
  Future<List<UserSession>> getSessions() async {
    final res = await dio.get('/auth/sessions');
    final list = res.data as List? ?? [];
    return list
        .map((e) => UserSession.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Revoke one session (log out a specific device).
  Future<void> deleteSession(String sessionId) async {
    await dio.delete('/auth/sessions/$sessionId');
  }

  /// Revoke every refresh token (log out all devices).
  Future<void> logoutAllDevices() async {
    await dio.post('/auth/logout-all');
  }

  // ────────────────────────────────────────────────────────────────────────────
  // SUBSCRIPTION & ENTITLEMENTS
  // ────────────────────────────────────────────────────────────────────────────

  /// Get the current user's subscription and trial phase.
  Future<MemberSubscription> getMySubscription() async {
    try {
      final res = await dio.get('/subscriptions/me');
      if (res.data == null) return MemberSubscription.none();
      return MemberSubscription.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return MemberSubscription.none();
      rethrow;
    }
  }

  /// Feature-gating truth: tier + which premium features are unlocked.
  Future<MemberEntitlements> getMyEntitlements() async {
    try {
      final res = await dio.get('/subscriptions/me/entitlements');
      if (res.data == null) return MemberEntitlements.free();
      return MemberEntitlements.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return MemberEntitlements.free();
      rethrow;
    }
  }

  /// Start the 7-day member premium trial.
  Future<void> startTrial({String planCode = 'MEMBER_PREMIUM_AI'}) async {
    await dio.post('/subscriptions/me/trial', data: {
      'planCode': planCode,
    });
  }

  // ────────────────────────────────────────────────────────────────────────────
  // PROFILE UPDATE
  // ────────────────────────────────────────────────────────────────────────────

  /// Update the current user's profile (name, phone, avatar).
  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
  }) async {
    final data = <String, dynamic>{};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (data.isNotEmpty) {
      await dio.patch('/users/me', data: data);
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // GOAL-INTAKE / FITNESS PROFILE
  // ────────────────────────────────────────────────────────────────────────────

  /// The member's goal-intake profile (age, goal, experience, diet, etc.).
  Future<MemberProfile> getMyFitnessProfile() async {
    final res = await dio.get('/members/me/profile');
    return MemberProfile.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Update goal-intake fields. All params optional — only non-null fields
  /// are sent, matching the backend's progressive-save design.
  Future<MemberProfile> updateMyFitnessProfile({
    String? dateOfBirth,
    String? sex,
    double? heightCm,
    double? weightKg,
    String? goal,
    String? experienceLevel,
    String? dietaryPreference,
    String? budgetBand,
    String? equipmentAccess,
    String? injuriesNotes,
    String? weeklyFocus,
  }) async {
    final data = <String, dynamic>{};
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth;
    if (sex != null) data['sex'] = sex;
    if (heightCm != null) data['heightCm'] = heightCm;
    if (weightKg != null) data['weightKg'] = weightKg;
    if (goal != null) data['goal'] = goal;
    if (experienceLevel != null) data['experienceLevel'] = experienceLevel;
    if (dietaryPreference != null) data['dietaryPreference'] = dietaryPreference;
    if (budgetBand != null) data['budgetBand'] = budgetBand;
    if (equipmentAccess != null) data['equipmentAccess'] = equipmentAccess;
    if (injuriesNotes != null) data['injuriesNotes'] = injuriesNotes;
    if (weeklyFocus != null) data['weeklyFocus'] = weeklyFocus;

    final res = await dio.patch('/members/me/profile', data: data);
    return MemberProfile.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // ────────────────────────────────────────────────────────────────────────────
  // MEDIA UPLOAD
  // ────────────────────────────────────────────────────────────────────────────

  /// Check whether media storage is configured.
  Future<bool> getMediaStatus() async {
    try {
      final res = await dio.get('/media/status');
      if (res.data is Map) {
        return res.data['configured'] as bool? ?? false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Get a presigned upload URL for direct-to-storage upload.
  Future<PresignedUpload> presignUpload({
    required String purpose,
    required String contentType,
    required int sizeBytes,
  }) async {
    final res = await dio.post('/media/presign-upload', data: {
      'purpose': purpose,
      'contentType': contentType,
      'sizeBytes': sizeBytes,
    });
    return PresignedUpload.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // ────────────────────────────────────────────────────────────────────────────
  // GYM JOIN
  // ────────────────────────────────────────────────────────────────────────────

  /// Redeem an invite code to join a gym.
  /// Returns the raw response data (membership details).
  Future<Map<String, dynamic>> joinGym(String inviteCode) async {
    final res = await dio.post('/gyms/join', data: {
      'code': inviteCode,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Get a gym's public profile.
  Future<Map<String, dynamic>> getGymProfile(String gymId) async {
    final res = await dio.get('/gyms/$gymId');
    return Map<String, dynamic>.from(res.data as Map);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ATTENDANCE (MEMBER SELF CHECK-IN)
  // ────────────────────────────────────────────────────────────────────────────

  /// Self check-in by scanning the gym's printed QR code.
  Future<void> qrCheckIn({
    required String gymId,
    required String qrToken,
  }) async {
    await dio.post('/gyms/$gymId/attendance/check-in', data: {
      'qrToken': qrToken,
    });
  }

  // ────────────────────────────────────────────────────────────────────────────
  // REFERRALS
  // ────────────────────────────────────────────────────────────────────────────

  /// Get (or mint) the user's shareable referral code for a gym.
  Future<ReferralCode> getMyReferralCode(String gymId) async {
    final res = await dio.get('/gyms/$gymId/referrals/my-code');
    return ReferralCode.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Redeem a friend's referral code.
  Future<void> redeemReferral({
    required String gymId,
    required String code,
  }) async {
    await dio.post('/gyms/$gymId/referrals/redeem', data: {
      'code': code,
    });
  }

  /// Get referrals the user has made and their status.
  Future<List<Referral>> getMyReferrals(String gymId) async {
    final res = await dio.get('/gyms/$gymId/referrals/my-referrals');
    if (res.data is List) {
      return (res.data as List)
          .map((e) => Referral.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    // Paginated response shape
    if (res.data is Map && res.data['items'] is List) {
      return (res.data['items'] as List)
          .map((e) => Referral.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return [];
  }
}

/// Riverpod provider for [MemberService].
final memberServiceProvider = Provider<MemberService>((ref) {
  return MemberService(ref.watch(dioProvider));
});
