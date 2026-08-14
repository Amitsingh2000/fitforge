# Screen: Gym Owner — Members Tab

- **File:** `lib/gym_owner/screens/gym_owner_members_tab.dart`
- **Route:** Tab within the gym owner shell

## Screen Information

Member roster with client-side search/filter (status chips, trainer filter, text search)
over the fetched page, plus per-member quick actions.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Search box / status chips / trainer filter | Filters | — | Client-side over fetched page |
| Member rows | Read-only | — | `GET /gyms/:gymId/members?page=1&limit=100&role=MEMBER` |
| Shift & Pay sheet (trainer staff) | Text fields | — | `PATCH /gyms/:gymId/members/:membershipId/trainer-config` |
| Remove | Confirmation | — | `DELETE /gyms/:gymId/members/:membershipId` |

## API Flow

```
Load   → GET /gyms/:gymId/members?page=1&limit=100&role=MEMBER (errors → [])
Shift  → PATCH /gyms/:gymId/members/:membershipId/trainer-config {shiftSchedule?, commissionPercent?}
Remove → DELETE /gyms/:gymId/members/:membershipId → reload
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Search / filter | — | Client-side only (no query params) |
| Tap member | — | Member Detail screen |
| Add Member | — | Add Member screen |
| Bulk Import | — | Bulk Import screen |
| "Shift & Pay" (trainer row) | `PATCH …/trainer-config` | Only non-null fields sent |
| "Remove" | `DELETE …/members/:membershipId` | Confirmation dialog |

## Database

Reads/writes: GymMemberships, Users (see `gym-members.md`).

## Validation / Error Handling

- `int.tryParse`/`double.tryParse` guards on the Shift & Pay fields; invalid → SnackBar.
- Delete confirmation required; failures → SnackBar.

## Links

`docs/apis/gym-members.md`, `docs/screens/add-member.md`,
`docs/screens/bulk-import.md`, `docs/screens/member-detail.md`.