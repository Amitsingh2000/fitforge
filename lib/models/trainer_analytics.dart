/// Gym-scoped trainer analytics from `GET /gyms/:gymId/trainer/analytics`.
class TrainerAnalytics {
  /// Total active members assigned to this trainer at this gym.
  final int activeMembers;

  /// Averaged across the trainer's clients (0-100).
  final double avgWorkoutCompletionRatePercent;

  /// Averaged across the trainer's clients (0-100).
  final double avgNutritionComplianceRatePercent;

  /// Share of clients with `goalAchievement: ON_TRACK` (0-100).
  final double goalCompletionRatePercent;

  /// Share of clients with a workout log in the last 7 days (0-100).
  final double engagedClientsLast7dPercent;

  const TrainerAnalytics({
    this.activeMembers = 0,
    this.avgWorkoutCompletionRatePercent = 0,
    this.avgNutritionComplianceRatePercent = 0,
    this.goalCompletionRatePercent = 0,
    this.engagedClientsLast7dPercent = 0,
  });

  factory TrainerAnalytics.fromJson(Map<String, dynamic> json) {
    return TrainerAnalytics(
      activeMembers: (json['activeMembers'] as num?)?.toInt() ??
          _int(json['totalActiveClients']),
      avgWorkoutCompletionRatePercent: _double(
          json['avgWorkoutCompletionRatePercent'] ?? json['avgWorkoutCompletion']),
      avgNutritionComplianceRatePercent: _double(
          json['avgNutritionComplianceRatePercent'] ?? json['avgNutritionCompliance']),
      goalCompletionRatePercent: _double(json['goalCompletionRatePercent']),
      engagedClientsLast7dPercent:
          _double(json['engagedClientsLast7dPercent'] ?? json['engagedLast7d']),
    );
  }

  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;
  static double _double(dynamic v) => (v as num?)?.toDouble() ?? 0;
}