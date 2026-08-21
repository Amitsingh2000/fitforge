/// Represents a payment recorded at a gym.
///
/// Source: `POST/GET /gyms/:gymId/payments`.
/// Methods: CASH | UPI_MANUAL | BANK_TRANSFER | CARD_OFFLINE | OTHER.
/// Payments are never hard-deleted — void restores dues.
class GymPayment {
  final String id;
  final String receiptNumber;
  final String? enrollmentId;
  final String? memberName;
  final double amountInr;
  final String method; // CASH | UPI_MANUAL | BANK_TRANSFER | CARD_OFFLINE | OTHER
  final DateTime? paidAt;
  final DateTime? voidedAt;
  final String? notes;
  final bool isVoided;

  const GymPayment({
    required this.id,
    required this.receiptNumber,
    this.enrollmentId,
    this.memberName,
    required this.amountInr,
    required this.method,
    this.paidAt,
    this.voidedAt,
    this.notes,
    this.isVoided = false,
  });

  factory GymPayment.fromJson(Map<String, dynamic> json) {
    return GymPayment(
      id: json['id'] as String? ?? '',
      receiptNumber: json['receiptNumber'] as String? ?? '—',
      enrollmentId: json['enrollmentId'] as String?,
      memberName: json['memberName'] as String? ??
          (json['user'] as Map<String, dynamic>?)?['fullName'] as String? ??
          (json['member'] as Map<String, dynamic>?)?['name'] as String?,
      amountInr: _toDouble(json['amountInr']),
      method: json['method'] as String? ?? 'CASH',
      paidAt: _tryParseDate(json['paidOn'] ?? json['paidAt']),
      voidedAt: _tryParseDate(json['voidedAt']),
      notes: json['notes'] as String?,
      isVoided: json['voidedAt'] != null || json['isVoided'] == true,
    );
  }

  String get methodLabel => switch (method) {
        'CASH' => 'Cash',
        'UPI_MANUAL' => 'UPI',
        'BANK_TRANSFER' => 'Bank Transfer',
        'CARD_OFFLINE' => 'Card',
        _ => 'Other',
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
}

/// Summary row from `GET /gyms/:gymId/payments/dues`.
class DuesSummary {
  final String membershipId;
  final String? userId;
  final String memberName;
  final String? enrollmentId;
  final String? planName;
  final double dueAmountInr;

  const DuesSummary({
    required this.membershipId,
    this.userId,
    required this.memberName,
    this.enrollmentId,
    this.planName,
    required this.dueAmountInr,
  });

  factory DuesSummary.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final plan = json['plan'] as Map<String, dynamic>?;
    return DuesSummary(
      membershipId: json['membershipId'] as String? ??
          json['id'] as String? ??
          json['userId'] as String? ??
          '',
      userId: json['userId'] as String? ?? user?['id'] as String?,
      memberName: json['memberName'] as String? ??
          user?['fullName'] as String? ??
          'Unknown',
      enrollmentId: json['enrollmentId'] as String? ?? json['id'] as String?,
      planName: json['planName'] as String? ?? plan?['name'] as String?,
      dueAmountInr: _toDouble(
        json['dueAmountInr'] ?? json['duesInr'] ?? json['dues'],
      ),
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0;
  }
}
