/// A daily task from `GET /members/me/tasks` or embedded in dashboard/today.
class DailyTask {
  final String id;
  final String title;
  final bool completed;
  final int xp;

  const DailyTask({
    required this.id,
    required this.title,
    this.completed = false,
    this.xp = 0,
  });

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Result of `PATCH /members/me/tasks/:taskId`.
class DailyTaskCompletion {
  final String taskId;
  final bool completed;
  final int xpGained;
  final int totalXp;

  const DailyTaskCompletion({
    required this.taskId,
    this.completed = true,
    this.xpGained = 0,
    this.totalXp = 0,
  });

  factory DailyTaskCompletion.fromJson(Map<String, dynamic> json) {
    return DailyTaskCompletion(
      taskId: json['taskId'] as String? ?? '',
      completed: json['completed'] as bool? ?? true,
      xpGained: (json['xpGained'] as num?)?.toInt() ?? 0,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
    );
  }
}
