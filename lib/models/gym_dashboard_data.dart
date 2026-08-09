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
      totalCheckIns: _parseInt(json['totalCheckIns'] ?? json['checkIns'] ?? json['checkInsToday']),
      collectionsAmount: _parseInt(json['collectionsAmount'] ?? json['collectionsToday'] ?? json['collections']),
      newJoinsCount: _parseInt(json['newJoinsCount'] ?? json['newJoins'] ?? json['newJoinsToday']),
      expiringSoonCount: _parseInt(json['expiringSoonCount'] ?? json['expiringSoon']),
      totalDuesAmount: _parseInt(json['totalDuesAmount'] ?? json['totalDues'] ?? json['pendingDues']),
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
  final List<dynamic> attendanceTrend;

  const GymDashboardMonthly({
    this.totalRevenue = 0,
    this.activeMembersCount = 0,
    this.renewalsCount = 0,
    this.churnCount = 0,
    this.attendanceTrend = const [],
  });

  factory GymDashboardMonthly.fromJson(Map<String, dynamic> json) {
    return GymDashboardMonthly(
      totalRevenue: GymDashboardToday._parseInt(json['totalRevenue'] ?? json['revenue']),
      activeMembersCount: GymDashboardToday._parseInt(json['activeMembersCount'] ?? json['activeMembers']),
      renewalsCount: GymDashboardToday._parseInt(json['renewalsCount'] ?? json['renewals']),
      churnCount: GymDashboardToday._parseInt(json['churnCount'] ?? json['churn']),
      attendanceTrend: json['attendanceTrend'] as List? ?? [],
    );
  }
}

/// Data from `GET /gyms/:gymId/dashboard/overview`
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
    final rev = json['revenueOverview'] is Map<String, dynamic>
        ? json['revenueOverview'] as Map<String, dynamic>
        : {};

    return GymDashboardOverview(
      totalMembers: GymDashboardToday._parseInt(json['totalMembers']),
      totalTrainers: GymDashboardToday._parseInt(json['totalTrainers']),
      activeMemberships: GymDashboardToday._parseInt(json['activeMemberships']),
      pendingJoinRequests: GymDashboardToday._parseInt(json['pendingJoinRequests']),
      membershipRenewalsDue: GymDashboardToday._parseInt(json['membershipRenewalsDue']),
      revenueTodayInr: GymDashboardToday._parseInt(rev['todayInr'] ?? json['revenueToday']),
      revenueMonthInr: GymDashboardToday._parseInt(rev['monthInr'] ?? json['revenueMonth']),
      unreadNotifications: GymDashboardToday._parseInt(json['unreadNotifications']),
    );
  }
}

/// Data item from `GET /gyms/:gymId/dashboard/growth`
class GrowthPoint {
  final String month;
  final int memberCount;

  const GrowthPoint({required this.month, required this.memberCount});

  factory GrowthPoint.fromJson(Map<String, dynamic> json) {
    return GrowthPoint(
      month: json['month']?.toString() ?? '',
      memberCount: GymDashboardToday._parseInt(json['memberCount'] ?? json['count'] ?? json['members'] ?? json['value']),
    );
  }
}

/// Data from `GET /gyms/:gymId/dashboard/progress`
class GymDashboardProgress {
  final int activeMembers;
  final int inactiveMembers;
  final double checkInRate7dPercent;
  final List<TrainerProgressSummary> byTrainer;

  const GymDashboardProgress({
    this.activeMembers = 0,
    this.inactiveMembers = 0,
    this.checkInRate7dPercent = 0.0,
    this.byTrainer = const [],
  });

  factory GymDashboardProgress.fromJson(Map<String, dynamic> json) {
    final overall = json['overall'] is Map<String, dynamic>
        ? json['overall'] as Map<String, dynamic>
        : json;

    final trainerList = (json['byTrainer'] as List?)
            ?.map((e) => TrainerProgressSummary.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        const [];

    return GymDashboardProgress(
      activeMembers: GymDashboardToday._parseInt(overall['activeMembers']),
      inactiveMembers: GymDashboardToday._parseInt(overall['inactiveMembers']),
      checkInRate7dPercent: (overall['checkInRate7dPercent'] as num?)?.toDouble() ?? 0.0,
      byTrainer: trainerList,
    );
  }
}

class TrainerProgressSummary {
  final String trainerId;
  final String trainerName;
  final double checkInRatePercent;
  final double avgSessionUtilizationPercent;

  const TrainerProgressSummary({
    required this.trainerId,
    required this.trainerName,
    this.checkInRatePercent = 0.0,
    this.avgSessionUtilizationPercent = 0.0,
  });

  factory TrainerProgressSummary.fromJson(Map<String, dynamic> json) {
    return TrainerProgressSummary(
      trainerId: json['trainerId']?.toString() ?? '',
      trainerName: json['trainerName']?.toString() ?? json['name']?.toString() ?? 'Trainer',
      checkInRatePercent: (json['checkInRatePercent'] as num?)?.toDouble() ?? 0.0,
      avgSessionUtilizationPercent: (json['avgSessionUtilizationPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Data from `GET /gyms/:gymId/dashboard/subscription-usage`
class GymSubscriptionUsage {
  final int freeCount;
  final int trialFullCount;
  final int trialLimitedCount;
  final int premiumCount;

  const GymSubscriptionUsage({
    this.freeCount = 0,
    this.trialFullCount = 0,
    this.trialLimitedCount = 0,
    this.premiumCount = 0,
  });

  int get total => freeCount + trialFullCount + trialLimitedCount + premiumCount;

  factory GymSubscriptionUsage.fromJson(Map<String, dynamic> json) {
    return GymSubscriptionUsage(
      freeCount: GymDashboardToday._parseInt(json['FREE'] ?? json['freeCount']),
      trialFullCount: GymDashboardToday._parseInt(json['TRIAL_FULL'] ?? json['trialFullCount']),
      trialLimitedCount: GymDashboardToday._parseInt(json['TRIAL_LIMITED'] ?? json['trialLimitedCount']),
      premiumCount: GymDashboardToday._parseInt(json['PREMIUM'] ?? json['premiumCount']),
    );
  }
}

