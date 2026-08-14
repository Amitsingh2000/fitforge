# Screen: Check-in Poster

- **File:** `lib/gym_owner/screens/checkin_poster_screen.dart`
- **Route:** `MaterialPageRoute` from Gym Owner Dashboard

## Screen Information

Displays the printable QR check-in poster for the gym. Members scan (or, in this build,
read the token) to self check-in. The token can be **rotated**, invalidating old posters.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Poster QR + token | Read-only | — | `GET /gyms/:gymId/qr-check-in-token` (implied by rotate below) |
| Rotate confirmation | Dialog | — | `POST /gyms/:gymId/qr-check-in-token/rotate` |

## API Flow

```
Load    → GET /gyms/:gymId/qr-check-in-token  (token + QR data for the poster)
Rotate  → POST /gyms/:gymId/qr-check-in-token/rotate → reload poster
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load poster | `GET /gyms/:gymId/qr-check-in-token` | — |
| "Rotate Token" | `POST /gyms/:gymId/qr-check-in-token/rotate` | Confirmation; invalidates old poster; new token shown |

## Database

Reads/writes: Gyms (qrCheckInSecret) via backend.

## Validation / Error Handling

- Load/rotate failures → SnackBar; rotation requires explicit confirmation.

## Links

`docs/apis/gym-member-actions.md`, `docs/screens/qr-checkin.md`.