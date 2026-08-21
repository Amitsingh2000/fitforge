import 'chat_thread.dart';

/// Cross-gym trainer dashboard from `GET /trainers/me/dashboard`.
class TrainerDashboard {
  final int assignedMembersCount;
  final int pendingWorkoutPlansCount;
  final int pendingDietPlansCount;
  final int unreadMessagesCount;
  final int unreadNotificationsCount;
  final int engagedClientsLast7Days;
  final List<ChatThread> recentThreads;

  const TrainerDashboard({
    this.assignedMembersCount = 0,
    this.pendingWorkoutPlansCount = 0,
    this.pendingDietPlansCount = 0,
    this.unreadMessagesCount = 0,
    this.unreadNotificationsCount = 0,
    this.engagedClientsLast7Days = 0,
    this.recentThreads = const [],
  });

  factory TrainerDashboard.fromJson(Map<String, dynamic> json) {
    final summary = json['progressSummary'] as Map<String, dynamic>? ?? {};
    final threads = json['recentThreads'] as List? ?? [];
    return TrainerDashboard(
      assignedMembersCount: _int(json['assignedMembersCount'] ?? json['assignedClients']),
      pendingWorkoutPlansCount: _int(json['pendingWorkoutPlansCount']),
      pendingDietPlansCount: _int(json['pendingDietPlansCount']),
      unreadMessagesCount: _int(json['unreadMessagesCount'] ?? json['unreadMessageCount']),
      unreadNotificationsCount:
          _int(json['unreadNotificationsCount'] ?? json['unreadNotificationCount']),
      engagedClientsLast7Days: _int(summary['engagedClientsLast7Days']),
      recentThreads: threads
          .whereType<Map>()
          .map((e) => ChatThread.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;
}