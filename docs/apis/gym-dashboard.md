# API Module: Gym Dashboards & Notifications

Source: `lib/services/gym_owner_service.dart`, `lib/models/gym_dashboard_data.dart`,
`lib/models/gym_trainer.dart`, `lib/models/owner_notification.dart`.
Backend controller/service details: **Not found in source code** (backend external to this
repo). Owner/manager-only per `section2-handoff.md` RBAC (GymRolesGuard).

All endpoints: `GET/POST /gyms/:gymId/...` — `gymId` from `currentGymIdProvider`.

## 1. GET /gyms/:gymId/dashboard/overview

Used by: Gym Owner Dashboard, Gym Owner Profile tab. **Response** (parsed by
`GymDashboardOverview.fromJson`):

```json
{
  "totalMembers": 120,
  "totalTrainers": 4,
  "activeMemberships": 95,
  "pendingJoinRequests": 3,
  "membershipRenewalsDue": 7,
  "revenueOverview": { "todayInr": 12000, "monthInr": 280000 },
  "unreadNotifications": 2
}
```

Errors → `const GymDashboardOverview()` (zeroed).

## 2. GET /gyms/:gymId/dashboard/today

Used by: Gym Owner Dashboard. **Response** (`GymDashboardToday.fromJson` — tolerant of
`checkIns`/`collectionsToday`/`newJoins`/`expiringSoon`/`totalDues` aliases):

```json
{ "totalCheckIns": 42, "collectionsAmount": 8500, "newJoinsCount": 3, "expiringSoonCount": 5, "totalDuesAmount": 24000 }
```

## 3. GET /gyms/:gymId/dashboard/monthly

Used by: Analytics tab. **Response** (`GymDashboardMonthly.fromJson`):

```json
{ "totalRevenue": 280000, "activeMembersCount": 95, "renewalsCount": 18, "churnCount": 4, "retentionRatePercent": 92.5, "attendanceTrend": [] }
```

## 4. GET /gyms/:gymId/dashboard/growth

Used by: Analytics tab. **Response:** list of `{month: "YYYY-MM", newMembers: number}` —
last 6 months, oldest first (`GymGrowthPoint`).

## 5. GET /gyms/:gymId/dashboard/progress

Used by: Analytics tab. **Response** (`GymProgressOverview.fromJson`):

```json
{
  "overall": { "activeMembers": 80, "inactiveMembers": 40, "activeMemberRate7dPercent": 72.4 },
  "byTrainer": [
    { "trainerUserId": "u_1", "trainerName": "Coach A", "assignedActiveClients": 8, "clientCheckInRate7dPercent": 65.0, "avgSessionPackUtilizationPercent": 40.0 }
  ],
  "definition": "..."
}
```

Engagement is attendance/session-based (an engagement proxy, not literal workout progress).

## 6. GET /gyms/:gymId/dashboard/subscription-usage

Used by: Analytics tab. **Response** (`GymSubscriptionUsage.fromJson`):

```json
{ "totalMembers": 120, "byTier": { "FREE": 40, "TRIAL_FULL": 10, "TRIAL_LIMITED": 5, "PREMIUM": 65 } }
```

## 7. GET /gyms/:gymId/dashboard/trainers

Used by: Gym Owner Dashboard, Members tab, Trainers screen. **Response:** list parsed by
`GymTrainer.fromJson`:

| Field | Aliases read | Description |
|---|---|---|
| trainerId | `userId`, `user.id` | Trainer user id |
| membershipId | `id` | Gym membership id |
| name | `firstName+lastName`, `name`, `user.fullName` | Display name |
| email / phone / avatarUrl | `user.*` | Contact |
| specialization | `spec` | Default `Fitness Trainer` |
| activeClientsCount | `clientsCount`, `assignedClients`, `assignedActiveClients` | Client count |
| status | — | `ACTIVE`/`INACTIVE` |
| sessionsLoggedLast30Days | — | Sessions |
| clientCheckInRate7dPercent | — | % |

On failure, `getTrainersRoster` falls back to `GET /gyms/:gymId/members?role=TRAINER`
(see `gym-members.md`).

## 8. GET /gyms/:gymId/dashboard/notifications

Used by: Notifications screen. Query param `unreadOnly=true` when the toggle is on.
**Response:** list of `OwnerNotification`:

| Field | Type | Description |
|---|---|---|
| id | String | Alert id |
| templateType | String | e.g. `OWNER_JOIN_REQUEST`, `OWNER_RENEWAL_DUE`, `OWNER_MEMBERSHIP_EXPIRED`, `OWNER_COUPON_REDEEMED`, `OWNER_TRAINER_JOINED`, `OWNER_TRAINER_UPDATE` |
| subject / body | String? / String | Content |
| readAt | ISO date? | Null = unread |
| createdAt | ISO date | Timestamp |

## 9. POST /gyms/:gymId/dashboard/notifications/:logId/read

Used by: Notifications screen (tap on an unread card). No body. The screen optimistically
marks the item read locally; API failure is swallowed (non-critical).

## Entities

Aggregates over Gyms, GymMemberships, Enrollments, Attendance, OwnerNotifications
(see `database-overview.md`).