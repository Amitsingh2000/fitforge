/// Feature-gating truth from `GET /subscriptions/me/entitlements`.
///
/// FE drives all paywall UI off this response — never local guesses.
/// Tracking/history is free forever; AI plans, trainer chat, and nutrition
/// analysis gate behind trial/premium per this matrix:
///
/// | tier          | aiPlans | trainerChat | nutritionAnalysis |
/// |---------------|---------|-------------|--------------------|
/// | FREE          | no      | no          | no                 |
/// | TRIAL_LIMITED | no      | yes         | no                 |
/// | TRIAL_FULL    | yes     | yes         | yes                |
/// | PREMIUM       | yes     | yes         | yes                |
///
/// The backend nests the booleans under `features` — not top-level — so
/// parsing must reach into `json['features']`, not `json` directly.
class MemberEntitlements {
  final String tier; // 'FREE' | 'TRIAL_FULL' | 'TRIAL_LIMITED' | 'PREMIUM'
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
    final features = json['features'] as Map<String, dynamic>? ?? const {};
    return MemberEntitlements(
      tier: json['tier'] as String? ?? 'FREE',
      aiPlans: features['aiPlans'] as bool? ?? false,
      trainerChat: features['trainerChat'] as bool? ?? false,
      nutritionAnalysis: features['nutritionAnalysis'] as bool? ?? false,
    );
  }

  /// Default free-tier entitlements.
  factory MemberEntitlements.free() => const MemberEntitlements();

  /// PREMIUM or TRIAL_FULL — matches the backend's own `isPremium` derivation.
  bool get isPremium => tier == 'PREMIUM' || tier == 'TRIAL_FULL';
  bool get isTrial => tier == 'TRIAL_FULL' || tier == 'TRIAL_LIMITED';
  bool get isFree => tier == 'FREE';

  String get tierLabel => switch (tier) {
        'PREMIUM' => 'Premium',
        'TRIAL_FULL' => 'Free Trial (Full Access)',
        'TRIAL_LIMITED' => 'Free Trial',
        _ => 'Free',
      };
}
