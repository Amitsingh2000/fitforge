/// Represents a single attendance entry for a gym member.
///
/// Source: `GET /gyms/:gymId/attendance`.
/// Check-in methods: QR | MANUAL | CALENDAR (backfill).
/// One entry per member per day — re-scans are idempotent.
class AttendanceRecord {
  final String id;
  final String userId;
  final String memberName;
  final String? memberAvatarUrl;
  final DateTime attendedOn;
  final String checkInMethod; // QR | MANUAL | CALENDAR

  const AttendanceRecord({
    required this.id,
    required this.userId,
    required this.memberName,
    this.memberAvatarUrl,
    required this.attendedOn,
    required this.checkInMethod,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final memberMap = json['member'] as Map<String, dynamic>? ??
        json['user'] as Map<String, dynamic>?;

    final rawName = json['memberName'] as String? ??
        (memberMap != null
            ? '${memberMap['firstName'] ?? ''} ${memberMap['lastName'] ?? ''}'.trim()
            : '');

    return AttendanceRecord(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? memberMap?['id'] as String? ?? '',
      memberName: rawName.isNotEmpty ? rawName : 'Member',
      memberAvatarUrl: json['memberAvatarUrl'] as String? ??
          memberMap?['avatarUrl'] as String?,
      attendedOn: _parseDate(json['attendedOn']) ?? DateTime.now(),
      checkInMethod: json['checkInMethod'] as String? ?? 'MANUAL',
    );
  }

  String get methodLabel => switch (checkInMethod) {
        'QR' => 'QR Scan',
        'MANUAL' => 'Manual',
        'CALENDAR' => 'Backfill',
        _ => checkInMethod,
      };

  static DateTime? _parseDate(dynamic val) {
    if (val == null) return null;
    if (val is String) return DateTime.tryParse(val);
    return null;
  }
}

/// Absence alert from `GET /gyms/:gymId/attendance/absence-alerts`.
class AbsenceAlert {
  final String userId;
  final String memberName;
  final int daysSinceLastVisit;
  final DateTime? lastVisitedOn;

  const AbsenceAlert({
    required this.userId,
    required this.memberName,
    required this.daysSinceLastVisit,
    this.lastVisitedOn,
  });

  factory AbsenceAlert.fromJson(Map<String, dynamic> json) {
    return AbsenceAlert(
      userId: json['userId'] as String? ?? '',
      memberName: json['memberName'] as String? ?? 'Unknown',
      daysSinceLastVisit: json['daysSinceLastVisit'] as int? ??
          json['daysSince'] as int? ?? 0,
      lastVisitedOn: _tryParseDate(json['lastVisitedOn'] ?? json['lastVisit']),
    );
  }

  static DateTime? _tryParseDate(dynamic val) {
    if (val == null) return null;
    if (val is String) return DateTime.tryParse(val);
    return null;
  }
}
