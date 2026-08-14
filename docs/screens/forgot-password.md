# Screen: Forgot Password

- **File:** `lib/auth/screens/forgot_password_screen.dart`
- **Route:** `/forgot-password`

## Screen Information

Requests a password-reset email. Uses a **direct Dio call** (`forgot_password_screen.dart:53`)
that bypasses the service layer — no bearer token needed, no auto-refresh for `/auth/*`.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Email | Text | Non-empty, contains `@` | `POST /auth/forgot-password.email` |

## API Flow

```
Submit → POST /auth/forgot-password {email}
       → success: success screen (check your inbox)
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Tap "Send Reset Link" | `POST /auth/forgot-password` | Direct `dio.post`, response not parsed |
| Tap "Back to Login" | — | Navigation to `/login` |
| Tap "Try Again" (after failure) | — | Re-shows the form |

## Database

Writes: none directly (backend mails a reset token).

## Validation / Error Handling

- Empty/format email → inline error or SnackBar.
- Server `{message}` → SnackBar; success screen only on request resolution.

## Links

`docs/apis/authentication.md`, `docs/screens/reset-password.md`.