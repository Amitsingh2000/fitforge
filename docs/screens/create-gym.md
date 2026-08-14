# Screen: Create Gym

- **File:** `lib/gym_owner/screens/create_gym_screen.dart`
- **Route:** `/create-gym`

## Screen Information

First-time gym setup form (also reachable from the gym-owner login flow when the email has
no gym yet).

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Gym Name | Text | ≥ 2 chars | `POST /gyms.name` |
| Phone | Text | Optional; ≥ 7 digits if filled | `POST /gyms.phone` |
| Email | Text | Optional; email format if filled | `POST /gyms.email` |
| Address Line | Text | Required | `POST /gyms.addressLine` |
| City | Text | Required | `POST /gyms.city` |
| State | Text | Required | `POST /gyms.state` |
| Pincode | Text | Optional; ≥ 4 digits if filled | `POST /gyms.pincode` |
| Referral Code | Text | Optional | `POST /gyms.referralCode` |

> Note: only the fields above are sent — `upiId`/`address`/facilities etc. are configured
> later via `PATCH /gyms/:gymId` (Gym Settings). Sending unknown fields to
> `CreateGymDto` would 400 under strict validation.

## API Flow

```
Submit → POST /gyms {…validated fields}
       → read res['id']/res['gymId'] + res['membershipId']
       → set selectedGymProvider (auto-select) → /gym-owner-dashboard
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Tap "Create Gym" | `POST /gyms` | Sets gym context from the response |
| "Sign In" (existing) | — | Navigation to `/gym-owner-login` |

## Database

Writes: Gyms + GymMemberships (owner) via backend.

## Validation / Error Handling

- Inline validation per field; server `{message}` → SnackBar; failure keeps the form.

## Links

`docs/apis/gym-management.md`, `docs/screens/gym-owner-login.md`,
`docs/screens/gym-settings.md`.