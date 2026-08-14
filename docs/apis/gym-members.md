# API Module: Gym Members & Staff

Source: `lib/services/gym_owner_service.dart`, `lib/models/gym_member.dart`.
Backend controller/service details: **Not found in source code** (backend external to this
repo).

## 1. GET /gyms/:gymId/members

Used by: Gym Owner Dashboard (preview), Members tab, Attendance (manual check-in picker),
Trainers (fallback).

**Query parameters** (backend `ListMembersQueryDto` only whitelists these — extra params 400):

| Param | Type | Value used by screens |
|---|---|---|
| page | Number | 1 |
| limit | Number | 10 (dashboard), 100 (members tab), 200 (attendance picker) |
| role | String | `MEMBER` (dashboard/attendance), `TRAINER` (trainers fallback) |

**Response:** list parsed by `GymMember.fromJson` (tolerant of nested `user{}`):

| Field | Aliases read | Description |
|---|---|---|
| membershipId | `id` | Membership id (used in detail/delete calls) |
| userId | `user.id` | User id (used in enroll/attendance calls) |
| firstName / lastName | `user.*` | Name (default "Member") |
| email | `user.email` | Email |
| phone / avatarUrl | `user.*` | Contact |
| role | — | `MEMBER` / `TRAINER` / `GYM_OWNER` / `FRONT_DESK` |
| status | — | `ACTIVE` / `EXPIRED` / `FROZEN` / `PENDING` |
| planName | `plan.name` | Current plan |
| startDate / endDate | — | Membership window |
| assignedTrainerName / assignedTrainerId | `trainer.name` / `trainer.id` | Trainer |

Search/filtering is **client-side** (status chips, trainer filter, text search) over the
fetched page.

## 2. GET /gyms/:gymId/members/:membershipId

Used by: Member Detail (360° view). **Response:** a `GymMember` enriched with recent
enrollments (with computed dues) and recent attendance.

## 3. POST /gyms/:gymId/members

Used by: Add Member.

**Request:**

```json
{ "firstName": "Rahul", "lastName": "Sharma", "email": "r@example.com", "phone": "9876543210" }
```

Optional fields omitted when empty. **Response:** `GymMember`.

## 4. POST /gyms/:gymId/members/import

Used by: Bulk Import (dry-run preview, then commit).

**Request:**

```json
{ "dryRun": true, "rows": [ { "first name": "Rahul", "phone": "..." } ] }
```

`rows` are key/value maps parsed client-side from CSV/Excel headers (max 500 rows).

**Response** (raw map read by the screen):

| Field | Type | Description |
|---|---|---|
| rows | Array | Per-row report: `{status: CREATED|LINKED_EXISTING|ALREADY_MEMBER|ERROR, fullName|firstName, message, phone, email, index}` |
| created / linkedExisting / alreadyMember / errors | Number | Summary chips |

## 5. PATCH /gyms/:gymId/members/:membershipId/notes

Used by: Member Detail. **Request:**

```json
{ "staffNotes": "Prefers morning slots" }
```

## 6. PATCH /gyms/:gymId/members/:membershipId/trainer-config

Used by: Members tab (Shift & Pay sheet). **Request:**

```json
{ "shiftSchedule": "Mon-Sat 6am-2pm", "commissionPercent": 20 }
```

Both optional — only non-null sent.

## 7. DELETE /gyms/:gymId/members/:membershipId

Used by: Members tab, Member Detail (Remove). No body. Removes the member/staff record.

## Unused endpoint in this module

| Method | Endpoint | Service method | Note |
|---|---|---|---|
| PATCH | `/gyms/:gymId/members/:membershipId/profile` | `updateMemberRecord` | Staff edit of photo/ID-proof/emergency-contact — defined but not wired to any screen |

## Entities

Users, GymMemberships, Enrollments, Attendance (see `database-overview.md`).