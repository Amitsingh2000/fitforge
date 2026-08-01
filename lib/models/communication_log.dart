/// Represents a communication log entry in the gym's outbox.
///
/// Source: `GET /gyms/:gymId/communications`.
/// WhatsApp messages are delivered as `wa.me` tap-to-send deep links —
/// the front desk taps to send from the gym's own WhatsApp, then confirms
/// with `/:id/mark-sent`. Email delivers automatically. SMS/Push are logged-only.
class CommunicationLog {
  final String id;
  final String recipientUserId;
  final String recipientName;
  final String? recipientPhone;
  final String channel; // EMAIL | WHATSAPP | SMS | PUSH
  final String messageType; // EXPIRY_REMINDER | DUES_REMINDER | ABSENCE | BIRTHDAY | RECEIPT | ANNOUNCEMENT
  final String? subject;
  final String? body;
  final String? waLink; // wa.me deep-link for WhatsApp channel
  final DateTime? sentAt;
  final DateTime? markedSentAt;
  final double estimatedCostInr;
  final bool isPending; // WhatsApp queued but not yet manually sent

  const CommunicationLog({
    required this.id,
    required this.recipientUserId,
    required this.recipientName,
    this.recipientPhone,
    required this.channel,
    required this.messageType,
    this.subject,
    this.body,
    this.waLink,
    this.sentAt,
    this.markedSentAt,
    this.estimatedCostInr = 0,
    this.isPending = false,
  });

  factory CommunicationLog.fromJson(Map<String, dynamic> json) {
    final recipientMap = json['recipient'] as Map<String, dynamic>?;
    final firstName = recipientMap?['firstName'] as String? ?? '';
    final lastName = recipientMap?['lastName'] as String? ?? '';
    final recipientName = json['recipientName'] as String? ??
        (recipientMap != null ? '$firstName $lastName'.trim() : 'Unknown');

    return CommunicationLog(
      id: json['id'] as String? ?? '',
      recipientUserId:
          json['recipientUserId'] as String? ?? recipientMap?['id'] as String? ?? '',
      recipientName: recipientName.isNotEmpty ? recipientName : 'Unknown',
      recipientPhone: json['recipientPhone'] as String? ??
          recipientMap?['phone'] as String?,
      channel: json['channel'] as String? ?? 'WHATSAPP',
      messageType: json['messageType'] as String? ??
          json['type'] as String? ?? 'ANNOUNCEMENT',
      subject: json['subject'] as String?,
      body: json['body'] as String?,
      waLink: json['waLink'] as String? ?? json['whatsappLink'] as String?,
      sentAt: _tryParseDate(json['sentAt']),
      markedSentAt: _tryParseDate(json['markedSentAt']),
      estimatedCostInr: _toDouble(json['estimatedCostInr']),
      isPending: json['isPending'] as bool? ??
          (json['markedSentAt'] == null && json['channel'] == 'WHATSAPP'),
    );
  }

  String get channelLabel => switch (channel) {
        'EMAIL' => 'Email',
        'WHATSAPP' => 'WhatsApp',
        'SMS' => 'SMS',
        'PUSH' => 'Push',
        _ => channel,
      };

  String get messageTypeLabel => switch (messageType) {
        'EXPIRY_REMINDER' => 'Expiry Reminder',
        'DUES_REMINDER' => 'Dues Reminder',
        'ABSENCE' => 'Absence Alert',
        'BIRTHDAY' => 'Birthday',
        'RECEIPT' => 'Receipt',
        'ANNOUNCEMENT' => 'Announcement',
        _ => messageType,
      };

  static DateTime? _tryParseDate(dynamic val) {
    if (val == null) return null;
    if (val is String) return DateTime.tryParse(val);
    return null;
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0;
  }
}
