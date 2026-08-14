# Screen: Gym Owner Login

- **File:** `lib/auth/screens/gym_owner_login_screen.dart`
- **Route:** `/gym-owner-login`

## Screen Information

Hybrid screen for gym-owner onboarding. If the email is already a gym owner, it signs in and
goes to the gym owner dashboard. If the email has **no gym membership**, the form
dynamically switches to a "Create Gym" mode (name, city, email, phone) and runs
`POST /gyms` after sign-in.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Email | Text | Non-empty, contains `@` | `POST /auth/login` / `POST /gyms.email` |
| Password | Text | Non-empty | `POST /auth/login.password` |
| Gym Name / City (create mode) | Text | Shown only when the email is not a gym owner | `POST /gyms.{name, city}` |

## API Flow

```
Login → POST /auth/login → GET /users/me
      → user has GYM_OWNER/GYM_MANAGER/FRONT_DESK role?
          YES → POST /auth/logout {refreshToken}  (sign-out the just-created session)
                → GET /users/me once more  (refresh user state after re-login below)
                → POST /auth/login again  (re-login to obtain a fresh session)
                → route /gym-owner-dashboard
          NO  → gym has no memberships → POST /auth/logout, then register flow:
                POST /auth/register {email, password, firstName, lastName}
                → POST /gyms {name, city}  → sets selectedGymProvider
                → route /gym-owner-dashboard
```

> Note: the double login/logout dance refreshes the user record so the backend recognizes
> the freshly created gym membership before routing.

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Tap "Login" (existing owner) | `POST /auth/login` → `GET /users/me` → re-login flow above | — |
| Tap "Login" (new owner) | `POST /auth/register` → `POST /gyms` | Creates account + gym in one flow |
| Tap "Are you a member? Sign in" | — | Navigation to `/login` |
| Tap "Sign Up" | — | Navigation to `/register` |

## Database

Reads: Users (role check). Writes: Gyms, GymMemberships (via backend).

## Validation / Error Handling

- Email/password required inline; email must contain `@`.
- Gym name ≥ 2 chars; city required in create mode.
- Server `{message}` errors → SnackBar.

## Links

`docs/apis/authentication.md`, `docs/apis/gym-management.md`,
`docs/screens/create-gym.md`, `docs/screens/gym-owner-dashboard.md`.