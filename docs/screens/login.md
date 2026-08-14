# Screen: Login

- **File:** `lib/auth/screens/login_screen.dart`
- **Route:** `/login` (deep-linkable) — first stop for the member portal
- **Entry path:** `main.dart` `_AppEntry` → routes to `/login` when no valid session

## Screen Information

Standard email/password login plus Google OAuth. On success the user is routed per their
roles (member dashboard, gym owner dashboard, trainer dashboard, or admin if super-admin),
and to onboarding if their member profile is incomplete.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Email | Text | Non-empty; contains `@` | `POST /auth/login.email` |
| Password | Text | Non-empty | `POST /auth/login.password` |
| Continue with Google | Button | — | External `GET /auth/google` |

## API Flow

```
Login → POST /auth/login {email, password}
      → store accessToken + refreshToken (memory + secure storage)
      → GET /users/me  (role routing)
      → route: isSuperAdmin → /settings (admin)
               has gymMemberships → /gym-owner-dashboard (GYM_OWNER/GYM_MANAGER/FRONT_DESK)
                 or /trainer-dashboard (TRAINER) or /dashboard (MEMBER)
               else no gyms + hasMemberProfile → /dashboard (member w/o gym)
               else no member profile → /onboarding
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Tap "Login" | `POST /auth/login` → `GET /users/me` | Via `AuthNotifier._performLogin` |
| Tap "Continue with Google" | `url_launcher` → `GET /auth/google` (external browser) | Callback `fitforge://oauth/callback?accessToken=…&refreshToken=…` handled by `_AppEntry` deep-link listener |
| Tap "Forgot Password?" | — | Navigation to `/forgot-password` |
| Tap "Don't have an account?" | — | Navigation to `/register` |
| "New to FitForge? Download the app" (web) | — | In-app only; no web handling |

## Database

Reads: Users (for role routing). Writes: none directly.

## Validation / Error Handling

- Client: empty email/password → inline "Please enter your email/password".
- Server errors: `{message}` shown in a SnackBar; non-401 unexpected failures also surface
  in the SnackBar.
- OAuth errors (bad state): SnackBar "Sign-in failed. Please try again."
- See `docs/authentication.md` for the full auth/session lifecycle.

## Links

`docs/apis/authentication.md`, `docs/screens/register.md`, `docs/screens/onboarding.md`,
`docs/screens/gym-owner-login.md`, `docs/screens/trainer-login.md`.