# Screen: QR Self Check-in

- **File:** `lib/dashboard/screens/qr_checkin_screen.dart`
- **Route:** `MaterialPageRoute` from the dashboard (gym required)

## Screen Information

Member self check-in using the gym's QR code token. **The current build has no camera
scanner** — the QR token is pasted manually into the text field (the value printed on the
gym's check-in poster).

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| QR Code Token | Text | Non-empty | `POST /gyms/:gymId/attendance/check-in.qrToken` |

`gymId` comes from `currentGymIdProvider` (auto-selected membership).

## API Flow

```
Submit → POST /gyms/:gymId/attendance/check-in {qrToken}
       → success: "Check-in successful!" 
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Tap "Check In" | `POST /gyms/:gymId/attendance/check-in` | Idempotent — one entry per member per day (re-scans don't duplicate) |

## Database

Writes: Attendance (via backend).

## Validation / Error Handling

- Empty token → SnackBar.
- Wrong/invalid token → server `{message}` SnackBar; the field is preserved.
- Already checked in today → backend idempotency keeps a single entry.

## Links

`docs/apis/gym-member-actions.md`, `docs/screens/join-gym.md`,
`docs/screens/checkin-poster.md`, `docs/screens/attendance.md`.