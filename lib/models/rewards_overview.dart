class DailyCheckInDay {
  final int day;
  final int rewardXp;
  final bool claimed;
  final bool isToday;

  const DailyCheckInDay({
    required this.day,
    this.rewardXp = 0,
    this.claimed = false,
    this.isToday = false,
  });

  factory DailyCheckInDay.fromJson(Map<String, dynamic> json) {
    return DailyCheckInDay(
      day: (json['day'] as num?)?.toInt() ?? 0,
      rewardXp: (json['rewardXp'] as num?)?.toInt() ?? 0,
      claimed: json['claimed'] as bool? ?? false,
      isToday: json['isToday'] as bool? ?? false,
    );
  }
}

class MemberBadge {
  final String id;
  final String code;
  final String name;
  final String? icon;
  final DateTime? unlockedAt;

  const MemberBadge({
    required this.id,
    required this.code,
    required this.name,
    this.icon,
    this.unlockedAt,
  });

  factory MemberBadge.fromJson(Map<String, dynamic> json) {
    return MemberBadge(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
      unlockedAt: json['unlockedAt'] is String
          ? DateTime.tryParse(json['unlockedAt'] as String)
          : null,
    );
  }
}

/// From `GET /members/me/rewards/overview`.
class RewardsOverview {
  final int level;
  final String levelTitle;
  final int currentXp;
  final int nextLevelXp;
  final int totalXp;
  final int totalPoints;
  final int streakDays;
  final List<DailyCheckInDay> dailyCheckInBoard;
  final List<MemberBadge> badges;

  const RewardsOverview({
    this.level = 1,
    this.levelTitle = '',
    this.currentXp = 0,
    this.nextLevelXp = 1000,
    this.totalXp = 0,
    this.totalPoints = 0,
    this.streakDays = 0,
    this.dailyCheckInBoard = const [],
    this.badges = const [],
  });

  factory RewardsOverview.fromJson(Map<String, dynamic> json) {
    return RewardsOverview(
      level: (json['level'] as num?)?.toInt() ?? 1,
      levelTitle: json['levelTitle'] as String? ?? '',
      currentXp: (json['currentXp'] as num?)?.toInt() ?? 0,
      nextLevelXp: (json['nextLevelXp'] as num?)?.toInt() ?? 1000,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      dailyCheckInBoard: (json['dailyCheckInBoard'] as List? ?? [])
          .whereType<Map>()
          .map((e) => DailyCheckInDay.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      badges: (json['badges'] as List? ?? [])
          .whereType<Map>()
          .map((e) => MemberBadge.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class DailyCheckInResult {
  final String claimedDay;
  final int xpGained;
  final bool alreadyClaimed;
  final int newTotalXp;
  final int streakDays;

  const DailyCheckInResult({
    required this.claimedDay,
    this.xpGained = 0,
    this.alreadyClaimed = false,
    this.newTotalXp = 0,
    this.streakDays = 0,
  });

  factory DailyCheckInResult.fromJson(Map<String, dynamic> json) {
    return DailyCheckInResult(
      claimedDay: json['claimedDay'] as String? ?? '',
      xpGained: (json['xpGained'] as num?)?.toInt() ?? 0,
      alreadyClaimed: json['alreadyClaimed'] as bool? ?? false,
      newTotalXp: (json['newTotalXp'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
    );
  }
}

class RewardStoreItem {
  final String id;
  final String code;
  final String title;
  final String? description;
  final int pointsCost;
  final int? stock;

  const RewardStoreItem({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    this.pointsCost = 0,
    this.stock,
  });

  factory RewardStoreItem.fromJson(Map<String, dynamic> json) {
    return RewardStoreItem(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      pointsCost: (json['pointsCost'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt(),
    );
  }
}

class RewardRedemptionResult {
  final String redemptionCode;
  final int remainingPoints;

  const RewardRedemptionResult({
    required this.redemptionCode,
    this.remainingPoints = 0,
  });

  factory RewardRedemptionResult.fromJson(Map<String, dynamic> json) {
    return RewardRedemptionResult(
      redemptionCode: json['redemptionCode'] as String? ?? '',
      remainingPoints: (json['remainingPoints'] as num?)?.toInt() ?? 0,
    );
  }
}
