/// An in-app alert from `GET /trainers/me/notifications`.
class TrainerNotification {
  final String id;

  /// e.g. `TRAINER_NEW_MESSAGE`, `TRAINER_NEW_CLIENT_ASSIGNED`.
  final String type;
  final String? title;
  final String body;
  final bool read;
  final DateTime? readAt;
  final DateTime? createdAt;

  /// Arbitrary payload the backend attaches (member id, thread id, ...).
  final Map<String, dynamic>? payload;

  const TrainerNotification({
    required this.id,
    required this.type,
    this.title,
    required this.body,
    this.read = false,
    this.readAt,
    this.createdAt,
    this.payload,
  });

  bool get isUnread => !read;

  factory TrainerNotification.fromJson(Map<String, dynamic> json) {
    final readAt = _date(json['readAt']);
    return TrainerNotification(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ??
          json['templateType'] as String? ??
          '',
      title: json['title'] as String? ?? json['subject'] as String?,
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      read: json['read'] as bool? ?? readAt != null,
      readAt: readAt,
      createdAt: _date(json['createdAt'] ?? json['sentAt']),
      payload: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
    );
  }

  static DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
}