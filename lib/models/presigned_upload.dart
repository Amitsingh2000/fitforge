/// Response from `POST /media/presign-upload`.
///
/// Flow: call presign → PUT file bytes to [uploadUrl] with [requiredHeaders]
/// → submit [publicUrl] to the endpoint that expects the file.
class PresignedUpload {
  final String uploadUrl;
  final String publicUrl;
  final Map<String, String> requiredHeaders;

  const PresignedUpload({
    required this.uploadUrl,
    required this.publicUrl,
    this.requiredHeaders = const {},
  });

  factory PresignedUpload.fromJson(Map<String, dynamic> json) {
    final headersRaw = json['requiredHeaders'];
    Map<String, String> headers = {};
    if (headersRaw is Map) {
      headers = headersRaw.map((k, v) => MapEntry(k.toString(), v.toString()));
    }

    return PresignedUpload(
      uploadUrl: json['uploadUrl'] as String? ?? '',
      publicUrl: json['publicUrl'] as String? ?? '',
      requiredHeaders: headers,
    );
  }
}
