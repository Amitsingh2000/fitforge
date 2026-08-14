# API Module: External Integrations

Sources: `lib/services/api_client.dart`, `lib/services/media_upload_service.dart`, auth &
login screens, communications screen. These are not Dio calls to the FitOS backend — they
leave the app (browser / external apps / raw HTTP).

## 1. Google OAuth — GET /auth/google

- Triggered by Login screen "Continue with Google" (`url_launcher`).
- Opens `https://fitos-backend-55g6.onrender.com/api/v1/auth/google` in the system browser.
- Backend redirects to the app deep link after OAuth:
  `fitforge://oauth/callback?accessToken=<JWT>&refreshToken=<JWT>`
- Handled by the `app_links` listener in `main.dart` (`_AppEntry`): tokens are stored, the
  session is restored (`GET /users/me`), and the user is routed to their dashboard.
- Note: the `/auth/google` URL itself is opened as a **plain HTTP request via
  `url_launcher`**, not through the Dio interceptor — no bearer token, no envelope.

## 2. WhatsApp send — wa.me links

- Communications screen "Send via WhatsApp": `url_launcher` with `LaunchMode.externalApplication`
  on `communication.waLink` (backend-provided `https://wa.me/…?text=…`).
- Not an API call from the app; the backend logs the attempt, the front desk confirms via
  `POST /gyms/:gymId/communications/:commId/mark-sent`.

## 3. Presigned object-storage upload — PUT <uploadUrl>

- Step 2 of the media flow (see `apis/media.md`): raw bytes PUT to the storage provider's
  signed URL using a plain `Dio()` — deliberately bypasses the API's bearer token + envelope
  (the storage domain is not the API host).
- `uploadUrl` and `publicUrl` come from `POST /media/presign-upload`.

## 4. Deep links (app_links) — inbound, not outbound

| Link | Handler | Result |
|---|---|---|
| `fitforge://oauth/callback?accessToken=…&refreshToken=…` | `_AppEntry` | Store tokens → `GET /users/me` → route to dashboard |
| `fitforge://<host>/verify-email?token=…` | Email Verification screen | Auto-fills and submits `POST /auth/verify-email` |
| `fitforge://<host>/reset-password?token=…` | Reset Password screen | Auto-fills the token field |

## External systems referenced (no direct calls)

- Swagger docs: `https://fitos-backend-55g6.onrender.com/docs` (OpenAPI:
  `…/docs-json`).
- Storage provider (S3-compatible) for avatars/logos/certificates — configured server-side.
- Email/SMS providers for `POST /auth/forgot-password`, `POST /auth/reset-password`, and
  `POST /gyms/:gymId/communications/announce` — orchestrated by the backend.

## Entities

No app-side persistence; tokens flow through `flutter_secure_storage`
(`fitforge_access_token`, `fitforge_refresh_token`).