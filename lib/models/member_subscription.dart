/// The user's SaaS subscription state from `GET /subscriptions/me`.
class MemberSubscription {
  final String? planCode;
  final String status; // 'ACTIVE', 'TRIALING', 'EXPIRED', 'NONE', etc.
  final String? trialPhase; // 'FULL_ACCESS', 'LIMITED', null
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;

  const MemberSubscription({
    this.planCode,
    this.status = 'NONE',
    this.trialPhase,
    this.startDate,
    this.endDate,
    this.trialStartDate,
    this.trialEndDate,
  });

  factory MemberSubscription.fromJson(Map<String, dynamic> json) {
    return MemberSubscription(
      planCode: json['planCode'] as String?,
      status: json['status'] as String? ?? 'NONE',
      trialPhase: json['trialPhase'] as String?,
      startDate: _tryParse(json['startDate']),
      endDate: _tryParse(json['endDate']),
      trialStartDate: _tryParse(json['trialStartDate']),
      trialEndDate: _tryParse(json['trialEndDate']),
    );
  }

  /// Empty/default subscription (no plan).
  factory MemberSubscription.none() => const MemberSubscription();

  bool get isActive => status == 'ACTIVE';
  bool get isTrialing => status == 'TRIALING';
  bool get hasSubscription => status != 'NONE' && planCode != null;

  /// Human-readable tier label.
  String get tierLabel {
    if (isTrialing) return 'TRIAL';
    if (isActive) return 'PREMIUM';
    return 'FREE';
  }

  /// Renewal/expiry date as a readable string.
  String get renewalLabel {
    final date = endDate ?? trialEndDate;
    if (date == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static DateTime? _tryParse(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
