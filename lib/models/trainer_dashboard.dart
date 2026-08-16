/// Cross-gym trainer dashboard from `GET /trainers/me/dashboard`.
class TrainerDashboard {
  /// Full list lives at `GET /gyms/:gymId/trainer/clients` (self-scoped).
  final int assignedMembersCount;

  /// DRAFT-status workout plans authored by this trainer.
  final int pendingWorkoutPlansCount;

  /// DRAFT-status diet plans authored by this trainer.
  final int pendingDietPlansCount;

  /// Unread chat messages; full feed at `GET /gyms/:gymId/chat/threads`.
  final int unreadMessagesCount;

  /// Unread in-app alerts; full feed at `GET /trainers/me/notifications`.
  final int unreadNotificationsCount;

  const TrainerDashboard({
    this.assignedMembersCount = 0,
    this.pendingWorkoutPlansCount = 0,
    this.pendingDietPlansCount = 0,
    this.unreadMessagesCount = 0,
    this.unreadNotificationsCount = 0,
  });

  factory TrainerDashboard.fromJson(Map<String, dynamic> json) {
    return TrainerDashboard(
      assignedMembersCount: _int(json['assignedMembersCount'] ?? json['assignedClients']),
      pendingWorkoutPlansCount: _int(json['pendingWorkoutPlansCount']),
      pendingDietPlansCount: _int(json['pendingDietPlansCount']),
      unreadMessagesCount: _int(json['unreadMessagesCount'] ?? json['unreadMessageCount']),
      unreadNotificationsCount:
          _int(json['unreadNotificationsCount'] ?? json['unreadNotificationCount']),
    );
  }

  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;
}