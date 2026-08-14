# Screen: Gym Owner — Profile Tab

- **File:** `lib/gym_owner/screens/gym_owner_profile_tab.dart`
- **Route:** Tab within the gym owner shell

## Screen Information

Gym identity + SaaS status: gym info, plan/trial state, and entry to Gym Settings.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Gym info (name, contact) | Read-only | — | `GET /gyms/:gymId` |
| Subscription card (plan, status, trial end) | Read-only | — | `GET /gyms/:gymId/subscription` |
| Free trial CTA | Button | — | `POST /gyms/:gymId/subscription/trial` |

## API Flow

```
Load   → GET /gyms/:gymId                (errors → SnackBar)
       → GET /gyms/:gymId/subscription   (404 → null → show trial CTA)
Trial  → POST /gyms/:gymId/subscription/trial {planCode: "GYM_PRO"} → reload subscription
Logout → POST /auth/logout {refreshToken} → clear → /gym-owner-login
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load tab | `GET /gyms/:gymId` + `GET …/subscription` | Parallel |
| "Start Free Trial" | `POST …/subscription/trial` | `planCode` hardcoded `GYM_PRO` |
| "Edit Gym Settings" | — | Navigation to Gym Settings |
| "Logout" | `POST /auth/logout` | Best-effort |

## Database

Reads/writes: Gyms, GymSubscriptions.

## Validation / Error Handling

- Subscription 404 → "No active plan" state; failures → SnackBar.

## Links

`docs/apis/gym-management.md`, `docs/screens/gym-settings.md`,
`docs/screens/gym-owner-login.md`.