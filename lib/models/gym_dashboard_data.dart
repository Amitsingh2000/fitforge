/// Data from `GET /gyms/:gymId/dashboard/today`
class GymDashboardToday {
  final int totalCheckIns;
  final int collectionsAmount;
  final int newJoinsCount;
  final int expiringSoonCount;
  final int totalDuesAmount;

  const GymDashboardToday({
    this.totalCheckIns = 0,
    this.collectionsAmount = 0,
    this.newJoinsCount = 0,
    this.expiringSoonCount = 0,
    this.totalDuesAmount = 0,
  });

  factory GymDashboardToday.fromJson(Map<String, dynamic> json) {
    return GymDashboardToday(
      totalCheckIns: _parseInt(json['checkIns'] ?? json['totalCheckIns'] ?? json['checkInsToday']),
      collectionsAmount: _parseInt(json['collectionsInr'] ?? json['collectionsAmount'] ?? json['collectionsToday'] ?? json['collections']),
      newJoinsCount: _parseInt(json['newJoins'] ?? json['newJoinsCount'] ?? json['newJoinsToday']),
      expiringSoonCount: _parseInt(json['expiringSoon'] ?? json['expiringSoonCount']),
      totalDuesAmount: _parseInt(json['duesTotalInr'] ?? json['totalDuesAmount'] ?? json['totalDues'] ?? json['pendingDues']),
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }
}

/// Data from `GET /gyms/:gymId/dashboard/monthly`
class GymDashboardMonthly {
  final int totalRevenue;
  final int activeMembersCount;
  final int renewalsCount;
  final int churnCount;
  final double? retentionRatePercent;
  final List<dynamic> attendanceTrend;

  const GymDashboardMonthly({
    this.totalRevenue = 0,
    this.activeMembersCount = 0,
    this.renewalsCount = 0,
    this.churnCount = 0,
    this.retentionRatePercent,
    this.attendanceTrend = const [],
  });

  factory GymDashboardMonthly.fromJson(Map<String, dynamic> json) {
    return GymDashboardMonthly(
      totalRevenue: GymDashboardToday._parseInt(json['revenueInr'] ?? json['totalRevenue'] ?? json['revenue']),
      activeMembersCount: GymDashboardToday._parseInt(json['activeMembers'] ?? json['activeMembersCount']),
      renewalsCount: GymDashboardToday._parseInt(json['renewalsThisMonth'] ?? json['renewalsCount'] ?? json['renewals']),
      churnCount: GymDashboardToday._parseInt(json['churnThisMonth'] ?? json['churnCount'] ?? json['churn']),
      retentionRatePercent: (json['retentionRatePercent'] as num?)?.toDouble(),
      attendanceTrend: json['attendanceTrend'] as List? ?? [],
    );
  }
}

/// Data from `GET /gyms/:gymId/dashboard/overview` — page-1 dashboard widget set.
class GymDashboardOverview {
  final int totalMembers;
  final int totalTrainers;
  final int activeMemberships;
  final int pendingJoinRequests;
  final int membershipRenewalsDue;
  final int revenueTodayInr;
  final int revenueMonthInr;
  final int unreadNotifications;

  const GymDashboardOverview({
    this.totalMembers = 0,
    this.totalTrainers = 0,
    this.activeMemberships = 0,
    this.pendingJoinRequests = 0,
    this.membershipRenewalsDue = 0,
    this.revenueTodayInr = 0,
    this.revenueMonthInr = 0,
    this.unreadNotifications = 0,
  });

  factory GymDashboardOverview.fromJson(Map<String, dynamic> json) {
    final revenue = json['revenueOverview'] as Map<String, dynamic>? ?? {};
    return GymDashboardOverview(
      totalMembers: GymDashboardToday._parseInt(json['totalMembers']),
      totalTrainers: GymDashboardToday._parseInt(json['totalTrainers']),
      activeMemberships: GymDashboardToday._parseInt(json['activeMemberships']),
      pendingJoinRequests: GymDashboardToday._parseInt(json['pendingJoinRequests']),
      membershipRenewalsDue: GymDashboardToday._parseInt(json['membershipRenewalsDue']),
      revenueTodayInr: GymDashboardToday._parseInt(revenue['todayInr']),
      revenueMonthInr: GymDashboardToday._parseInt(revenue['monthInr']),
      unreadNotifications: GymDashboardToday._parseInt(json['unreadNotifications']),
    );
  }
}

/// One point from `GET /gyms/:gymId/dashboard/growth`.
class GymGrowthPoint {
  final String month; // "YYYY-MM"
  final int newMembers;

