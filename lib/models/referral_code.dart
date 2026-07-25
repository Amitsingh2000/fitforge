/// My shareable referral code from `GET /gyms/:gymId/referrals/my-code`.
class ReferralCode {
  final String code;
  final int totalReferrals;
  final int qualifiedReferrals;

  const ReferralCode({
    required this.code,
    this.totalReferrals = 0,
    this.qualifiedReferrals = 0,
  });

  factory ReferralCode.fromJson(Map<String, dynamic> json) {
    return ReferralCode(
      code: json['code'] as String? ?? '',
      totalReferrals: json['totalReferrals'] as int? ?? 0,
      qualifiedReferrals: json['qualifiedReferrals'] as int? ?? 0,
    );
  }
}

/// A single referral entry from `GET /gyms/:gymId/referrals/my-referrals`.
class Referral {
  final String id;
  final String? refereeFirstName;
  final String? refereeLastName;
  final String status; // 'PENDING', 'QUALIFIED', etc.
  final DateTime? createdAt;

  const Referral({
    required this.id,
    this.refereeFirstName,
    this.refereeLastName,
    this.status = 'PENDING',
    this.createdAt,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] as String? ?? '',
      refereeFirstName: json['refereeFirstName'] as String? ??
          json['referee']?['firstName'] as String?,
      refereeLastName: json['refereeLastName'] as String? ??
          json['referee']?['lastName'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  String get refereeName {
    final first = refereeFirstName ?? '';
    final last = refereeLastName ?? '';
    final name = '$first $last'.trim();
    return name.isNotEmpty ? name : 'Unknown';
  }
}
