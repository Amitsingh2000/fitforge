# Screen: Register

- **File:** `lib/auth/screens/register_screen.dart`
- **Route:** `/register`

## Screen Information

Self-service account creation (member path). After success the user lands on onboarding if
their member profile is incomplete, otherwise on the member dashboard.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| First Name | Text | Non-empty | `POST /auth/register.firstName` |
| Last Name | Text | Non-empty | `POST /auth/register.lastName` |
| Email | Text | Non-empty, contains `@` | `POST /auth/register.email` |
| Password | Text | ≥ 8 chars | `POST /auth/register.password` |
| Confirm Password | Text | Matches password | client-side only |

## API Flow

```
Register → POST /auth/register {email, password, firstName, lastName}
         → store tokens (same as login)
         → GET /users/me  → route by roles (same rules as login)
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Tap "Create Account" | `POST /auth/register` → `GET /users/me` | Via `AuthNotifier.register` |
| Tap "Sign in" | — | Navigation to `/login` |
| Gym owner? / Trainer? | — | Navigation to `/gym-owner-login` / `/trainer-login` |

## Database

Writes: Users (via backend). The backend auto-creates a member profile (empty) so
`User.isOnboardingComplete` starts false → onboarding flow.

## Validation / Error Handling

- Client-side: all required; email contains `@`; password ≥ 8; confirm matches →
  SnackBar.
- Server `{message}` (e.g. duplicate email) → SnackBar; the registration state is reset so
  the user can retry.

## Links

`docs/apis/authentication.md`, `docs/screens/onboarding.md`,
`docs/screens/email-verification.md`.