/// Represents a fitness CRM lead in the gym's pipeline.
///
/// Source: `POST/GET/PATCH /gyms/:gymId/leads` and `/leads/:id/convert`.
/// Sources: WALK_IN | PHONE | INSTAGRAM | WEBSITE.
/// Stages: NEW → CONTACTED → INTERESTED → CONVERTED | LOST.
class GymLead {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String source; // WALK_IN | PHONE | INSTAGRAM | WEBSITE
  final String stage; // NEW | CONTACTED | INTERESTED | CONVERTED | LOST
  final String? assigneeId;
  final String? assigneeName;
  final String? notes;
  final String? convertedUserId;
  final DateTime? createdAt;
  final DateTime? followUpAt;

  const GymLead({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.source,
    required this.stage,
    this.assigneeId,
    this.assigneeName,
    this.notes,
    this.convertedUserId,
    this.createdAt,
    this.followUpAt,
  });

  factory GymLead.fromJson(Map<String, dynamic> json) {
    final assigneeMap = json['assignee'] as Map<String, dynamic>?;
    final assigneeFirstName = assigneeMap?['firstName'] as String? ?? '';
    final assigneeLastName = assigneeMap?['lastName'] as String? ?? '';
    final assigneeName = assigneeMap != null
        ? '$assigneeFirstName $assigneeLastName'.trim()
        : json['assigneeName'] as String?;

    return GymLead(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      source: json['source'] as String? ?? 'WALK_IN',
      stage: json['stage'] as String? ?? 'NEW',
      assigneeId: json['assigneeId'] as String? ?? assigneeMap?['id'] as String?,
      assigneeName: assigneeName?.isNotEmpty == true ? assigneeName : null,
      notes: json['notes'] as String?,
      convertedUserId: json['convertedUserId'] as String?,
      createdAt: _tryParseDate(json['createdAt']),
      followUpAt: _tryParseDate(json['followUpAt']),
    );
  }

  bool get isConverted => stage == 'CONVERTED' || convertedUserId != null;

  String get sourceLabel => switch (source) {
        'WALK_IN' => 'Walk-in',
        'PHONE' => 'Phone',
        'INSTAGRAM' => 'Instagram',
        'WEBSITE' => 'Website',
        _ => source,
      };

  String get stageLabel => switch (stage) {
        'NEW' => 'New',
        'CONTACTED' => 'Contacted',
        'INTERESTED' => 'Interested',
        'CONVERTED' => 'Converted',
        'LOST' => 'Lost',
        _ => stage,
      };

  static DateTime? _tryParseDate(dynamic val) {
    if (val == null) return null;
    if (val is String) return DateTime.tryParse(val);
    return null;
  }
}
