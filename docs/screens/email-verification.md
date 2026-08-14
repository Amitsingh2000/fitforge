# Screen: Email Verification

- **File:** `lib/auth/screens/email_verification_screen.dart`
- **Route:** `/verify-email` (deep-linkable with `?token=…`)

## Screen Information

Shown when a freshly registered user has `isEmailVerified == false`. Verifies the email
either by auto-submitting the deep-link token (`fitforge://<host>/verify-email?token=…`) or
via a resend code. Uses **direct Dio calls** that bypass the service layer.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Code / Token | Text | Non-empty (auto-filled from deep link) | `POST /auth/verify-email.token` |

## API Flow

```
Verify → POST /auth/verify-email {token}     (auto-triggered by deep link)
       → GET /users/me                       (refresh isEmailVerified)
       → isEmailVerified? route to dashboard : stay + prompt resend
Resend → POST /auth/resend-verification {}   (empty body; Bearer token identifies user)
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Deep link arrives | `POST /auth/verify-email` (auto) | Listener in `_AppEntry` routes to this screen with the token |
| Tap "Resend Code" | `POST /auth/resend-verification` | Direct `dio.post`, empty body |
| Tap "Logout" | `POST /auth/logout {refreshToken}` | Cleanly exits the unverified session |
| Tap "Continue" (after verified) | `GET /users/me` | Re-checks `isEmailVerified` |

## Database

Writes: none directly (backend sets `isEmailVerified`).

## Validation / Error Handling

- Empty code → SnackBar.
- `POST /auth/verify-email` failure → SnackBar with server message; stays on screen.
- After successful verify, `GET /users/me` confirms the flag before routing.

## Links

`docs/apis/authentication.md`, `docs/screens/register.md`.