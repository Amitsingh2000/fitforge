# Screen: Gym Settings

- **File:** `lib/gym_owner/screens/gym_settings_screen.dart`
- **Route:** `MaterialPageRoute` from the gym owner profile tab

## Screen Information

Gym profile editor: identity, address, UPI payout details, logo/photos/uploads (media
gated on storage config), facilities, and working hours.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Name / Phone / Email | Text | Phone optional | `PATCH /gyms/:gymId.{name, phone, email}` |
| Address Line / City / State / Pincode | Text | Pincode ≥ 4 digits if filled | `PATCH /gyms/:gymId.{…}` |
| Logo | Image picker → upload | — | `POST /media/presign-upload` (`GYM_LOGO`) → PUT → `PATCH /gyms/:gymId.logoUrl` |
| UPI ID | Text | UPI format if filled | `PATCH /gyms/:gymId.upiId` |
| UPI QR | Image picker → upload | — | `POST /media/presign-upload` (`GYM_UPI_QR`) → PUT → `PATCH /gyms/:gymId.upiQrCodeUrl` |
| Facilities | Chip multi-select | — | `PATCH /gyms/:gymId.facilities` |
| Working Hours | Day row editor ×7 | HH:mm format | `PATCH /gyms/:gymId.workingHours` (day map incl. `isClosed`) |
| Notification mute prefs | Toggles | — | `PATCH /gyms/:gymId.mutedOwnerAlertTypes` |

## API Flow

```
Load   → GET /gyms/:gymId  (populate form; 404 → SnackBar)
       → GET /media/status  (gate uploads)
Save   → PATCH /gyms/:gymId {…non-null changed fields}
Upload → POST /media/presign-upload → PUT storage → field set with publicUrl
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load | `GET /gyms/:gymId`, `GET /media/status` | Parallel |
| "Save Changes" | `PATCH /gyms/:gymId` | Only non-null fields |
| Upload logo/QR | `POST /media/presign-upload` → PUT | Uses shared upload helper |

## Database

Reads/writes: Gyms, Media/storage config.

## Validation / Error Handling

- Save → SnackBar; uploads blocked with a hint when storage is not configured
  (`GET /media/status.configured == false`).

## Links

`docs/apis/gym-management.md`, `docs/apis/media.md`,
`docs/screens/create-gym.md`, `docs/screens/gym-owner-profile-tab.md`.