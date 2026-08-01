/// Represents a `MemberPlanEnrollment` — one member's specific instance of a
/// membership plan, with its own status, dates, price, and sessions snapshot.
///
/// Source: `POST/GET /gyms/:gymId/memberships` and related lifecycle endpoints.
/// Enrollment status: ACTIVE · FROZEN · EXPIRED · CANCELLED.
class Enrollment {
  final String id;
  final String status; // ACTIVE | FROZEN | EXPIRED | CANCELLED
  final String userId;
  final String? planId;
  final String? planName;
  final String? planType; // DURATION | SESSION
  final DateTime? startDate;
  final DateTime? endDate;
  final double priceInr;
  final int? sessionsTotal;
  final int? sessionsRemaining;
  final String? couponCode;
  final String? previousEnrollmentId;
  final String? assignedTrainerId;
  final String? assignedTrainerName;
  final double? dueAmountInr; // live-computed: priceInr - Σ(payments)

  const Enrollment({
    required this.id,
    required this.status,
    required this.userId,
    this.planId,
    this.planName,
    this.planType,
    this.startDate,
    this.endDate,
    this.priceInr = 0,
    this.sessionsTotal,
    this.sessionsRemaining,
    this.couponCode,
    this.previousEnrollmentId,
    this.assignedTrainerId,
    this.assignedTrainerName,
    this.dueAmountInr,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    final planMap = json['plan'] as Map<String, dynamic>?;
    final trainerMap = json['assignedTrainer'] as Map<String, dynamic>?;

    return Enrollment(
      id: json['id'] as String? ?? json['enrollmentId'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      userId: json['userId'] as String? ?? '',
      planId: json['planId'] as String? ?? planMap?['id'] as String?,
      planName: json['planName'] as String? ?? planMap?['name'] as String?,
      planType: json['planType'] as String? ?? planMap?['type'] as String?,
      startDate: _tryParseDate(json['startDate']),
      endDate: _tryParseDate(json['endDate']),
      priceInr: _toDouble(json['priceInr']),
      sessionsTotal: json['sessionsTotal'] as int? ?? json['sessionCount'] as int?,
      sessionsRemaining: json['sessionsRemaining'] as int?,
      couponCode: json['couponCode'] as String?,
      previousEnrollmentId: json['previousEnrollmentId'] as String?,
      assignedTrainerId: json['assignedTrainerId'] as String? ?? trainerMap?['id'] as String?,
      assignedTrainerName: json['assignedTrainerName'] as String? ?? trainerMap?['name'] as String?,
      dueAmountInr: _toDoubleNullable(json['dueAmountInr'] ?? json['dues']),
    );
  }

  bool get isActive => status == 'ACTIVE';
  bool get isFrozen => status == 'FROZEN';
  bool get isExpired => status == 'EXPIRED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isSessionBased => planType == 'SESSION';

  String get displayStatus => switch (status) {
        'ACTIVE' => 'Active',
        'FROZEN' => 'Frozen',
        'EXPIRED' => 'Expired',
        'CANCELLED' => 'Cancelled',
        _ => status,
      };

  static DateTime? _tryParseDate(dynamic val) {
    if (val == null) return null;
    if (val is String) return DateTime.tryParse(val);
    return null;
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0;
  }

  static double? _toDoubleNullable(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }
}
