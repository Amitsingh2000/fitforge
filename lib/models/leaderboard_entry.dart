class LeaderboardEntry {
  final int rank;
  final String userId;
  final String name;
  final String? avatarUrl;
  final int score;
  final int rankChange;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.score = 0,
    this.rankChange = 0,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      score: (json['score'] as num?)?.toInt() ?? 0,
      rankChange: (json['rankChange'] as num?)?.toInt() ?? 0,
    );
  }
}

class MyLeaderboardRank {
  final int rank;
  final String userId;
  final String name;
  final int score;
  final int rankChange;

  const MyLeaderboardRank({
    required this.rank,
    required this.userId,
    required this.name,
    this.score = 0,
    this.rankChange = 0,
  });

  factory MyLeaderboardRank.fromJson(Map<String, dynamic> json) {
    return MyLeaderboardRank(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      rankChange: (json['rankChange'] as num?)?.toInt() ?? 0,
    );
  }
}

/// From `GET /leaderboards`.
class LeaderboardResponse {
  final MyLeaderboardRank? myRank;
  final List<LeaderboardEntry> leaderboard;

  const LeaderboardResponse({
    this.myRank,
    this.leaderboard = const [],
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      myRank: json['myRank'] is Map
          ? MyLeaderboardRank.fromJson(
              Map<String, dynamic>.from(json['myRank'] as Map),
            )
          : null,
      leaderboard: (json['leaderboard'] as List? ?? [])
          .whereType<Map>()
          .map((e) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class Challenge {
  final String id;
  final String title;
  final String? description;
  final String scope;
  final String? gymId;
  final String metric;
  final int targetValue;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int rewardXp;
  final bool joined;
  final int myProgress;

  const Challenge({
    required this.id,
    required this.title,
    this.description,
    this.scope = 'GLOBAL',
    this.gymId,
    this.metric = 'XP',
    this.targetValue = 0,
    this.startsAt,
    this.endsAt,
    this.rewardXp = 0,
    this.joined = false,
    this.myProgress = 0,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      scope: json['scope'] as String? ?? 'GLOBAL',
      gymId: json['gymId'] as String?,
      metric: json['metric'] as String? ?? 'XP',
      targetValue: (json['targetValue'] as num?)?.toInt() ?? 0,
      startsAt: _tryParse(json['startsAt']),
      endsAt: _tryParse(json['endsAt']),
      rewardXp: (json['rewardXp'] as num?)?.toInt() ?? 0,
      joined: json['joined'] as bool? ?? false,
      myProgress: (json['myProgress'] as num?)?.toInt() ?? 0,
    );
  }

  static DateTime? _tryParse(dynamic val) {
    if (val is String) return DateTime.tryParse(val);
    return null;
  }
}
