/// One check-in for a member from `GET /gyms/:gymId/members/:userId/attendance`.
class MemberAttendanceEntry {
  final String id;
  final DateTime attendedOn;

  /// QR | MANUAL | CALENDAR.
  final String checkInMethod;
  final String? note;

  const MemberAttendanceEntry({
    required this.id,
    required this.attendedOn,
    this.checkInMethod = 'MANUAL',
    this.note,
  });

  factory MemberAttendanceEntry.fromJson(Map<String, dynamic> json) {
    return MemberAttendanceEntry(
      id: json['id'] as String? ?? '',
      attendedOn: _date(json['attendedOn'] ?? json['date'] ?? json['checkInAt']) ??
          DateTime.now(),
      checkInMethod:
          json['checkInMethod'] as String? ?? json['method'] as String? ?? 'MANUAL',
      note: json['note'] as String?,
    );
  }

  static DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
}