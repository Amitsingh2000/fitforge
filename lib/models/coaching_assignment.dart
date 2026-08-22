class CoachingTrainer {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final List<String> specializations;
  final int? experienceYears;
  final String? verificationStatus;

  const CoachingTrainer({
    required this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.specializations = const [],
    this.experienceYears,
    this.verificationStatus,
  });

  factory CoachingTrainer.fromJson(Map<String, dynamic> json) {
    final profile = json['trainerProfile'] as Map?;
    return CoachingTrainer(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: profile?['bio'] as String?,
      specializations: (profile?['specializations'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      experienceYears: (profile?['experienceYears'] as num?)?.toInt(),
      verificationStatus: profile?['verificationStatus'] as String?,
    );
  }

  String get displayName =>
      fullName ??
      [firstName, lastName].where((s) => s != null && s.isNotEmpty).join(' ');
}

/// From `GET /members/me/coaching` — null when no assignment.
class CoachingAssignment {
  final String id;
  final String memberId;
  final String trainerId;
  final String status;
  final DateTime? assignedAt;
  final CoachingTrainer? trainer;

  const CoachingAssignment({
    required this.id,
    required this.memberId,
    required this.trainerId,
    this.status = 'ACTIVE',
    this.assignedAt,
    this.trainer,
  });

  factory CoachingAssignment.fromJson(Map<String, dynamic> json) {
    return CoachingAssignment(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      trainerId: json['trainerId'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      assignedAt: json['assignedAt'] is String
          ? DateTime.tryParse(json['assignedAt'] as String)
          : null,
      trainer: json['trainer'] is Map
          ? CoachingTrainer.fromJson(
              Map<String, dynamic>.from(json['trainer'] as Map),
            )
          : null,
    );
  }
}
