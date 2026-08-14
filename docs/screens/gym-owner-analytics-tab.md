# Screen: Gym Owner — Analytics Tab

- **File:** `lib/gym_owner/screens/gym_owner_analytics_tab.dart`
- **Route:** Tab within the gym owner shell

## Screen Information

Business analytics: monthly KPIs, growth trend, engagement by trainer, and subscription
tier distribution.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Monthly KPIs | Read-only | — | `GET …/dashboard/monthly` |
| Growth chart | Read-only | — | `GET …/dashboard/growth` |
| Engagement by trainer | Read-only | — | `GET …/dashboard/progress` |
| Tier distribution | Read-only | — | `GET …/dashboard/subscription-usage` |

## API Flow

```
Load → GET /gyms/:gymId/dashboard/monthly               (errors tolerated)
     → GET /gyms/:gymId/dashboard/growth                (errors → [])
     → GET /gyms/:gymId/dashboard/progress              (errors → [])
     → GET /gyms/:gymId/dashboard/subscription-usage    (errors tolerated)
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load tab | 4 parallel GETs above | All degrade to empty/zeroed states |

## Database

Reads: aggregates (see `docs/apis/gym-dashboard.md` for field contracts).

## Validation / Error Handling

- Individual failures never block the tab — each section shows its own empty state.

## Links

`docs/apis/gym-dashboard.md`, `docs/screens/gym-owner-dashboard.md`.