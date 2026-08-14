# Screen: Gym Owner — Notifications

- **File:** `lib/gym_owner/screens/gym_owner_notifications_screen.dart`
- **Route:** `/gym-owner-notifications`

## Screen Information

Owner alert feed (join requests, renewals due, coupon redemptions, trainer updates, …)
with unread filtering and per-item read marking.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Unread toggle | Toggle | — | `GET …/dashboard/notifications?unreadOnly=true` |
| Notification cards | Read-only | — | `GET …/dashboard/notifications` |

## API Flow

```
Load → GET /gyms/:gymId/dashboard/notifications[?unreadOnly=true]  (errors → [])
Read → POST /gyms/:gymId/dashboard/notifications/:logId/read  (optimistic)
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Toggle unread | `GET …/dashboard/notifications?unreadOnly=true` | Reload |
| Tap unread card | `POST …/notifications/:logId/read` | Optimistic local mark; API failure swallowed |

## Database

Reads/writes: OwnerNotifications.

## Validation / Error Handling

- Mark-read is best-effort (non-critical); list failures → error state + retry.

## Links

`docs/apis/gym-dashboard.md`, `docs/screens/gym-owner-dashboard.md`.