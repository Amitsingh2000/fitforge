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