  const GymGrowthPoint({required this.month, this.newMembers = 0});

  factory GymGrowthPoint.fromJson(Map<String, dynamic> json) {
    return GymGrowthPoint(
      month: json['month'] as String? ?? '',
      newMembers: GymDashboardToday._parseInt(json['newMembers']),
    );
  }
}

/// Per-trainer row inside `GymProgressOverview.byTrainer`.
class TrainerProgressRow {
  final String trainerUserId;
  final String trainerName;
  final int assignedActiveClients;
  final double? clientCheckInRate7dPercent;
  final double? avgSessionPackUtilizationPercent;

  const TrainerProgressRow({
    required this.trainerUserId,
    required this.trainerName,
    this.assignedActiveClients = 0,
    this.clientCheckInRate7dPercent,
    this.avgSessionPackUtilizationPercent,
  });

  factory TrainerProgressRow.fromJson(Map<String, dynamic> json) {
    return TrainerProgressRow(
      trainerUserId: json['trainerUserId'] as String? ?? '',
      trainerName: json['trainerName'] as String? ?? 'Trainer',
      assignedActiveClients: GymDashboardToday._parseInt(json['assignedActiveClients']),
      clientCheckInRate7dPercent: (json['clientCheckInRate7dPercent'] as num?)?.toDouble(),
      avgSessionPackUtilizationPercent:
          (json['avgSessionPackUtilizationPercent'] as num?)?.toDouble(),
    );
  }
}

/// Data from `GET /gyms/:gymId/dashboard/progress` — attendance/session-based
/// engagement proxy, not literal workout/diet progress (see backend doc comment).
class GymProgressOverview {
  final int activeMembers;
  final int inactiveMembers;
  final double? activeMemberRate7dPercent;
  final List<TrainerProgressRow> byTrainer;
  final String? definition;

  const GymProgressOverview({
    this.activeMembers = 0,
    this.inactiveMembers = 0,
    this.activeMemberRate7dPercent,
    this.byTrainer = const [],
    this.definition,
  });

  factory GymProgressOverview.fromJson(Map<String, dynamic> json) {
    final overall = json['overall'] as Map<String, dynamic>? ?? {};
    final trainers = json['byTrainer'] as List? ?? [];
    return GymProgressOverview(
      activeMembers: GymDashboardToday._parseInt(overall['activeMembers']),
      inactiveMembers: GymDashboardToday._parseInt(overall['inactiveMembers']),
      activeMemberRate7dPercent: (overall['activeMemberRate7dPercent'] as num?)?.toDouble(),
      byTrainer: trainers
          .map((e) => TrainerProgressRow.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      definition: json['definition'] as String?,
    );
  }
}

/// Data from `GET /gyms/:gymId/dashboard/subscription-usage`.
class GymSubscriptionUsage {
  final int totalMembers;
  final int free;
  final int trialFull;
  final int trialLimited;
  final int premium;

  const GymSubscriptionUsage({
    this.totalMembers = 0,
    this.free = 0,
    this.trialFull = 0,
    this.trialLimited = 0,
    this.premium = 0,
  });

  factory GymSubscriptionUsage.fromJson(Map<String, dynamic> json) {
    final byTier = json['byTier'] as Map<String, dynamic>? ?? {};
    return GymSubscriptionUsage(
      totalMembers: GymDashboardToday._parseInt(json['totalMembers']),
      free: GymDashboardToday._parseInt(byTier['FREE']),
      trialFull: GymDashboardToday._parseInt(byTier['TRIAL_FULL']),
      trialLimited: GymDashboardToday._parseInt(byTier['TRIAL_LIMITED']),
      premium: GymDashboardToday._parseInt(byTier['PREMIUM']),
    );
  }
}
