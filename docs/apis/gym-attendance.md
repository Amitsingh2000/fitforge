# API Module: Attendance

Source: `lib/services/gym_owner_service.dart`, `lib/models/attendance_record.dart`.
Backend context: `section2-handoff.md` — QR self check-in, front-desk manual check-in, and
Google-Calendar-style CRUD. One entry per member per day (re-scans idempotent). Check-in
methods: `QR | MANUAL | CALENDAR`.

Backend controller/service details: **Not found in source code** (backend external to this
repo).

## 1. GET /gyms/:gymId/attendance

Used by: Attendance screen (Check-ins tab).

**Query parameters:**

| Param | Type | Source |
|---|---|---|
| page | Number | 1 (service default) |
| limit | Number | 100 (service default) |
| date | String `YYYY-MM-DD` | Selected date (date picker) |
| userId | String | Member filter (service supports; not passed by the current screen) |

**Response:** list parsed by `AttendanceRecord.fromJson`:

| Field | Aliases read | Description |
|---|---|---|
| id | — | Attendance id (used for delete) |
| userId | `user.id` / `member.id` | Member |
| memberName | `memberName` or `member/user.{firstName,lastName}` | Name |
| memberAvatarUrl | `member/user.avatarUrl` | Avatar |
| attendedOn | — | Date |
| checkInMethod | — | `QR` / `MANUAL` / `CALENDAR` |

## 2. POST /gyms/:gymId/attendance/manual

Used by: Attendance screen (Manual Check-In FAB → pick member from bottom sheet).

**Request:**

```json
{ "userId": "u_123" }
```

Checks the member in for **today** (no date param — server uses today).

## 3. DELETE /gyms/:gymId/attendance/:attendanceId

Used by: Attendance screen (delete icon — GYM_OWNER / GYM_MANAGER only; the UI gates via
`currentGymRoleProvider.isOwnerOrManager`). No body.

## 4. GET /gyms/:gymId/attendance/absence-alerts

Used by: Attendance screen (Absence Alerts tab). **Response:** list of `AbsenceAlert`
(members who haven't visited in N days):

| Field | Aliases read | Description |
|---|---|---|
| userId | — | Member user id |
| memberName | — | Name |
| daysSinceLastVisit | `daysSince` | Absence days |
| lastVisitedOn | `lastVisit` | Last visit date |

Errors → `[]`.

## Defined but NOT called by any screen

| Method | Endpoint | Service method | Note |
|---|---|---|---|
| POST | `/gyms/:gymId/attendance` | `addAttendanceEntry` | Calendar backfill `{userId, attendedOn}` — not wired |
| PATCH | `/gyms/:gymId/attendance/:attendanceId` | `updateAttendanceEntry` | Correct a date `{attendedOn}` — not wired |

## RBAC (from section2-handoff.md)

- Manual check-in / take attendance: GYM_OWNER, GYM_MANAGER, FRONT_DESK.
- Delete an attendance entry: GYM_OWNER, GYM_MANAGER only.
- QR self check-in: MEMBER (`POST /gyms/:gymId/attendance/check-in`, see
  `gym-member-actions.md`).

## Entities

Attendance (+ derived absence alerts; see `database-overview.md`).