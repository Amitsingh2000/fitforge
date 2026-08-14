# Screen: Enrollment

- **File:** `lib/gym_owner/screens/enrollment_screen.dart`
- **Route:** `MaterialPageRoute` from Members tab / Member Detail

## Screen Information

Enrollment (order) management: list enrollments, enroll a member into a plan, and act on
status (freeze / unfreeze / renew). SESSION plans with a trainer use `assignedTrainer`.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Member scope | Read-only (fixed) | — | `GET …/memberships?userId=` |
| Plan | Picker | Required | `POST …/memberships.planId` |
| Coupon Code | Text | Optional (non-empty sends) | `POST …/memberships.couponCode` |
| Price Override | Number | Optional (`double.tryParse`, non-null sends) | `POST …/memberships.priceOverride` |

## API Flow

```
Load    → GET /gyms/:gymId/memberships?page=1&limit=50[&userId=…]   (errors → [])
Enroll  → POST /gyms/:gymId/memberships {userId, planId, couponCode?, priceOverride?}
Freeze  → POST /gyms/:gymId/memberships/:id/freeze
Unfreeze→ POST /gyms/:gymId/memberships/:id/unfreeze
Renew   → POST /gyms/:gymId/memberships/:id/renew {}  → reload
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Tap "Enroll" | `POST …/memberships` | Coupon validated server-side |
| Freeze | `POST …/:id/freeze` | Confirmation |
| Unfreeze | `POST …/:id/unfreeze` | Confirmation |
| Renew | `POST …/:id/renew` | Creates next enrollment; old one CANCELLED |
| Add Plan | — | Navigation to Membership Plans |

## Database

Reads/writes: MemberPlanEnrollments, MembershipPlans, Coupons, Users.

## Validation / Error Handling

- No plan selected → SnackBar; freeze on non-active → SnackBar.
- Coupon invalid/expired → server message SnackBar.

## Links

`docs/apis/gym-memberships.md`, `docs/screens/membership-plans.md`,
`docs/screens/payments.md`, `docs/screens/member-detail.md`.