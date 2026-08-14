# Screen: Gym Owner — Support

- **File:** `lib/gym_owner/screens/gym_owner_support_screen.dart`
- **Route:** `/gym-owner-support`

## Screen Information

Gym-side support desk: list existing tickets and submit new ones (category, subject,
message).

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Category chips | BILLING / TECHNICAL / ACCOUNT / OTHER | Required (default TECHNICAL) | `POST …/support.category` |
| Subject | Text | Required | `POST …/support.subject` |
| Message | Text | Required | `POST …/support.message` |

## API Flow

```
Load    → GET /gyms/:gymId/support   (errors → [])
Submit  → POST /gyms/:gymId/support {category, subject, message} → prepend to list
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load tickets | `GET …/support` | — |
| "Submit" | `POST …/support` | Validation → SnackBar |

## Database

Reads/writes: SupportRequests.

## Validation / Error Handling

- Empty subject/message → SnackBar; server `{message}` → SnackBar.

## Links

`docs/apis/gym-invites-joins-support.md`, `docs/screens/gym-owner-dashboard.md`.