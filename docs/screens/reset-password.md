# Screen: Reset Password

- **File:** `lib/auth/screens/reset_password_screen.dart`
- **Route:** `/reset-password` (deep-linkable with `?token=…`)

## Screen Information

Sets a new password using a one-time reset token. The token can arrive via the
`fitforge://<host>/reset-password?token=…` deep link (auto-filled) or be pasted manually.
Uses a **direct Dio call** (`reset_password_screen.dart:98`).

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Token | Text | Non-empty (auto-filled from deep link) | `POST /auth/reset-password.token` |
| New Password | Text | ≥ 8 chars | `POST /auth/reset-password.newPassword` |
| Confirm Password | Text | Matches new password | client-side only |

## API Flow

```
Submit → POST /auth/reset-password {token, newPassword}
       → success: success screen → login
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Tap "Reset Password" | `POST /auth/reset-password` | Direct `dio.post`; `newPassword` sent untrimmed |
| "Try Again" | — | Re-shows the form |

## Database

Writes: none directly (backend rotates the password + invalidates the token).

## Validation / Error Handling

- Empty token → SnackBar; password < 8 or mismatch → SnackBar.
- Server `{message}` (e.g. token expired/invalid) → SnackBar.

## Links

`docs/apis/authentication.md`, `docs/screens/forgot-password.md`.