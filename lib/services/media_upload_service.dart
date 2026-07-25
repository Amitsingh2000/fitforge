import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

/// Shared 3-step upload flow used everywhere the backend takes a file URL
/// (avatar, trainer photo/certification, gym logo/UPI QR, progress/meal
/// photos): `POST /media/presign-upload` → PUT the bytes directly to the
/// returned signed URL → hand the returned `publicUrl` to whichever endpoint
/// expects it.
class MediaUploadService {
  final Dio dio;
  MediaUploadService(this.dio);

  /// Checks whether media storage is configured server-side. Callers should
  /// hide upload UI when this is false rather than let the presign call fail.
  Future<bool> isStorageConfigured() async {
    try {
      final res = await dio.get('/media/status');
      if (res.data is Map) return res.data['configured'] as bool? ?? false;
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Uploads a local file for the given [purpose] (one of the backend's
  /// `MediaPurpose` enum values, e.g. `AVATAR`, `TRAINER_PHOTO`,
  /// `TRAINER_CERTIFICATION`, `GYM_LOGO`, `GYM_UPI_QR`, `PROGRESS_PHOTO`,
  /// `MEAL_PHOTO`, `TRAINER_INTRO_VIDEO`, `MEMBER_ID_PROOF`) and returns the
  /// public URL to submit to the actual target endpoint.
  Future<String> uploadFile({
    required File file,
    required String purpose,
    required String contentType,
  }) async {
    final sizeBytes = await file.length();

    final presignRes = await dio.post('/media/presign-upload', data: {
      'purpose': purpose,
      'contentType': contentType,
      'sizeBytes': sizeBytes,
    });
    final presign = Map<String, dynamic>.from(presignRes.data as Map);
    final uploadUrl = presign['uploadUrl'] as String? ?? presign['url'] as String?;
    final publicUrl = presign['publicUrl'] as String?;
    if (uploadUrl == null || publicUrl == null) {
      throw Exception('Upload could not be prepared — storage may not be configured.');
    }

    final bytes = await file.readAsBytes();
    // Plain Dio instance: this is a pre-signed storage URL, not our API — it
    // must not carry our Bearer token or go through our interceptor chain.
    final uploadDio = Dio();
    await uploadDio.put(
      uploadUrl,
      data: bytes,
      options: Options(
        headers: {'Content-Type': contentType},
        contentType: contentType,
      ),
    );

    return publicUrl;
  }
}

final mediaUploadServiceProvider = Provider<MediaUploadService>((ref) {
  return MediaUploadService(ref.read(dioProvider));
});
