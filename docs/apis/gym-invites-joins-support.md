# API Module: Invites, Join Requests & Support

Three smaller gym modules: invite codes (self-serve join), join requests (owner approval),
and the support desk.

Backend controller/service details: **Not found in source code** (backend external to this
repo).

## Part A — Invite codes

### GET /gyms/:gymId/invites
Used by: Invite Codes screen. **Response:** list of raw maps; the screen reads `role`
(default `MEMBER`), `code`, `revokedAt` (null = active), `expiresAt` (ISO),
`maxUses` (null = unlimited), `usesCount` (default 0), `id`.

### POST /gyms/:gymId/invites
Used by: Invite Codes screen (New Invite sheet).

```json
{ "role": "MEMBER", "maxUses": 100, "expiresAt": "2026-09-13T00:00:00.000Z" }
```

| Field | Type | Required | Source |
|---|---|---|---|
| role | String | Yes | Chips: `MEMBER` / `TRAINER` / `FRONT_DESK` / `GYM_MANAGER` (default MEMBER) |
| maxUses | Number | No | `int.tryParse` (empty = unlimited) |
| expiresAt | ISO 8601 | No | Date picker (default +30 days; clearable) |

**Response:** raw map (unused; list reloaded).

### POST /gyms/:gymId/invites/:inviteId/revoke
Used by: Invite Codes screen (Revoke, confirmation). No body. Invalidates the code.

## Part B — Join requests (self-serve member join, owner approval)

### GET /gyms/:gymId/join-requests
Used by: Join Requests screen. **Response:** list parsed by `JoinRequest.fromJson`:

| Field | Aliases read | Description |
|---|---|---|
| membershipId | `id` | Membership id (used for approve/reject) |
| userId | `user.id` | User id |
| firstName / lastName | `user.*` | Name |
| email / phone / avatarUrl | `user.*` | Contact |
| requestedAt | `joinedAt` | When requested |

### POST /gyms/:gymId/join-requests/:membershipId/approve
Used by: Join Requests screen (Accept). No body. Activates the membership; the request is
removed from the local list.

### POST /gyms/:gymId/join-requests/:membershipId/reject
Used by: Join Requests screen (Reject sheet).

```json
{ "reason": "Gym at Full Capacity" }
```

`reason` = selected chip (`Gym at Full Capacity`, `Out of Service Area`, `Incomplete
Profile`, `Payment Issue`, `Other (Type Below)`) or the custom text; omitted if empty.

### Open question (from GAP_LOG.md)
Whether "Join Requests" should map to these invite/join-request endpoints or to walk-in
leads (`GET /gyms/:gymId/leads`) is pending backend clarification.

## Part C — Support

### GET /gyms/:gymId/support
Used by: Support screen. Query `status` supported by the service, not passed by the screen.
**Response:** list parsed by `SupportRequest.fromJson`:

| Field | Type | Description |
|---|---|---|
| id | String | Request id |
| category | String | `BILLING` / `TECHNICAL` / `ACCOUNT` / `OTHER` |
| subject / message | String | Content |
| status | String | `OPEN` / `IN_PROGRESS` / `RESOLVED` |
| resolutionNotes | String? | Platform response |
| createdAt | ISO date | Timestamp |

### POST /gyms/:gymId/support
Used by: Support screen (Submit Request).

```json
{ "category": "TECHNICAL", "subject": "App crash", "message": "It crashes on save." }
```

Subject + message must be non-empty (SnackBar otherwise). **Response:** `SupportRequest`
(prepended to the local list).

## Entities

InviteCodes, GymMemberships, SupportRequests (see `database-overview.md`).