/// `GET/PATCH /trainers/me/profile` — a trainer's own onboarding profile.
class TrainerProfile {
  final String? bio;
  final List<String> specializations;
  final int? experienceYears;
  final String? introVideoUrl;
  final List<String> photoUrls;
  final String verificationStatus; // UNVERIFIED | PENDING | VERIFIED | REJECTED
  final List<TrainerCertification> certifications;

  const TrainerProfile({
    this.bio,
    this.specializations = const [],
    this.experienceYears,
    this.introVideoUrl,
    this.photoUrls = const [],
    this.verificationStatus = 'UNVERIFIED',
    this.certifications = const [],
  });

  bool get isVerified => verificationStatus == 'VERIFIED';

  factory TrainerProfile.fromJson(Map<String, dynamic> json) {
    final certs = json['certifications'] as List?;
    return TrainerProfile(
      bio: json['bio'] as String?,
      specializations: (json['specializations'] as List?)?.map((e) => e.toString()).toList() ?? [],
      experienceYears: json['experienceYears'] as int?,
      introVideoUrl: json['introVideoUrl'] as String?,
      photoUrls: (json['photoUrls'] as List?)?.map((e) => e.toString()).toList() ?? [],
      verificationStatus: json['verificationStatus'] as String? ?? 'UNVERIFIED',
      certifications: certs
              ?.map((e) => TrainerCertification.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }
}

class TrainerCertification {
  final String id;
  final String title;
  final String? issuer;
  final String fileUrl;
  final String verificationStatus; // PENDING | VERIFIED | REJECTED
  final String? rejectionReason;
  final DateTime? uploadedAt;

  const TrainerCertification({
    required this.id,
    required this.title,
    this.issuer,
    required this.fileUrl,
    this.verificationStatus = 'PENDING',
    this.rejectionReason,
    this.uploadedAt,
  });

  factory TrainerCertification.fromJson(Map<String, dynamic> json) {
    return TrainerCertification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      issuer: json['issuer'] as String?,
      fileUrl: json['fileUrl'] as String? ?? '',
      verificationStatus: json['verificationStatus'] as String? ?? 'PENDING',
      rejectionReason: json['rejectionReason'] as String?,
      uploadedAt: json['uploadedAt'] != null ? DateTime.tryParse(json['uploadedAt'] as String) : null,
    );
  }
}
