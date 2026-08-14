# Screen: Gym Owner — Join Requests

- **File:** `lib/gym_owner/screens/gym_owner_join_requests_screen.dart`
- **Route:** `/gym-owner-join-requests`

## Screen Information

Pending self-serve join requests awaiting owner approval/rejection (with reason).

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Request rows (name, email, phone, joinedAt) | Read-only | — | `GET …/join-requests` |
| Rejection reason chips | Full Capacity / Out of Area / Incomplete Profile / Payment Issue / Other (type below) | Optional (omitted if empty) | `POST …/reject.reason` |

## API Flow

```
Load    → GET /gyms/:gymId/join-requests   (errors → [])
Accept  → POST /gyms/:gymId/join-requests/:membershipId/approve → remove from list
Reject  → POST /gyms/:gymId/join-requests/:membershipId/reject {reason?} → remove from list
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load | `GET …/join-requests` | — |
| "Accept" | `POST …/approve` | Activates the membership |
| "Reject" | `POST …/reject` | Reason sheet (chip or custom text) |

## Database

Reads/writes: GymMemberships, Users.

## Validation / Error Handling

- Approve/reject failures → SnackBar.

> **Open question** (see `GAP_LOG.md`): whether this screen should map to the invite/join-
> request endpoints or to walk-in leads — pending backend clarification.

## Links

`docs/apis/gym-invites-joins-support.md`, `docs/screens/invite-management.md`,
`docs/screens/join-gym.md`.