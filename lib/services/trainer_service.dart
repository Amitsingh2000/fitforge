import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trainer_profile.dart';
import 'api_client.dart';

/// Service layer for Trainer API calls (§1.4 onboarding & verification).
class TrainerService {
  final Dio dio;
  TrainerService(this.dio);

  Future<TrainerProfile> getMyProfile() async {
    final res = await dio.get('/trainers/me/profile');
    return TrainerProfile.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<TrainerProfile> updateMyProfile({
    String? bio,
    List<String>? specializations,
    int? experienceYears,
    String? introVideoUrl,
    List<String>? photoUrls,
  }) async {
    final data = <String, dynamic>{};
    if (bio != null) data['bio'] = bio;
    if (specializations != null) data['specializations'] = specializations;
    if (experienceYears != null) data['experienceYears'] = experienceYears;
    if (introVideoUrl != null && introVideoUrl.isNotEmpty) data['introVideoUrl'] = introVideoUrl;
    if (photoUrls != null) data['photoUrls'] = photoUrls;

    final res = await dio.patch('/trainers/me/profile', data: data);
    return TrainerProfile.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Submit a certification for review. [fileUrl] comes from the shared
  /// media-upload helper (purpose `TRAINER_CERTIFICATION`).
  Future<TrainerCertification> submitCertification({
    required String title,
    String? issuer,
    required String fileUrl,
  }) async {
    final res = await dio.post('/trainers/me/certifications', data: {
      'title': title,
      if (issuer != null && issuer.isNotEmpty) 'issuer': issuer,
      'fileUrl': fileUrl,
    });
    return TrainerCertification.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // ── Super-admin review queue (§1.4 / §8) ──────────────────────────────────

  Future<List<Map<String, dynamic>>> getPendingCertifications() async {
    final res = await dio.get('/trainers/certifications/pending');
    final data = res.data;
    if (data is List) return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<void> reviewCertification(
    String certificationId, {
    required bool approve,
    String? rejectionReason,
  }) async {
    await dio.patch('/trainers/certifications/$certificationId/review', data: {
      'approve': approve,
      if (rejectionReason != null && rejectionReason.isNotEmpty) 'rejectionReason': rejectionReason,
    });
  }
}

/// Riverpod provider for [TrainerService].
final trainerServiceProvider = Provider<TrainerService>((ref) {
  return TrainerService(ref.read(dioProvider));
});
