/// Represents a gym discount coupon.
///
/// Source: `POST/GET/PATCH/DELETE /gyms/:gymId/coupons`.
/// Types: PERCENT (percentage off) | FLAT (fixed rupee amount off).
/// Codes are case-insensitive on redemption.
/// Deactivate is a soft-delete so redemption history survives.
class GymCoupon {
  final String id;
  final String code;
  final String type; // PERCENT | FLAT
  final double value; // percent value (0–100) or flat amount in INR
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int? usageLimit;
  final int usageCount;
  final List<String> applicablePlanIds;
  final bool isActive;
  final bool appliesToPremium;

  const GymCoupon({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.validFrom,
    this.validUntil,
    this.usageLimit,
    this.usageCount = 0,
    this.applicablePlanIds = const [],
    this.isActive = true,
    this.appliesToPremium = false,
  });

  factory GymCoupon.fromJson(Map<String, dynamic> json) {
    return GymCoupon(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      type: json['discountType'] as String? ?? json['type'] as String? ?? 'FLAT',
      value: _toDouble(json['discountValue'] ?? json['value']),
      validFrom: _tryParseDate(json['validFrom']),
      validUntil: _tryParseDate(json['validUntil']),
      usageLimit: json['maxUses'] as int? ?? json['usageLimit'] as int?,
      usageCount: json['usesCount'] as int? ?? json['usageCount'] as int? ?? 0,
      applicablePlanIds: (json['applicablePlanIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
      appliesToPremium: json['appliesToPremium'] as bool? ?? false,
    );
  }

  String get displayValue =>
      type == 'PERCENT' ? '${value.toStringAsFixed(0)}% off' : '₹${value.toStringAsFixed(0)} off';

  bool get hasUsageLimit => usageLimit != null;
  bool get isExpired =>
      validUntil != null && validUntil!.isBefore(DateTime.now());

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
