# FitForge — Authentication & Session Management

All information below is derived from `lib/services/api_client.dart`,
`lib/providers/auth_provider.dart`, `lib/services/token_storage_service.dart` and the auth
screens. Backend controller/service details are not available in this repo.

## 1. Token model

- **Access token** (JWT) — sent as `Authorization: Bearer <token>` on every request by the Dio
  request interceptor (`api_client.dart`).
- **Refresh token** — rotating. **Invalidated after every use.** The backend treats a second
  use of an already-consumed refresh token as theft and revokes all sessions — this is why all
  concurrent 401 handlers share a single in-flight refresh Future.
- Storage: in-memory Riverpod `tokenProvider` / `refreshTokenProvider` (source of truth during
  the session) + persisted in `flutter_secure_storage` under `fitforge_access_token` /
  `fitforge_refresh_token` (web fallback: localStorage).

## 2. Login flow

```
User submits email + password
   │
   ▼
POST /auth/login  {email, password}
   │  → {accessToken, refreshToken}        (envelope-unwrapped)
   ▼
save tokens (memory + secure storage)
   │
   ▼
GET /users/me  (Bearer attached)
   │  → User.fromBackendJson(...)  reads id, email, firstName, lastName, avatarUrl, phone,
   │    isEmailVerified, isPhoneVerified, isSuperAdmin, createdAt, gymMemberships[],
   │    memberProfile.onboardingCompletedAt
   ▼
client-side role gate (UX check only; server enforces real authz on each call)
   • loginAsGymOwner: requires a gymMembership with role GYM_OWNER|GYM_MANAGER|FRONT_DESK
     else "Access denied. You are not registered as a Gym Owner."
   • loginAsTrainer: requires user.role == trainer
   • login (member): no role check
   ▼
route: gymOwner+0 memberships → /create-gym · gymOwner → /gym-owner-dashboard ·
       trainer → /trainer-dashboard · member → /dashboard
```

Endpoints: `POST /auth/login` (payload `{"email", "password"}`),
`GET /users/me` (no payload). Both used by `AuthNotifier._performLogin`
(`lib/providers/auth_provider.dart:107-159`).

## 3. Registration flow

```
POST /auth/register  {email, password, firstName, lastName}
   → {accessToken, refreshToken}
GET /users/me  → User
route: targetRole gymOwner → /create-gym · otherwise → /verify-email
```

Client-side validation before the call: all fields required, email must contain `@`,
password ≥ 8 chars, confirm-password must match (`RegisterScreen`).

## 4. Session restore (cold start)

`_AppEntry` → `tryRestoreSession()` (`auth_provider.dart:43-75`):

1. Read tokens from secure storage; if either missing → `unauthenticated`.
2. Put tokens in memory, call `GET /users/me`.
3. On 401 the interceptor auto-refreshes; if refresh also fails → clear session →
   `unauthenticated`.
4. On network error → `unauthenticated` (logged out; no optimistic retention).

## 5. 401 auto-refresh (interceptor, api_client.dart:120-140)

```
401 received (non /auth/* endpoint, refresh token present)
   ▼
POST /auth/refresh  {refreshToken: <stored>}
   → {data: {accessToken, refreshToken}}   (or flat {accessToken, refreshToken})
   ▼
update memory + secure storage
   ▼
retry original request once with new Bearer token
failure → clear tokens + storage → original 401 propagates (screen shows error)
```

`/auth/*` endpoints never trigger auto-refresh (an expired token during login just fails).

## 6. Logout

`AuthNotifier.logout()` (`auth_provider.dart:251-268`):

1. Best-effort `POST /auth/logout` with `{refreshToken: <stored>}` — revokes the server
   session while the Bearer token is still in memory.
2. Clears local tokens (memory + secure storage), state → `unauthenticated`.

Related: `POST /auth/logout-all` revokes every refresh token (Settings screen);
`DELETE /auth/sessions/:sessionId` revokes one device session.

## 7. Google OAuth

- `LoginScreen` opens `https://fitos-backend-55g6.onrender.com/api/v1/auth/google` in an
  external browser via `url_launcher` (not a Dio call).
- Callback deep link `fitforge://oauth/callback?accessToken=...&refreshToken=...` handled in
  `main.dart:_handleDeepLink` → `handleOAuthCallback` (saves tokens, then `GET /users/me`).

## 8. Email verification & password reset

| Endpoint | Method | Payload | Called from |
|---|---|---|---|
| `/auth/verify-email` | POST | `{token}` | `EmailVerificationScreen` (auto on deep link) |
| `/auth/resend-verification` | POST | — (Bearer auth) | `EmailVerificationScreen` button |
| `/auth/forgot-password` | POST | `{email}` | `ForgotPasswordScreen` |
| `/auth/reset-password` | POST | `{token, newPassword}` | `ResetPasswordScreen` |

Deep links `fitforge://<host>/verify-email?token=...` and
`fitforge://<host>/reset-password?token=...` pre-fill the token.

## 9. Session management (Settings screen)

- `GET /auth/sessions` → list of `UserSession` (`id`/`_id`, `userAgent`/`device`, `createdAt`,
  `lastUsedAt`/`updatedAt`). Note: the current session's id is not passed to the parser, so
  `isCurrent` is always false — the "This device" pill never renders.
- `DELETE /auth/sessions/:sessionId` → revoke one session.
- `POST /auth/logout-all` → revoke all devices.

## 10. Error responses

Error responses are normalized by the interceptor from the backend's shape:

```json
{ "message": "string | string[]", "error": "fallback string" }
```

- `message` array → joined with `", "`.
- Fallback: `error` field, else `"Something went wrong"`.
- Auth screens surface the normalized message via `AuthState.errorMessage` → SnackBar; direct
  Dio screens (forgot/reset/verify) use `DioException.message`.

## 11. Backend details

- Controller/service/repository classes and HTTP status-code lists for these endpoints:
  **Not found in source code** (backend not in this repo). The Swagger docs at
  `https://fitos-backend-55g6.onrender.com/docs` are the live reference.