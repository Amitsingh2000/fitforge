# Screen: Gym Owner — Trainers

- **File:** `lib/gym_owner/screens/gym_owner_trainers_screen.dart`
- **Route:** `/gym-owner-trainers`

## Screen Information

Trainer roster (from the dashboard trainers aggregate, with a members-list fallback) —
the trainer onboarding/management actions are covered in the trainer portal.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Trainer rows (name, specialization, clients, status, sessions) | Read-only | — | `GET …/dashboard/trainers` |

## API Flow

```
Load → GET /gyms/:gymId/dashboard/trainers
     → on failure: GET /gyms/:gymId/members?role=TRAINER&limit=100 (fallback)
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load roster | `GET …/dashboard/trainers` | Aggregates active clients + check-in rate + sessions |
| Fallback list | `GET …/members?role=TRAINER` | Only when the aggregate fails |
| Row tap | — | Static detail (no API beyond load) |

## Database

Reads: GymTrainerProfiles, GymMemberships, Enrollments.

## Validation / Error Handling

- Aggregate failure → fallback fetch; both failing → error state + retry.

## Links

`docs/apis/gym-dashboard.md`, `docs/apis/gym-members.md`,
`docs/screens/trainer-profile-tab.md`, `docs/screens/gym-owner-dashboard.md`.