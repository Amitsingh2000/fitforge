# Screen: Member Detail

- **File:** `lib/gym_owner/screens/member_detail_screen.dart`
- **Route:** `MaterialPageRoute` from Members tab / Attendance picker

## Screen Information

360° member view: profile, plan + computed dues, recent enrollments and attendance, staff
notes, and remove.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Member info + plan + dues | Read-only | — | `GET /gyms/:gymId/members/:membershipId` |
| Staff Notes | Text | Optional | `PATCH /gyms/:gymId/members/:membershipId/notes.staffNotes` |
| Remove member | Confirmation | — | `DELETE /gyms/:gymId/members/:membershipId` |

## API Flow

```
Load   → GET /gyms/:gymId/members/:membershipId  (enriched GymMember with enrollments+dues+attendance)
Notes  → PATCH /gyms/:gymId/members/:membershipId/notes {staffNotes}
Remove → DELETE /gyms/:gymId/members/:membershipId → pop back to Members tab
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load detail | `GET …/members/:membershipId` | Errors → SnackBar |
| "Save Notes" | `PATCH …/notes` | — |
| "Remove Member" | `DELETE …/members/:membershipId` | Dialog confirmation |

## Database

Reads/writes: GymMemberships, Enrollments, Attendance, Users.

## Validation / Error Handling

- Empty notes → SnackBar; load failure → SnackBar with retry.

## Links

`docs/apis/gym-members.md`, `docs/screens/gym-owner-members-tab.md`,
`docs/screens/enrollment.md`, `docs/screens/payments.md`.