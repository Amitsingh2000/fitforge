# Screen: Join a Gym

- **File:** `lib/dashboard/screens/join_gym_screen.dart`
- **Route:** `MaterialPageRoute` from the dashboard when the member has no gym

## Screen Information

Lets a member join a gym via its invite/activation code. On success the membership is cached
into `selectedGymProvider` so gym-scoped features (QR check-in, referrals) work immediately.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Gym Code | Text | Non-empty | `POST /gyms/join.code` |

## API Flow

```
Submit → POST /gyms/join {code}
       → store GymMembership{gymId, gymName, role: member, membershipId} in selectedGymProvider
       → success SnackBar
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Tap "Join Gym" | `POST /gyms/join` | Reads `gymId`/`gym.id`, `membershipId`, `gymName`/`gym.name` from the response |

## Database

Reads/writes: GymMemberships (via backend).

## Validation / Error Handling

- Empty code → SnackBar.
- Invalid/expired code → server `{message}` SnackBar; input kept for retry.

## Links

`docs/apis/gym-member-actions.md`, `docs/screens/qr-checkin.md`,
`docs/screens/referral.md`, `docs/screens/gym-owner-dashboard.md`.