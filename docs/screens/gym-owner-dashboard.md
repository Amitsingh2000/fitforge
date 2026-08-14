# Screen: Gym Owner Dashboard

- **File:** `lib/gym_owner/screens/gym_owner_dashboard.dart`
- **Route:** `/gym-owner-dashboard`

## Screen Information

Owner landing: KPI cards, quick actions, member preview, and a bottom nav into the owner
tabs (Members, Attendance, Payments, Coupons, Analytics, Profile …). Data loads from the
dashboard overview/today endpoints and a members preview.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Total members / trainers / renewals due / pending joins | Read-only KPIs | — | `GET /gyms/:gymId/dashboard/overview` |
| Today: check-ins / collections / new joins | Read-only | — | `GET /gyms/:gymId/dashboard/today` |
| Recent members preview | Read-only | — | `GET /gyms/:gymId/members?page=1&limit=10&role=MEMBER` |
| Trainer roster chip | Read-only | — | `GET /gyms/:gymId/dashboard/trainers` |

## API Flow

```
Load → GET /gyms/:gymId/dashboard/overview   (errors → zeroed GymDashboardOverview)
     → GET /gyms/:gymId/dashboard/today      (errors tolerated)
     → GET /gyms/:gymId/members (preview)    (errors → [])
     → GET /gyms/:gymId/dashboard/trainers   (errors → [] or role=MEMBER fallback)
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load dashboard | 4 parallel GETs above | All tolerant of failure |
| Tap "Members" | — | Members tab |
| Tap "Check-In Poster" | — | Check-in Poster screen |
| Tap "Invite Codes" / "Join Requests" | — | Respective screens |
| Bottom nav (Attendance, Payments, Coupons, Analytics, Profile) | — | Respective tabs |

## Database

Reads: aggregated gym data (see `gym-dashboard.md` for the aggregate contract).

## Validation / Error Handling

- Every load degrades gracefully (zeroed/empty state) — the dashboard never hard-fails.

## Links

`docs/apis/gym-dashboard.md`, `docs/apis/gym-members.md`,
`docs/screens/gym-owner-analytics-tab.md`, `docs/screens/checkin-poster.md`.