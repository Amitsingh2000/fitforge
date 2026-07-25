/// Feature-gating truth from `GET /subscriptions/me/entitlements`.
///
/// FE drives all paywall UI off this response.
/// Tracking/history is free forever; premium features gate behind trial/premium.
class MemberEntitlements {
  final String tier; // 'FREE', 'TRIAL', 'PREMIUM'
  final bool aiPlans;
  final bool trainerChat;
  final bool nutritionAnalysis;

  const MemberEntitlements({
    this.tier = 'FREE',
    this.aiPlans = false,
    this.trainerChat = false,
    this.nutritionAnalysis = false,
  });

  factory MemberEntitlements.fromJson(Map<String, dynamic> json) {
    return MemberEntitlements(
      tier: json['tier'] as String? ?? 'FREE',
      aiPlans: json['aiPlans'] as bool? ?? false,
      trainerChat: json['trainerChat'] as bool? ?? false,
      nutritionAnalysis: json['nutritionAnalysis'] as bool? ?? false,
    );
  }

  /// Default free-tier entitlements.
  factory MemberEntitlements.free() => const MemberEntitlements();

  bool get isPremium => tier == 'PREMIUM';
  bool get isTrial => tier == 'TRIAL';
  bool get isFree => tier == 'FREE';
}
