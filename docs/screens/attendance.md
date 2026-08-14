# Screen: Attendance

- **File:** `lib/gym_owner/screens/attendance_screen.dart`
- **Route:** Tab within the gym owner shell

## Screen Information

Daily attendance log (Check-ins) + absence alerts. Manual check-in via a member picker
bottom sheet (staff lookup). Deletion is owner/manager only (role-gated).

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Date picker | Date | — | `GET /gyms/:gymId/attendance?date=YYYY-MM-DD` |
| Check-in rows | Read-only | — | Same GET |
| Absence alerts | Read-only | — | `GET /gyms/:gymId/attendance/absence-alerts` |

## API Flow

```
Load      → GET /gyms/:gymId/attendance?date=…&page=1&limit=100  (errors → [])
Alerts    → GET /gyms/:gymId/attendance/absence-alerts           (errors → [])
Manual    → POST /gyms/:gymId/attendance/manual {userId}  → reload
Delete    → DELETE /gyms/:gymId/attendance/:attendanceId → reload  (owner/manager)
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Change date | `GET …/attendance?date=` | Reload |
| FAB → pick member | `POST …/attendance/manual` | Picker sourced from `GET /gyms/:gymId/members?limit=200&role=MEMBER` |
| Delete row (owner/manager) | `DELETE …/attendance/:attendanceId` | Confirmation |
| Alerts tab | `GET …/attendance/absence-alerts` | — |

## Database

Reads/writes: Attendance, GymMemberships (picker).

## Validation / Error Handling

- Manual check-in failure → SnackBar; delete failure → SnackBar.
- No attendance that day → empty state.

## Links

`docs/apis/gym-attendance.md`, `docs/screens/qr-checkin.md`,
`docs/screens/gym-owner-dashboard.md`.