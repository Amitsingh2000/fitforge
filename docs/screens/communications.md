# Screen: Communications

- **File:** `lib/gym_owner/screens/communications_screen.dart`
- **Route:** Tab within the gym owner shell

## Screen Information

Outbound communications hub: pending/full log with filter, send via WhatsApp (external
wa.me deep link), mark-sent confirmation, and announcements.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Pending toggle | Toggle | — | `GET …/communications?pendingOnly=true` |
| Announce title | Text | Required | `POST …/communications/announce.title` |
| Announce body | Text | Required | `POST …/communications/announce.body` |

## API Flow

```
Load      → GET /gyms/:gymId/communications?page=1&limit=50[&pendingOnly=true]  (errors → [])
MarkSent  → POST /gyms/:gymId/communications/:commId/mark-sent → reload
Announce  → POST /gyms/:gymId/communications/announce {title, body} → reload
WhatsApp  → url_launcher → log.waLink (wa.me, externalApplication)
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Toggle pending | `GET …/communications?pendingOnly=true` | Reload |
| "Send" (wa.me) | — | External `wa.me` link from `waLink`; NOT an API call |
| "Mark Sent" | `POST …/communications/:commId/mark-sent` | Front-desk confirmation after sending |
| "Announce" | `POST …/communications/announce` | `channel`/`targetUserIds` not sent (all members, all channels) |

## Database

Reads/writes: CommunicationLogs.

## Validation / Error Handling

- Empty title/body → SnackBar; mark-sent failure tolerated (SnackBar).

## Links

`docs/apis/gym-referrals-leads-communications.md`, `docs/apis/external.md`,
`docs/screens/gym-owner-dashboard.md`.