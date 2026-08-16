/// One measurement snapshot from `GET /gyms/:gymId/members/:userId/progress-entries`.
///
/// Weight, body measurements and progress photos. Photos are private by default
/// (MediaPurpose.PROGRESS_PHOTO) — display only in trainer/member context.
class ProgressEntry {
  final String id;
  final DateTime? loggedAt;
  final double? weightKg;

  /// Flexible body-part → cm map (e.g. { 'chest': 102.0, 'waist': 84.0 }).
  final Map<String, double> measurements;

  final List<String> photoUrls;
  final String? note;

  const ProgressEntry({
    required this.id,
    this.loggedAt,
    this.weightKg,
    this.measurements = const {},
    this.photoUrls = const [],
    this.note,
  });

  factory ProgressEntry.fromJson(Map<String, dynamic> json) {
    final rawMeasurements = json['measurements'];
    final measurements = <String, double>{};
    if (rawMeasurements is Map) {
      rawMeasurements.forEach((key, value) {
        final numValue = value is num ? value : double.tryParse(value.toString());
        if (numValue != null) measurements[key.toString()] = numValue.toDouble();
      });
    }

    final photos = json['photoUrls'] as List? ?? json['photos'] as List?;

    return ProgressEntry(
      id: json['id'] as String? ?? '',
      loggedAt: _date(json['loggedAt'] ?? json['recordedAt'] ?? json['date']),
      weightKg: (json['weightKg'] as num?)?.toDouble() ??
          (json['weight'] as num?)?.toDouble(),
      measurements: measurements,
      photoUrls: (photos ?? []).map((e) => e.toString()).toList(),
      note: json['note'] as String?,
    );
  }

  static DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
}