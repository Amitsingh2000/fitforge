/// A single active session (device) from `GET /auth/sessions`.
class UserSession {
  final String id;
  final String? userAgent;
  final DateTime? createdAt;
  final DateTime? lastUsedAt;
  final bool isCurrent;

  const UserSession({
    required this.id,
    this.userAgent,
    this.createdAt,
    this.lastUsedAt,
    this.isCurrent = false,
  });

  factory UserSession.fromJson(Map<String, dynamic> json, {String? currentSessionId}) {
    final id = json['id'] as String? ?? json['_id'] as String? ?? '';
    return UserSession(
      id: id,
      userAgent: json['userAgent'] as String? ?? json['device'] as String?,
      createdAt: _tryParseDate(json['createdAt']),
      lastUsedAt: _tryParseDate(json['lastUsedAt'] ?? json['updatedAt']),
      isCurrent: currentSessionId != null && id == currentSessionId,
    );
  }

  /// Friendly device name derived from userAgent.
  String get deviceName {
    if (userAgent == null || userAgent!.isEmpty) return 'Unknown device';
    // Try to extract meaningful device info
    if (userAgent!.contains('Android')) return 'Android Device';
    if (userAgent!.contains('iPhone') || userAgent!.contains('iOS')) return 'iPhone';
    if (userAgent!.contains('Windows')) return 'Windows PC';
    if (userAgent!.contains('Mac')) return 'Mac';
    if (userAgent!.contains('Linux')) return 'Linux';
    if (userAgent!.length > 40) return '${userAgent!.substring(0, 40)}…';
    return userAgent!;
  }

  /// Relative time since last used, e.g. "2 hours ago".
  String get lastUsedLabel {
    if (lastUsedAt == null) return 'Unknown';
    final diff = DateTime.now().difference(lastUsedAt!);
    if (diff.inMinutes < 2) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
