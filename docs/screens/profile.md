# Screen: Profile

- **File:** `lib/dashboard/screens/profile_screen.dart`
- **Route:** Tab in the member dashboard shell

## Screen Information

Member profile tab: identity card, gym memberships, subscription + entitlements summary,
and logout.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Name / Email | Read-only | — | `GET /users/me` |
| Gym list | Read-only | — | `GET /users/me.gymMemberships` |
| Plan + tier | Read-only | — | `GET /subscriptions/me`, `GET /subscriptions/me/entitlements` |

## API Flow

```
Load → GET /users/me (via auth state) 
     → GET /subscriptions/me          (404 → NONE)
     → GET /subscriptions/me/entitlements (404 → FREE)
Logout → POST /auth/logout {refreshToken} → clear tokens → /login
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load tab | `GET /users/me`, `GET /subscriptions/me`, `GET /subscriptions/me/entitlements` | Sub errors tolerated |
| Tap "Manage Plan" | — | Navigation to `/billing-plans` |
| Tap "Edit Profile" | — | Navigation to Edit Profile |
| Tap "Logout" | `POST /auth/logout` | Best-effort; local session always cleared |

## Database

Reads: Users, MemberSubscriptions, MemberEntitlements, GymMemberships.

## Validation / Error Handling

- Subscription/entitlement fetch failures degrade to FREE/NONE display.

## Links

`docs/apis/subscriptions.md`, `docs/apis/authentication.md`,
`docs/screens/billing-plans.md`, `docs/screens/edit-profile.md`.