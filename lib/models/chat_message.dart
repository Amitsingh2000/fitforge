/// A message inside a thread — REST-persisted via
/// `GET/POST /gyms/:gymId/chat/threads/:id/messages`, and also the shape pushed
/// live over Socket.IO (`newMessage` event).
///
/// Uses `senderId` so the UI can distinguish mine vs theirs. `meta` preserves
/// any extra socket payload fields that don't map to typed members.
class ChatMessage {
  final String id;
  final String threadId;
  final String senderId;
  final String? senderName;
  final String? senderAvatarUrl;

  /// `TEXT` | `WORKOUT_PLAN_REF` | `DIET_PLAN_REF`.
  final String type;
  final String body;

  /// Present when [type] == `WORKOUT_PLAN_REF`.
  final String? refWorkoutPlanId;

  /// Present when [type] == `DIET_PLAN_REF`.
  final String? refDietPlanId;
  final DateTime? createdAt;

  /// Raw additional payload from socket live events.
  final Map<String, dynamic>? meta;

  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    this.senderName,
    this.senderAvatarUrl,
    this.type = 'TEXT',
    this.body = '',
    this.refWorkoutPlanId,
    this.refDietPlanId,
    this.createdAt,
    this.meta,
  });

  bool get isWorkoutRef => type == 'WORKOUT_PLAN_REF';
  bool get isDietRef => type == 'DIET_PLAN_REF';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final senderRaw = json['sender'] as Map?;
    return ChatMessage(
      id: json['id'] as String? ?? '',
      threadId: json['threadId'] as String? ?? '',
      senderId: json['senderId'] as String? ??
          senderRaw?['id'] as String? ??
          '',
      senderName: json['senderName'] as String? ??
          (senderRaw != null
              ? '${senderRaw['firstName'] ?? ''} ${senderRaw['lastName'] ?? ''}'.trim()
              : null),
      senderAvatarUrl:
          json['senderAvatarUrl'] as String? ?? senderRaw?['avatarUrl'] as String?,
      type: json['type'] as String? ?? 'TEXT',
      body: json['body'] as String? ?? json['content'] as String? ?? '',
      refWorkoutPlanId: json['refWorkoutPlanId'] as String?,
      refDietPlanId: json['refDietPlanId'] as String?,
      createdAt: _date(json['createdAt'] ?? json['sentAt'] ?? json['timestamp']),
      meta: json,
    );
  }

  /// Body for `POST .../threads/:id/messages`.
  Map<String, dynamic> toSendPayload() {
    return {
      'type': type,
      if (body.isNotEmpty) 'body': body,
      if (refWorkoutPlanId != null) 'refWorkoutPlanId': refWorkoutPlanId,
      if (refDietPlanId != null) 'refDietPlanId': refDietPlanId,
    };
  }

  static DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
}

/// Live typing indicator pushed over Socket.IO (`typing` / `stopTyping`).
class ChatTypingEvent {
  final String threadId;
  final String userId;
  final String? name;
  final bool typing;

  const ChatTypingEvent({
    required this.threadId,
    required this.userId,
    this.name,
    required this.typing,
  });

  factory ChatTypingEvent.fromJson(Map<String, dynamic> json) {
    return ChatTypingEvent(
      threadId: json['threadId'] as String? ?? '',
      userId: json['userId'] as String? ?? json['senderId'] as String? ?? '',
      name: json['name'] as String? ?? json['userName'] as String?,
      typing: json['typing'] as bool? ?? true,
    );
  }
}

/// Read receipt pushed over Socket.IO (`read` event).
class ChatReadEvent {
  final String threadId;
  final String userId;
  final DateTime? readAt;

  const ChatReadEvent({
    required this.threadId,
    required this.userId,
    this.readAt,
  });

  factory ChatReadEvent.fromJson(Map<String, dynamic> json) {
    return ChatReadEvent(
      threadId: json['threadId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      readAt: json['readAt'] is String ? DateTime.tryParse(json['readAt']) : null,
    );
  }
}