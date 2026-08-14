# Screen: Gym Owner — Referrals Tab

- **File:** `lib/gym_owner/screens/gym_owner_referrals_tab.dart`
- **Route:** Tab within the gym owner shell

## Screen Information

Owner-side referral program configuration: reward type (free days vs discount coupon) and
value, with live referrer stats.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Reward type chips | FREE_DAYS / FLAT_DISCOUNT_COUPON | Required | `PUT …/referrals/config.rewardType` |
| Value chips | Days [3,5,7,14,30] / ₹ [50,100,150,200,500] | Required (default 7) | `PUT …/referrals/config.rewardValue` |
| Referrer stats | Read-only | — | `GET …/referrals/config` (and member-side stats) |

## API Flow

```
Load   → GET /gyms/:gymId/referrals/config   (404 → not configured → empty state)
Save   → PUT /gyms/:gymId/referrals/config {rewardType, rewardValue} → reload
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load tab | `GET …/referrals/config` | 404 handled as "not configured" |
| "Save Reward Config" | `PUT …/referrals/config` | — |

## Database

Reads/writes: ReferralConfig, ReferralCodes.

## Validation / Error Handling

- No type/value → default values used; errors → SnackBar.

## Links

`docs/apis/gym-referrals-leads-communications.md`, `docs/screens/referral.md`,
`docs/screens/coupons.md`.