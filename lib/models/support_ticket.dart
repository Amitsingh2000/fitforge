/// Represents a Gym Owner support ticket.
/// Source: `POST/GET /gyms/:gymId/support`
class SupportTicket {
  final String id;
  final String gymId;
  final String subject;
  final String description;
  final String status; // OPEN | IN_PROGRESS | RESOLVED | CLOSED
  final String priority; // LOW | MEDIUM | HIGH | URGENT
  final DateTime createdAt;
  final String? resolutionNotes;

  const SupportTicket({
    required this.id,
    required this.gymId,
    required this.subject,
    required this.description,
    this.status = 'OPEN',
    this.priority = 'MEDIUM',
    required this.createdAt,
    this.resolutionNotes,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      gymId: json['gymId'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
      priority: json['priority'] as String? ?? 'MEDIUM',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      resolutionNotes: json['resolutionNotes'] as String? ?? json['resolution'] as String?,
    );
  }
}
