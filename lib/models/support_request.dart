/// A support request from `POST/GET /gyms/:gymId/support`.
class SupportRequest {
  final String id;
  final String category; // 'BILLING' | 'TECHNICAL' | 'ACCOUNT' | 'OTHER'
  final String subject;
  final String message;
  final String status; // 'OPEN' | 'IN_PROGRESS' | 'RESOLVED'
  final String? resolutionNotes;
  final DateTime? createdAt;

  const SupportRequest({
    required this.id,
    required this.category,
    required this.subject,
    required this.message,
    this.status = 'OPEN',
    this.resolutionNotes,
    this.createdAt,
  });

  factory SupportRequest.fromJson(Map<String, dynamic> json) {
    return SupportRequest(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'OTHER',
      subject: json['subject'] as String? ?? '',
      message: json['message'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
      resolutionNotes: json['resolutionNotes'] as String?,
      createdAt: _tryParseDate(json['createdAt']),
    );
  }

  static DateTime? _tryParseDate(dynamic val) {
    if (val is String) return DateTime.tryParse(val);
    return null;
  }
}
