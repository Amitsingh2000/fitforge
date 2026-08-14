# Screen: Membership Plans

- **File:** `lib/gym_owner/screens/membership_plans_screen.dart`
- **Route:** `MaterialPageRoute` from the gym owner shell

## Screen Information

Plan (menu item) CRUD: list with an "include retired" toggle, create/edit sheets, and
retire (soft-delete) so enrollment history survives.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Name | Text | Required | `POST/PATCH …/plans.name` |
| Description | Text | Optional (omitted if empty) | `POST/PATCH …/plans.description` |
| Type | Chips: DURATION / SESSION | Required | `POST …/plans.type` |
| Duration Days | Number | Required when type=DURATION (`int.tryParse`) | `POST …/plans.durationDays` |
| Session Count | Number | Required when type=SESSION | `POST …/plans.sessionCount` |
| Price (₹) | Number | Required (`double.tryParse`) | `POST/PATCH …/plans.priceInr` |
| Retired toggle | Toggle | — | `GET …/plans?includeInactive=true` |

## API Flow

```
Load   → GET /gyms/:gymId/plans[?includeInactive=true]   (errors → [])
Create → POST /gyms/:gymId/plans {name, type, durationDays|sessionCount, priceInr, description?}
Edit   → PATCH /gyms/:gymId/plans/:planId {name?, description?, priceInr?} (non-null)
Retire → DELETE /gyms/:gymId/plans/:planId → reload
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Toggle retired | `GET …/plans?includeInactive=true` | Reload |
| "New Plan" → Save | `POST …/plans` | Validation errors → SnackBar |
| Edit → Save | `PATCH …/plans/:planId` | — |
| Retire | `DELETE …/plans/:planId` | Confirmation |

## Database

Reads/writes: MembershipPlans.

## Validation / Error Handling

- Invalid numbers → SnackBar; missing name → SnackBar; server `{message}` → SnackBar.

## Links

`docs/apis/gym-memberships.md`, `docs/screens/enrollment.md`.