# API Module: Authentication & Session

Source: `lib/services/api_client.dart`, `lib/providers/auth_provider.dart`,
`lib/services/member_service.dart` (sessions), auth screens. Backend controller/service
details: **Not found in source code**.

## Common envelope & headers

- All endpoints: `Authorization: Bearer <accessToken>` (except `/auth/login`, `/auth/register`,
  `/auth/forgot-password`, `/auth/reset-password`, `/auth/google` — those either don't need it
  or are pre-auth).
- Response envelope `{success: true, data: ...}` is unwrapped by the interceptor.
- Errors: `{message: string|string[], error?: string}` → normalized to a single string.

## 1. POST /auth/login

Used by: Login, Gym Owner Login, Trainer Login (via `AuthNotifier._performLogin`).

**Request:**

```json
{ "email": "user@example.com", "password": "secret123" }
```

| Field | Type | Required | Source |
|---|---|---|---|
| email | String | Yes | Email field (trimmed) |
| password | String | Yes | Password field (trimmed) |

**Response** (unwrapped `data`):

```json
{ "accessToken": "eyJ...", "refreshToken": "eyJ..." }
```

| Field | Type | Description |
|---|---|---|
| accessToken | String | JWT for `Authorization: Bearer` |
| refreshToken | String | Rotating refresh token (single-use) |

Both tokens are stored in memory + secure storage. Followed by `GET /users/me`.

## 2. POST /auth/register

Used by: Register screen (`AuthNotifier.register`).

**Request:**

```json
{ "email": "user@example.com", "password": "secret123", "firstName": "A", "lastName": "B" }
```

**Response:** same as login — `{accessToken, refreshToken}`.

Client-side pre-validation: all fields required; email contains `@`; password ≥ 8 chars;
confirm password matches.

## 3. POST /auth/logout

Used by: Email Verification, Profile, Gym Owner Profile tab, Trainer Profile tab.

**Request:**

```json
{ "refreshToken": "<stored refresh token>" }
```

Best-effort: failures are swallowed; local session is always cleared.

## 4. POST /auth/refresh

Used by: Dio error interceptor on any 401 (except `/auth/*` endpoints).

**Request:**

```json
{ "refreshToken": "<stored refresh token>" }
```

**Response** (two accepted shapes):

```json
{ "success": true, "data": { "accessToken": "...", "refreshToken": "..." } }
```
or flat
```json
{ "accessToken": "...", "refreshToken": "..." }
```

`refreshToken` in the response is optional — if absent the old one is kept. New tokens update
memory + secure storage, then the original request is retried once. On failure: tokens cleared,
session logged out. A shared in-flight Future deduplicates concurrent refreshes (rotating
tokens are single-use; a second concurrent call would be treated as theft).

## 5. POST /auth/forgot-password

Used by: Forgot Password screen (direct `dio` call, `forgot_password_screen.dart:53`).

**Request:**

```json
{ "email": "user@example.com" }
```

**Response:** not parsed — success inferred from the request resolving.

## 6. POST /auth/reset-password

Used by: Reset Password screen (direct `dio` call, `reset_password_screen.dart:98`).

**Request:**

```json
{ "token": "<reset token from email/deep link>", "newPassword": "newsecret123" }
```

| Field | Type | Required | Source |
|---|---|---|---|
| token | String | Yes | Deep link `?token=` or manual paste |
| newPassword | String | Yes | New password field (untrimmed) |

**Response:** not parsed.

Client-side: token non-empty; new password ≥ 8 chars; confirm matches.

## 7. POST /auth/verify-email

Used by: Email Verification screen (direct `dio` call, auto-triggered via deep link or after
register).

**Request:**

```json
{ "token": "<verification token from deep link>" }
```

**Response:** not parsed.

## 8. POST /auth/resend-verification

Used by: Email Verification screen (direct `dio` call).

**Request:** empty body. Requires the Bearer token (identifies the user).

**Response:** not parsed.

## 9. GET /users/me

Used by: app startup (`tryRestoreSession`), all logins, register, OAuth callback, Edit Profile
(`refreshUser`), Create Gym (`refreshUser`).

**Request:** none. Bearer token required.

**Response** (fields read by `User.fromBackendJson` in `lib/models/user.dart`):

| Field | Type | Description |
|---|---|---|
| id | String | User id |
| email | String | Email |
| firstName / lastName / fullName / name | String | Display name resolution |
| avatarUrl | String? | Avatar |
| phone | String? | Phone |
| isEmailVerified | Boolean | Email verified flag |
| isPhoneVerified | Boolean | Phone verified flag |
| isSuperAdmin | Boolean | Super-admin flag (unlocks admin screens) |
| createdAt | String (ISO date) | Account creation |
| gymMemberships[] | Array | `[{gymId, gymName, role, membershipId/id, status}]` — role strings: GYM_OWNER, GYM_MANAGER, FRONT_DESK, TRAINER, MEMBER |
| memberProfile | Object? | `{onboardingCompletedAt: ...}` — presence/non-null drives `hasMemberProfile` and `isOnboardingComplete` |

## 10. GET /auth/sessions

Used by: Settings screen (`MemberService.getSessions`).

**Request:** none.

**Response:** list of:

| Field | Type | Description |
|---|---|---|
| id / _id | String | Session id |
| userAgent / device | String? | Device description |
| createdAt | ISO date | When session started |
| lastUsedAt / updatedAt | ISO date | Last activity |

Note: the current session's id is not supplied by the screen, so `isCurrent` is always false.

## 11. DELETE /auth/sessions/:sessionId

Used by: Settings screen (`MemberService.deleteSession`).

**Request:** none. `sessionId` from the sessions list.

## 12. POST /auth/logout-all

Used by: Settings screen (`MemberService.logoutAllDevices`).

**Request:** none. Revokes every refresh token for the user.

## 13. GET /auth/google (external)

Used by: Login screen. Opened in an external browser via `url_launcher` — not a Dio call.
Callback: `fitforge://oauth/callback?accessToken=...&refreshToken=...`.

## Backend / database

- Controller, service, repository names: **Not found in source code**.
- Entities: Users, UserSessions, token storage (see `database-overview.md`).
- Live reference: Swagger `https://fitos-backend-55g6.onrender.com/docs`.