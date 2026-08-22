/// Member IN_APP notification from `GET /members/me/notifications`.
class MemberNotification {
  final String id;
  final String templateType;
  final String? subject;
  final String body;
  final DateTime? readAt;
  final DateTime? createdAt;

  const MemberNotification({
    required this.id,
    required this.templateType,
    this.subject,
    required this.body,
    this.readAt,
    this.createdAt,
  });

  bool get isUnread => readAt == null;

  factory MemberNotification.fromJson(Map<String, dynamic> json) {
    return MemberNotification(
      id: json['id'] as String? ?? '',
      templateType: json['templateType'] as String? ?? '',
      subject: json['subject'] as String?,
      body: json['body'] as String? ?? '',
      readAt: _tryParse(json['readAt']),
      createdAt: _tryParse(json['createdAt']),
    );
  }

  static DateTime? _tryParse(dynamic val) {
    if (val is String) return DateTime.tryParse(val);
    return null;
  }
}

class MemberNotificationPage {
  final List<MemberNotification> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const MemberNotificationPage({
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 20,
    this.totalPages = 1,
  });

  factory MemberNotificationPage.fromJson(Map<String, dynamic> json) {
    return MemberNotificationPage(
      items: (json['items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => MemberNotification.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
