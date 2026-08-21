/// A chat thread from `GET /gyms/:gymId/chat/threads`.
///
/// `POST .../chat/threads { otherUserId }` get-or-creates and returns the same
/// shape. Threads are created between exactly two users (get-or-create keyed on
/// the other party), so the client surfaces the counterpart convenience fields
/// ([otherUser...]).
class ChatThread {
  final String id;
  final String? gymId;
  final List<ChatParticipant> participants;

  /// Convenience fields for the two-person thread case.
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserAvatarUrl;

  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime? createdAt;

  const ChatThread({
    required this.id,
    this.gymId,
    this.participants = const [],
    this.otherUserId,
    this.otherUserName,
    this.otherUserAvatarUrl,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.createdAt,
  });

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    final participantsRaw = json['participants'] as List?;
    final participants = (participantsRaw ?? [])
        .whereType<Map>()
        .map((e) => ChatParticipant.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final other =
        participants.isNotEmpty ? participants.first : null;

    return ChatThread(
      id: json['id'] as String? ?? '',
      gymId: json['gymId'] as String?,
      participants: participants,
      otherUserId: json['otherUserId'] as String? ??
          json['userId'] as String? ??
          json['memberId'] as String? ??
          (json['member'] as Map?)?['id'] as String? ??
          other?.userId,
      otherUserName: json['otherUserName'] as String? ??
          (json['member'] as Map?)?['fullName'] as String? ??
          other?.name,
      otherUserAvatarUrl:
          json['otherUserAvatarUrl'] as String? ?? other?.avatarUrl,
      lastMessagePreview: json['lastMessagePreview'] as String? ??
          json['lastMessage']?['body'] as String?,
      lastMessageAt: _date(json['lastMessageAt'] ??
          json['lastActivityAt'] ??
          json['updatedAt']),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      createdAt: _date(json['createdAt']),
    );
  }

  static DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
}

/// One participant inside a [ChatThread].
class ChatParticipant {
  final String userId;
  final String? name;
  final String? avatarUrl;
  final String? role;
  final DateTime? lastReadAt;

  const ChatParticipant({
    required this.userId,
    this.name,
    this.avatarUrl,
    this.role,
    this.lastReadAt,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    final userRaw = json['user'] as Map?;
    return ChatParticipant(
      userId: json['userId'] as String? ??
          json['id'] as String? ??
          userRaw?['id'] as String? ??
          '',
      name: json['name'] as String? ??
          (userRaw != null
              ? '${userRaw['firstName'] ?? ''} ${userRaw['lastName'] ?? ''}'.trim()
              : null),
      avatarUrl: json['avatarUrl'] as String? ?? userRaw?['avatarUrl'] as String?,
      role: json['role'] as String?,
      lastReadAt: _date(json['lastReadAt']),
    );
  }

  static DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
}