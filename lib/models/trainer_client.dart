import 'member_progress_summary.dart';

/// One assigned client from `GET /gyms/:gymId/trainer/clients`.
///
/// Server-derived "mine": the backend only returns members actually assigned
/// to this trainer (active enrollment or a plan they authored) — the client
/// never supplies a filter. A 403 here means a member genuinely isn't yours.
class TrainerClient {
  final String userId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? avatarUrl;

  /// Member's goal from their profile (FitnessGoal enum string).
  final String? fitnessGoal;

  /// Current enrollment plan name, if any.
  final String? planName;

  /// Enrollment/membership status (ACTIVE, EXPIRED, FROZEN, ...).
  final String? membershipStatus;

  final DateTime? joinedAt;

  /// Embedded per-client summary. May be null if the backend hasn't computed
  /// it yet — treat null as "no progress to show".
  final MemberProgressSummary? progressSummary;

  const TrainerClient({
    required this.userId,
    this.firstName = '',
    this.lastName = '',
    this.email,
    this.phone,
    this.avatarUrl,
    this.fitnessGoal,
    this.planName,
    this.membershipStatus,
    this.joinedAt,
    this.progressSummary,
  });

  String get fullName => '$firstName $lastName'.trim().isEmpty
      ? 'Member'
      : '$firstName $lastName'.trim();

  String get initials {
    final names = fullName.split(' ');
    final first = names.first.isNotEmpty ? names.first[0] : '';
    final last = names.length > 1 && names.last.isNotEmpty ? names.last[0] : '';
    return (first + last).toUpperCase();
  }

  /// Heuristic-derived goal achievement status for badge display — this is a
  /// heuristic (ON_TRACK/OFF_TRACK/UNKNOWN), never a precise metric.
  GoalAchievement? get goalAchievement => progressSummary?.goalAchievement;

  factory TrainerClient.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map?;
    final summaryRaw = json['progressSummary'] as Map?;

    final firstName = json['firstName'] as String? ??
        userMap?['firstName'] as String? ??
        '';
    final lastName = json['lastName'] as String? ??
        userMap?['lastName'] as String? ??
        '';

    return TrainerClient(
      userId: json['userId'] as String? ??
          userMap?['id'] as String? ??
          json['id'] as String? ??
          '',
      firstName: firstName,
      lastName: lastName,
      email: json['email'] as String? ?? userMap?['email'] as String?,
      phone: json['phone'] as String? ?? userMap?['phone'] as String?,
      avatarUrl:
          json['avatarUrl'] as String? ?? userMap?['avatarUrl'] as String?,
      fitnessGoal: json['goal'] as String? ??
          json['fitnessGoal'] as String? ??
          userMap?['fitnessGoal'] as String?,
      planName: json['planName'] as String? ??
          json['plan']?['name'] as String?,
      membershipStatus:
          json['membershipStatus'] as String? ?? json['status'] as String? ?? 'ACTIVE',
      joinedAt: _date(json['joinedAt'] ?? json['joinedOn'] ?? json['startDate']),
      progressSummary: summaryRaw != null
          ? MemberProgressSummary.fromJson(
              Map<String, dynamic>.from(summaryRaw))
          : null,
    );
  }

  static DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
}