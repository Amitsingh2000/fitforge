import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_record.dart';
import '../models/communication_log.dart';
import '../models/coupon.dart';
import '../models/enrollment.dart';
import '../models/gym_dashboard_data.dart';
import '../models/gym_member.dart';
import '../models/gym_trainer.dart';
import '../models/join_request.dart';
import '../models/lead.dart';
import '../models/owner_notification.dart';
import '../models/payment.dart';
import '../models/support_request.dart';
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

  /// Update gym profile — name/contact/address/logo/UPI payout details, plus
  /// facilities/working-hours/photo-gallery/owner-notification-preferences.
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
    List<String>? facilities,
    List<Map<String, dynamic>>? workingHours,
    List<String>? photoUrls,
    List<String>? mutedOwnerAlertTypes,
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
      if (facilities != null) 'facilities': facilities,
      if (workingHours != null) 'workingHours': workingHours,
      if (photoUrls != null) 'photoUrls': photoUrls,
      if (mutedOwnerAlertTypes != null) 'mutedOwnerAlertTypes': mutedOwnerAlertTypes,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Get a gym's full profile (owner/staff view).
  Future<Map<String, dynamic>> getGym(String gymId) async {
    final res = await dio.get('/gyms/$gymId');
    return Map<String, dynamic>.from(res.data as Map);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // JOIN REQUESTS (self-serve member join, owner approval)
  // ────────────────────────────────────────────────────────────────────────────

  /// List pending member join requests awaiting approval.
  Future<List<JoinRequest>> getJoinRequests(String gymId) async {
    final res = await dio.get('/gyms/$gymId/join-requests');
    final list = _extractList(res.data);
    return list
        .map((e) => JoinRequest.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Approve a pending join request — activates the membership.
  Future<void> approveJoinRequest(String gymId, String membershipId) async {
    await dio.post('/gyms/$gymId/join-requests/$membershipId/approve');
  }

  /// Reject a pending join request.
  Future<void> rejectJoinRequest(
    String gymId,
    String membershipId, {
    String? reason,
  }) async {
    await dio.post('/gyms/$gymId/join-requests/$membershipId/reject', data: {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
  }

  /// Rotate the gym's join code (self-serve "activation code") — invalidates the old one.
  Future<String?> rotateJoinCode(String gymId) async {
    final res = await dio.post('/gyms/$gymId/join-code/rotate');
    final data = Map<String, dynamic>.from(res.data as Map);
    return data['joinCode'] as String?;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // DASHBOARD
  // ────────────────────────────────────────────────────────────────────────────

  /// Page-1 dashboard widget set: totals, pending join requests, renewals due,
  /// revenue, unread owner alerts.
  Future<GymDashboardOverview> getDashboardOverview(String gymId) async {
    try {
      final res = await dio.get('/gyms/$gymId/dashboard/overview');
      if (res.data == null) return const GymDashboardOverview();
      return GymDashboardOverview.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (_) {
      return const GymDashboardOverview();
    }
  }

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

  /// Last 6 months of new-member counts, oldest first.
  Future<List<GymGrowthPoint>> getGrowthTrend(String gymId) async {
    try {
      final res = await dio.get('/gyms/$gymId/dashboard/growth');
      if (res.data is! List) return [];
      return (res.data as List)
          .map((e) => GymGrowthPoint.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Progress monitoring: overall + trainer-wise engagement (attendance/session-based proxy).
  Future<GymProgressOverview> getProgressOverview(String gymId) async {
    try {
      final res = await dio.get('/gyms/$gymId/dashboard/progress');
      if (res.data == null) return const GymProgressOverview();
      return GymProgressOverview.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (_) {
      return const GymProgressOverview();
    }
  }

  /// Analytics: breakdown of this gym's members by individual premium tier.
  Future<GymSubscriptionUsage> getSubscriptionUsage(String gymId) async {
    try {
      final res = await dio.get('/gyms/$gymId/dashboard/subscription-usage');
      if (res.data == null) return const GymSubscriptionUsage();
      return GymSubscriptionUsage.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (_) {
      return const GymSubscriptionUsage();
    }
  }

  /// Owner-facing in-app alert feed.
  Future<List<OwnerNotification>> getNotifications(
    String gymId, {
    bool unreadOnly = false,
  }) async {
    final res = await dio.get('/gyms/$gymId/dashboard/notifications', queryParameters: {
      if (unreadOnly) 'unreadOnly': 'true',
    });
    final list = _extractList(res.data);
    return list
        .map((e) => OwnerNotification.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Mark an owner alert as read.
  Future<void> markNotificationRead(String gymId, String logId) async {
    await dio.post('/gyms/$gymId/dashboard/notifications/$logId/read');
  }

  // ────────────────────────────────────────────────────────────────────────────
  // SUPPORT
  // ────────────────────────────────────────────────────────────────────────────

  Future<SupportRequest> createSupportRequest(
    String gymId, {
    required String category,
    required String subject,
    required String message,
  }) async {
    final res = await dio.post('/gyms/$gymId/support', data: {
      'category': category,
      'subject': subject,
      'message': message,
    });
    return SupportRequest.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<List<SupportRequest>> getSupportRequests(String gymId, {String? status}) async {
    final res = await dio.get('/gyms/$gymId/support', queryParameters: {
      if (status != null) 'status': status,
    });
    final list = _extractList(res.data);
    return list
        .map((e) => SupportRequest.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
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


  // ────────────────────────────────────────────────────────────────────────────
  // §2.1 ENROLLMENTS (membership lifecycle)
  // ────────────────────────────────────────────────────────────────────────────

  /// Enroll a member in a plan. Optional `couponCode` applies a discount;
  /// price is snapshotted onto the enrollment at purchase time.
  Future<Enrollment> enrollMember(
    String gymId, {
    required String userId,
    required String planId,
    String? couponCode,
    double? priceOverride,
  }) async {
    final res = await dio.post('/gyms/$gymId/memberships', data: {
      'userId': userId,
      'planId': planId,
      if (couponCode != null && couponCode.isNotEmpty) 'couponCode': couponCode,
      if (priceOverride != null) 'priceOverride': priceOverride,
    });
    return Enrollment.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// List enrollments for the gym, optionally filtered by member.
  Future<List<Enrollment>> getEnrollments(
    String gymId, {
    String? memberId,
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (memberId != null) query['userId'] = memberId;
    if (status != null) query['status'] = status;
    final res = await dio.get('/gyms/$gymId/memberships', queryParameters: query);
    final list = _extractList(res.data);
    return list
        .map((e) => Enrollment.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Get a single enrollment by ID.
  Future<Enrollment> getEnrollment(String gymId, String enrollmentId) async {
    final res = await dio.get('/gyms/$gymId/memberships/$enrollmentId');
    return Enrollment.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Freeze an active enrollment (e.g. member travels/injured).
  Future<void> freezeEnrollment(String gymId, String enrollmentId) async {
    await dio.post('/gyms/$gymId/memberships/$enrollmentId/freeze');
  }

  /// Unfreeze — extends endDate by the actual frozen duration so the member
  /// never loses paid days.
  Future<void> unfreezeEnrollment(String gymId, String enrollmentId) async {
    await dio.post('/gyms/$gymId/memberships/$enrollmentId/unfreeze');
  }

  /// Renew — creates the next enrollment starting when the current one ends
  /// (or now if already lapsed). The old enrollment becomes CANCELLED.
  Future<Enrollment> renewEnrollment(
    String gymId,
    String enrollmentId, {
    double? priceOverride,
  }) async {
    final res = await dio.post('/gyms/$gymId/memberships/$enrollmentId/renew', data: {
      if (priceOverride != null) 'priceOverride': priceOverride,
    });
    return Enrollment.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Change plan — upgrade/downgrade with auto-proration of unused value.
  /// Staff can still override the final price.
  Future<Enrollment> changePlan(
    String gymId,
    String enrollmentId, {
    required String newPlanId,
    double? priceOverride,
  }) async {
    final res = await dio.post('/gyms/$gymId/memberships/$enrollmentId/change-plan', data: {
      'newPlanId': newPlanId,
      if (priceOverride != null) 'priceOverride': priceOverride,
    });
    return Enrollment.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Transfer an enrollment to a different member — no money math involved.
  Future<void> transferEnrollment(
    String gymId,
    String enrollmentId, {
    required String toUserId,
  }) async {
    await dio.post('/gyms/$gymId/memberships/$enrollmentId/transfer', data: {
      'toUserId': toUserId,
    });
  }

  /// Assign a trainer to a SESSION-type enrollment.
  Future<void> assignTrainerToEnrollment(
    String gymId,
    String enrollmentId, {
    required String trainerId,
  }) async {
    await dio.post('/gyms/$gymId/memberships/$enrollmentId/assign-trainer', data: {
      'trainerId': trainerId,
    });
  }

  /// Log a PT/class session — decrements sessionsRemaining.
  /// Auto-flips enrollment to EXPIRED when the last session is used.
  Future<void> logSession(
    String gymId,
    String enrollmentId, {
    String? sessionDate,
    String? notes,
  }) async {
    await dio.post('/gyms/$gymId/memberships/$enrollmentId/session-logs', data: {
      if (sessionDate != null) 'sessionDate': sessionDate,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  /// Get session logs for a SESSION-type enrollment.
  Future<List<Map<String, dynamic>>> getSessionLogs(
    String gymId,
    String enrollmentId,
  ) async {
    try {
      final res = await dio.get('/gyms/$gymId/memberships/$enrollmentId/session-logs');
      final list = _extractList(res.data);
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // §2.2 PAYMENTS & BILLING
  // ────────────────────────────────────────────────────────────────────────────

  /// Record a manual payment (cash / UPI / card / bank transfer).
  /// May be tied to an enrollment (`enrollmentId`) or ad-hoc.
  /// May be backdated via `paidAt` (ISO 8601 string).
  Future<GymPayment> recordPayment(
    String gymId, {
    required double amountInr,
    required String method, // CASH | UPI_MANUAL | BANK_TRANSFER | CARD_OFFLINE | OTHER
    String? enrollmentId,
    String? paidAt,
    String? notes,
  }) async {
    final res = await dio.post('/gyms/$gymId/payments', data: {
      'amountInr': amountInr,
      'method': method,
      if (enrollmentId != null && enrollmentId.isNotEmpty) 'enrollmentId': enrollmentId,
      if (paidAt != null) 'paidAt': paidAt,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return GymPayment.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// List payments for a gym. Optionally filter by enrollment.
  Future<List<GymPayment>> getPayments(
    String gymId, {
    String? enrollmentId,
    int page = 1,
    int limit = 50,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (enrollmentId != null) query['enrollmentId'] = enrollmentId;
    final res = await dio.get('/gyms/$gymId/payments', queryParameters: query);
    final list = _extractList(res.data);
    return list
        .map((e) => GymPayment.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Void a payment — never hard-delete; voiding restores the dues amount.
  Future<void> voidPayment(
    String gymId,
    String paymentId, {
    String? reason,
  }) async {
    await dio.post('/gyms/$gymId/payments/$paymentId/void', data: {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
  }

  /// Get the printable receipt data for a single payment.
  Future<Map<String, dynamic>> getPaymentReceipt(
    String gymId,
    String paymentId,
  ) async {
    final res = await dio.get('/gyms/$gymId/payments/$paymentId/receipt');
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Dues dashboard — lists members with outstanding amounts.
  /// Dues = enrollment price − Σ(recorded payments).
  Future<List<DuesSummary>> getDuesDashboard(String gymId) async {
    try {
      final res = await dio.get('/gyms/$gymId/payments/dues');
      final list = _extractList(res.data);
      return list
          .map((e) => DuesSummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // §2.3 ATTENDANCE
  // ────────────────────────────────────────────────────────────────────────────

  /// Front-desk manual check-in for today (no QR needed).
  Future<void> manualCheckIn(String gymId, {required String userId}) async {
    await dio.post('/gyms/$gymId/attendance/manual', data: {'userId': userId});
  }

  /// List attendance entries. Filter by date (ISO YYYY-MM-DD) and/or member.
  Future<List<AttendanceRecord>> getAttendance(
    String gymId, {
    String? date,
    String? memberId,
    int page = 1,
    int limit = 100,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (date != null) query['date'] = date;
    if (memberId != null) query['userId'] = memberId;
    final res = await dio.get('/gyms/$gymId/attendance', queryParameters: query);
    final list = _extractList(res.data);
    return list
        .map((e) => AttendanceRecord.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Backfill / calendar add — one entry per member per day.
  Future<AttendanceRecord> addAttendanceEntry(
    String gymId, {
    required String userId,
    required String attendedOn, // ISO date YYYY-MM-DD
  }) async {
    final res = await dio.post('/gyms/$gymId/attendance', data: {
      'userId': userId,
      'attendedOn': attendedOn,
    });
    return AttendanceRecord.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Update an existing attendance entry (e.g. correct the date).
  Future<void> updateAttendanceEntry(
    String gymId,
    String attendanceId, {
    required String attendedOn,
  }) async {
    await dio.patch('/gyms/$gymId/attendance/$attendanceId', data: {
      'attendedOn': attendedOn,
    });
  }

  /// Delete an attendance entry — GYM_OWNER / GYM_MANAGER only.
  Future<void> deleteAttendanceEntry(String gymId, String attendanceId) async {
    await dio.delete('/gyms/$gymId/attendance/$attendanceId');
  }

  /// Absence alerts — members who haven't visited in N days.
  Future<List<AbsenceAlert>> getAbsenceAlerts(String gymId) async {
    try {
      final res = await dio.get('/gyms/$gymId/attendance/absence-alerts');
      final list = _extractList(res.data);
      return list
          .map((e) => AbsenceAlert.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // §2.4 COUPONS & OFFERS
  // ────────────────────────────────────────────────────────────────────────────

  /// List coupons. Pass `includeInactive: true` to show soft-deleted ones.
  Future<List<GymCoupon>> getCoupons(
    String gymId, {
    bool includeInactive = false,
  }) async {
    final res = await dio.get('/gyms/$gymId/coupons', queryParameters: {
      if (includeInactive) 'includeInactive': 'true',
    });
    final list = _extractList(res.data);
    return list
        .map((e) => GymCoupon.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Create a coupon. `type` is 'PERCENT' or 'FLAT'.
  /// `applicablePlanIds` restricts the coupon to specific plans.
  Future<GymCoupon> createCoupon(
    String gymId, {
    required String code,
    required String type,
    required double value,
    String? validFrom,
    String? validUntil,
    int? usageLimit,
    List<String>? applicablePlanIds,
  }) async {
    final res = await dio.post('/gyms/$gymId/coupons', data: {
      'code': code,
      'type': type,
      'value': value,
      if (validFrom != null) 'validFrom': validFrom,
      if (validUntil != null) 'validUntil': validUntil,
      if (usageLimit != null) 'usageLimit': usageLimit,
      if (applicablePlanIds != null && applicablePlanIds.isNotEmpty)
        'applicablePlanIds': applicablePlanIds,
    });
    return GymCoupon.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Update a coupon (e.g. toggle active/inactive, update limit).
  Future<GymCoupon> updateCoupon(
    String gymId,
    String couponId, {
    bool? isActive,
    int? usageLimit,
  }) async {
    final res = await dio.patch('/gyms/$gymId/coupons/$couponId', data: {
      if (isActive != null) 'isActive': isActive,
      if (usageLimit != null) 'usageLimit': usageLimit,
    });
    return GymCoupon.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Soft-deactivate a coupon. Redemption history survives.
  Future<void> deactivateCoupon(String gymId, String couponId) async {
    await dio.delete('/gyms/$gymId/coupons/$couponId');
  }

  /// Get redemption history for a coupon (for campaign analytics).
  Future<List<Map<String, dynamic>>> getCouponRedemptions(
    String gymId,
    String couponId,
  ) async {
    try {
      final res = await dio.get('/gyms/$gymId/coupons/$couponId/redemptions');
      final list = _extractList(res.data);
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // §2.5 REFERRAL CONFIG (owner-side)
  // ────────────────────────────────────────────────────────────────────────────

  /// Get the gym's current member-referral reward config.
  Future<Map<String, dynamic>?> getReferralConfig(String gymId) async {
    try {
      final res = await dio.get('/gyms/$gymId/referrals/config');
      if (res.data == null) return null;
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Set the member-referral reward config.
  /// `rewardType`: 'FREE_DAYS' | 'FLAT_DISCOUNT_COUPON'.
  /// `rewardValue`: days (for FREE_DAYS) or INR amount (for coupon).
  Future<void> setReferralConfig(
    String gymId, {
    required String rewardType,
    required double rewardValue,
  }) async {
    await dio.put('/gyms/$gymId/referrals/config', data: {
      'rewardType': rewardType,
      'rewardValue': rewardValue,
    });
  }

  // ────────────────────────────────────────────────────────────────────────────
  // §2.6 LEADS (fitness CRM pipeline)
  // ────────────────────────────────────────────────────────────────────────────

  /// List leads. Filter by stage, source, or assignee.
  Future<List<GymLead>> getLeads(
    String gymId, {
    String? stage,
    String? source,
    String? assigneeId,
    int page = 1,
    int limit = 100,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (stage != null) query['stage'] = stage;
    if (source != null) query['source'] = source;
    if (assigneeId != null) query['assigneeId'] = assigneeId;
    final res = await dio.get('/gyms/$gymId/leads', queryParameters: query);
    final list = _extractList(res.data);
    return list
        .map((e) => GymLead.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Capture a new lead (walk-in / phone / Instagram / website).
  Future<GymLead> createLead(
    String gymId, {
    required String name,
    String? phone,
    String? email,
    required String source,
    String? assigneeId,
    String? notes,
  }) async {
    final res = await dio.post('/gyms/$gymId/leads', data: {
      'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      'source': source,
      if (assigneeId != null) 'assigneeId': assigneeId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return GymLead.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Update a lead — move stage, add follow-up notes.
  Future<GymLead> updateLead(
    String gymId,
    String leadId, {
    String? stage,
    String? notes,
    String? followUpAt,
  }) async {
    final res = await dio.patch('/gyms/$gymId/leads/$leadId', data: {
      if (stage != null) 'stage': stage,
      if (notes != null) 'notes': notes,
      if (followUpAt != null) 'followUpAt': followUpAt,
    });
    return GymLead.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Convert a lead — finds-or-creates the person and attaches the MEMBER role.
  /// Enroll them separately via `/memberships` after conversion.
  Future<Map<String, dynamic>> convertLead(String gymId, String leadId) async {
    final res = await dio.post('/gyms/$gymId/leads/$leadId/convert');
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Conversion metrics: total leads, converted, conversion rate, etc.
  Future<Map<String, dynamic>> getLeadMetrics(String gymId) async {
    try {
      final res = await dio.get('/gyms/$gymId/leads/metrics');
      if (res.data == null) return {};
      return Map<String, dynamic>.from(res.data as Map);
    } catch (_) {
      return {};
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // §2.7 COMMUNICATIONS HUB
  // ────────────────────────────────────────────────────────────────────────────

  /// Get the staff outbox — WhatsApp tap-to-send messages pending manual send.
  Future<List<CommunicationLog>> getCommunications(
    String gymId, {
    bool pendingOnly = false,
    int page = 1,
    int limit = 50,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (pendingOnly) query['pendingOnly'] = 'true';
    final res = await dio.get('/gyms/$gymId/communications', queryParameters: query);
    final list = _extractList(res.data);
    return list
        .map((e) => CommunicationLog.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Mark a WhatsApp message as sent (front desk confirms after tapping wa.me).
  Future<void> markCommunicationSent(String gymId, String commId) async {
    await dio.post('/gyms/$gymId/communications/$commId/mark-sent');
  }

  /// Broadcast an announcement to targeted or all active members.
  /// Reliable delivery is email at scale. WhatsApp = one tap per member.
  Future<void> sendAnnouncement(
    String gymId, {
    required String title,
    required String body,
    String? channel, // defaults to all available channels
    List<String>? targetUserIds, // null = all active members
  }) async {
    await dio.post('/gyms/$gymId/communications/announce', data: {
      'title': title,
      'body': body,
      if (channel != null) 'channel': channel,
      if (targetUserIds != null) 'targetUserIds': targetUserIds,
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
