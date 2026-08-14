# API Module: Media Upload

Source: `lib/services/media_upload_service.dart`, `lib/services/member_service.dart`
(`getMediaStatus`/`presignUpload` — unused variants), `lib/models/presigned_upload.dart`.
Backend controller/service details: **Not found in source code**.

## Upload flow (3 steps)

```
1. POST /media/presign-upload        → {uploadUrl, publicUrl, requiredHeaders}
2. PUT <uploadUrl>  (raw bytes, plain Dio, NO bearer token — storage domain, not the API)
3. Submit publicUrl to the target endpoint (PATCH /users/me, PATCH /gyms/:gymId,
   PATCH /trainers/me/profile, POST /trainers/me/certifications, ...)
```

## 1. GET /media/status

Used by: Gym Settings (`MediaUploadService.isStorageConfigured`) to gate upload UI.
Member-service duplicate (`MemberService.getMediaStatus`) exists but is **unused**.

**Request:** none. Bearer token.

**Response:**

```json
{ "configured": true }
```

`configured` false or any error → callers hide upload controls.

## 2. POST /media/presign-upload

Used by: Edit Profile (avatar), Gym Settings (logo/UPI QR/photos), Trainer Edit Profile
(photos), Trainer Certifications (certification file).

**Request:**

```json
{
  "purpose": "AVATAR",
  "contentType": "image/jpeg",
  "sizeBytes": 245760
}
```

| Field | Type | Required | Source |
|---|---|---|---|
| purpose | String | Yes | Purpose enum value — observed: `AVATAR`, `GYM_LOGO`, `GYM_UPI_QR`, `GYM_PHOTO`, `TRAINER_PHOTO`, `TRAINER_CERTIFICATION` (handoff also lists `PROGRESS_PHOTO`, `MEAL_PHOTO`, `TRAINER_INTRO_VIDEO`, `MEMBER_ID_PROOF`) |
| contentType | String | Yes | From file extension: `image/png`, `image/jpeg`, `application/pdf` |
| sizeBytes | Number | Yes | `file.length()` |

**Response** (parsed by `PresignedUpload.fromJson`):

```json
{
  "uploadUrl": "https://storage.example.com/...?X-Amz-Signature=...",
  "publicUrl": "https://storage.example.com/public/avatar_123.jpg",
  "requiredHeaders": {}
}
```

| Field | Type | Description |
|---|---|---|
| uploadUrl | String | Signed PUT URL (`url` is accepted as fallback) |
| publicUrl | String | Public URL to submit to target endpoints |
| requiredHeaders | Map | Headers for the PUT (not actually applied by the frontend) |

If either URL is missing the service throws `Upload could not be prepared — storage may not
be configured.`

## 3. PUT <uploadUrl> (external storage)

Raw bytes via a **plain `Dio()`** (no interceptor chain, no bearer token — deliberate).

**Request:** body = file bytes; header `Content-Type: <contentType>`.

**Response:** not parsed.

## Entities

Media/storage configuration + object storage (backend). Details: **Not found in source code**.