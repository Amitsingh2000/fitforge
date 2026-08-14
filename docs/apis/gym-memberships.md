# API Module: Membership Plans & Enrollments

Source: `lib/services/gym_owner_service.dart`, `lib/models/enrollment.dart`.
Backend context: `section2-handoff.md` — plan = menu item; **enrollment** = the order (one
member's instance of a plan with snapshotted price/dates/sessions). Status:
`ACTIVE · FROZEN · EXPIRED · CANCELLED`.

Backend controller/service details: **Not found in source code** (backend external to this
repo).

## 1. Plans

### GET /gyms/:gymId/plans
Used by: Membership Plans, Enrollment (plan picker). Query: `includeInactive=true` when the
"show retired" toggle is on. **Response:** list of raw maps (fields read: `id`, `name`,
`description`, `priceInr`, `type` — `DURATION`/`SESSION` (default DURATION), `isActive`
(default true), `durationDays`, `sessionCount`).

### POST /gyms/:gymId/plans
Used by: Membership Plans (create sheet).

```json
{ "name": "Quarterly", "description": "90 days", "type": "DURATION", "durationDays": 90, "sessionCount": null, "priceInr": 5000 }
```

| Field | Type | Required | Source |
|---|---|---|---|
| name | String | Yes | Form |
| description | String | No | Form (omitted if empty) |
| type | String | Yes | Type chips: `DURATION`/`SESSION` |
| durationDays | Number | If type=DURATION | `int.tryParse` of form |
| sessionCount | Number | If type=SESSION | `int.tryParse` of form |
| priceInr | Number | Yes | `double.tryParse` (must be valid + name non-empty) |

### PATCH /gyms/:gymId/plans/:planId
Used by: Membership Plans (edit). Body: `{name?, description?, priceInr?}` (only non-null).

### DELETE /gyms/:gymId/plans/:planId
Used by: Membership Plans (retire — soft-deactivate). History on past enrollments survives.

## 2. Enrollments

### GET /gyms/:gymId/memberships
Used by: Enrollment screen. Query params: `page=1`, `limit=50`, `userId=<member.userId>`
(when scoped to one member), `status` (supported by the service, not currently passed).
**Response:** list parsed by `Enrollment.fromJson`:

| Field | Aliases read | Description |
|---|---|---|
| id | `enrollmentId` | Enrollment id |
| status | — | `ACTIVE`/`FROZEN`/`EXPIRED`/`CANCELLED` |
| userId | — | Member user id |
| planId / planName / planType | `plan.id` / `plan.name` / `plan.type` | Plan snapshot |
| startDate / endDate | — | Validity |
| priceInr | — | Snapshotted price |
| sessionsTotal / sessionsRemaining | `sessionCount` | Session pack counters |
| couponCode | — | Discount applied |
| previousEnrollmentId | — | Renewal lineage |
| assignedTrainerId / assignedTrainerName | `assignedTrainer.id`/`name` | PT assignment |
| dueAmountInr | `dues` | Live dues (price − Σ payments) |

### POST /gyms/:gymId/memberships
Used by: Enrollment (enroll sheet).

```json
{ "userId": "u_1", "planId": "plan_1", "couponCode": "SAVE10", "priceOverride": 4500 }
```

`couponCode`/`priceOverride` only when non-empty/non-null. Optional `priceOverride` lets staff
override the final price. **Response:** `Enrollment`.

### POST /gyms/:gymId/memberships/:enrollmentId/freeze
Freeze an active enrollment (travel/injury). No body.

### POST /gyms/:gymId/memberships/:enrollmentId/unfreeze
Unfreeze — extends `endDate` by the actual frozen duration. No body.

### POST /gyms/:gymId/memberships/:enrollmentId/renew
Creates the next enrollment starting when the current ends (or now if lapsed); the old
enrollment becomes `CANCELLED` and links via `previousEnrollmentId`. Body `{}` (screen does
not pass `priceOverride`). **Response:** `Enrollment`.

## 3. Defined but NOT called by any screen (backend-only from the frontend's perspective)

| Method | Endpoint | Service method | Purpose (per handoff) |
|---|---|---|---|
| GET | `/gyms/:gymId/memberships/:enrollmentId` | `getEnrollment` | Single enrollment fetch |
| POST | `/gyms/:gymId/memberships/:enrollmentId/change-plan` | `changePlan` | Upgrade/downgrade with auto-proration (`newPlanId`, `priceOverride?`) |
| POST | `/gyms/:gymId/memberships/:enrollmentId/transfer` | `transferEnrollment` | Reassign to another member (`toUserId`) |
| POST | `/gyms/:gymId/memberships/:enrollmentId/assign-trainer` | `assignTrainerToEnrollment` | Assign trainer to SESSION enrollment (`trainerId`) |
| POST | `/gyms/:gymId/memberships/:enrollmentId/session-logs` | `logSession` | Log PT/class session — decrements `sessionsRemaining`; auto-EXPIRED at 0 |
| GET | `/gyms/:gymId/memberships/:enrollmentId/session-logs` | `getSessionLogs` | Session log history |

## RBAC (from section2-handoff.md)

- Enroll / freeze / renew: GYM_OWNER, GYM_MANAGER, FRONT_DESK.
- Change-plan / transfer / assign-trainer: GYM_OWNER, GYM_MANAGER only.

## Entities

MembershipPlans, MemberPlanEnrollments, Coupons (discount), Users (see
`database-overview.md`).