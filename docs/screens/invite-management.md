# Screen: Invite Codes

- **File:** `lib/gym_owner/screens/invite_management_screen.dart`
- **Route:** `MaterialPageRoute` from Gym Owner Dashboard

## Screen Information

Role-based invite codes (self-serve member/trainer/staff joins) with usage caps and
expiry, plus revoke.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Role chips | MEMBER / TRAINER / FRONT_DESK / GYM_MANAGER | Required (default MEMBER) | `POST …/invites.role` |
| Max Uses | Number | Optional (`int.tryParse`; empty = unlimited) | `POST …/invites.maxUses` |
| Expiry | Date | Optional (default +30 days; clearable) | `POST …/invites.expiresAt` (ISO 8601) |

## API Flow

```
Load    → GET /gyms/:gymId/invites   (errors → [])
Create  → POST /gyms/:gymId/invites {role, maxUses?, expiresAt?} → reload
Revoke  → POST /gyms/:gymId/invites/:inviteId/revoke → reload
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load list | `GET …/invites` | Shows role, code, uses, expiry, revoked |
| "New Invite" → Create | `POST …/invites` | — |
| Revoke | `POST …/invites/:inviteId/revoke` | Confirmation; code invalidated |

## Database

Reads/writes: InviteCodes.

## Validation / Error Handling

- Invalid numbers → SnackBar; server `{message}` → SnackBar.

## Links

`docs/apis/gym-invites-joins-support.md`, `docs/screens/gym-owner-join-requests.md`,
`docs/screens/join-gym.md`.