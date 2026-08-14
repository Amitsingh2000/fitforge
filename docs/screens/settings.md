# Screen: Settings

- **File:** `lib/dashboard/screens/settings_screen.dart`
- **Route:** `/settings`

## Screen Information

Account security hub: active sessions list, device logout, "log out everywhere", plus
super-admin entry points (Certification Review).

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Session rows (device, created, last used) | Read-only | — | `GET /auth/sessions` |
| Session "X" (current device) | Icon | — | `DELETE /auth/sessions/:sessionId` |

## API Flow

```
Load   → GET /auth/sessions  → list with per-row delete
Delete → DELETE /auth/sessions/:sessionId → reload
All    → POST /auth/logout-all → reload + SnackBar
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load settings | `GET /auth/sessions` | — |
| Tap device "X" | `DELETE /auth/sessions/:sessionId` | Confirmation dialog |
| "Log Out of All Devices" | `POST /auth/logout-all` | — |
| Super-admin → "Certification Review" | — | Navigation to Certification Review |
| App version info | — | Static |

## Database

Writes: none directly (backend manages sessions).

## Validation / Error Handling

- `isCurrent` flag: the screen has no current-session id, so the current row is never
  highlighted as "this device" (**known gap** — see `GAP_LOG.md`).
- Session list failure → error state + retry.

## Links

`docs/apis/authentication.md`, `docs/screens/certification-review.md`.