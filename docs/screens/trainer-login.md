# Screen: Trainer Login

- **File:** `lib/auth/screens/trainer_login_screen.dart`
- **Route:** `/trainer-login`

## Screen Information

Email/password login for trainers. Routes to the trainer dashboard after success. If the
session user is a super-admin, routes to `/settings` instead (admin access point).

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Email | Text | Non-empty, contains `@` | `POST /auth/login.email` |
| Password | Text | Non-empty | `POST /auth/login.password` |

## API Flow

```
Login → POST /auth/login {email, password}
      → store tokens
      → GET /users/me
      → route: isSuperAdmin → /settings
               else → /trainer-dashboard
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Tap "Login" | `POST /auth/login` → `GET /users/me` | — |
| Tap "Sign in as Gym Owner" | — | Navigation to `/gym-owner-login` |
| Tap "Create Account" | — | Navigation to `/register` |

## Database

Reads: Users. Writes: none directly.

## Validation / Error Handling

- Empty fields → inline errors; email must contain `@`.
- Server `{message}` → SnackBar.

## Links

`docs/apis/authentication.md`, `docs/screens/trainer-mock-screens.md`,
`docs/screens/trainer-profile-tab.md`.