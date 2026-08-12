/// An owner-facing in-app alert from `GET /gyms/:gymId/dashboard/notifications`.
class OwnerNotification {
  final String id;
  final String templateType;
  final String? subject;
  final String body;
  final DateTime? readAt;
  final DateTime? createdAt;

  const OwnerNotification({
    required this.id,
    required this.templateType,
    this.subject,
    required this.body,
    this.readAt,
    this.createdAt,
  });

  bool get isUnread => readAt == null;

  factory OwnerNotification.fromJson(Map<String, dynamic> json) {
    return OwnerNotification(
      id: json['id'] as String? ?? '',
      templateType: json['templateType'] as String? ?? '',
      subject: json['subject'] as String?,
      body: json['body'] as String? ?? '',
      readAt: _tryParseDate(json['readAt']),
      createdAt: _tryParseDate(json['createdAt']),
    );
  }

  static DateTime? _tryParseDate(dynamic val) {
    if (val is String) return DateTime.tryParse(val);
    return null;
  }
}
