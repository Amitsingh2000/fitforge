/// Heuristic per-client progress verdict from `progress-summary` /
/// embedded in each `trainer/clients` entry.
///
/// ⚠️ This is a **heuristic**, not a tracked metric (weight-trend direction vs
/// the member's goal, with a workout-completion fallback). Never render it as
/// a precise percentage or treat it as factual goal tracking.
enum GoalAchievement {
  onTrack,
  offTrack,
  unknown;

  static GoalAchievement fromString(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'ON_TRACK':
        return GoalAchievement.onTrack;
      case 'OFF_TRACK':
        return GoalAchievement.offTrack;
      default:
        return GoalAchievement.unknown;
    }
  }

  String get wireValue => switch (this) {
        GoalAchievement.onTrack => 'ON_TRACK',
        GoalAchievement.offTrack => 'OFF_TRACK',
        GoalAchievement.unknown => 'UNKNOWN',
      };
}

/// Summary from `GET /gyms/:gymId/members/:userId/progress-summary`.
/// The same shape is embedded as `progressSummary` on each trainer/clients
/// entry, so this one model serves both endpoints.
class MemberProgressSummary {
  /// Completed plan-linked workout logs ÷ scheduled plan days elapsed (0-100).
  final int workoutCompletionRatePercent;

  /// Days logged on the active diet plan ÷ days elapsed (0-100).
  final int nutritionComplianceRatePercent;

  /// Trend direction derived from recent `progress-entries[].weightKg`
  /// (e.g. `DOWN`, `UP`, `STABLE`) — freeform string, not an enum.
  final String? weightTrend;

  /// Heuristic verdict — see [GoalAchievement].
  final GoalAchievement goalAchievement;

  /// Optional supporting counts the backend may include.
  final int? workoutsLoggedCount;
  final int? nutritionDaysLoggedCount;
  final DateTime? planStartedAt;

  const MemberProgressSummary({
    this.workoutCompletionRatePercent = 0,
    this.nutritionComplianceRatePercent = 0,
    this.weightTrend,
    this.goalAchievement = GoalAchievement.unknown,
    this.workoutsLoggedCount,
    this.nutritionDaysLoggedCount,
    this.planStartedAt,
  });

  factory MemberProgressSummary.fromJson(Map<String, dynamic> json) {
    return MemberProgressSummary(
      workoutCompletionRatePercent: _int(
          json['workoutCompletionRatePercent'] ?? json['workoutCompletion']),
      nutritionComplianceRatePercent: _int(
          json['nutritionComplianceRatePercent'] ?? json['nutritionCompliance']),
      weightTrend: json['weightTrend'] as String?,
      goalAchievement: GoalAchievement.fromString(json['goalAchievement'] as String?),
      workoutsLoggedCount: _intOrNull(json['workoutsLoggedCount']),
      nutritionDaysLoggedCount: _intOrNull(json['nutritionDaysLoggedCount']),
      planStartedAt: _date(json['planStartedAt'] ?? json['lastPlanAssignedAt']),
    );
  }

  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;
  static int? _intOrNull(dynamic v) => (v as num?)?.toInt();
  static DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
}