# Screen: Coupons

- **File:** `lib/gym_owner/screens/coupons_screen.dart`
- **Route:** Tab within the gym owner shell

## Screen Information

Coupon management: list (with retired toggle), create, deactivate (soft-delete), and view
redemption history per coupon.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Code | Text | Required; `[A-Za-z0-9_-]` formatter (uppercased) | `POST …/coupons.code` |
| Type | Chips: PERCENT / FLAT | Required (default PERCENT) | `POST …/coupons.type` |
| Value | Number | `double.tryParse` required | `POST …/coupons.value` (percent 0–100 / INR) |
| Usage Limit | Number | Optional (`int.tryParse`) | `POST …/coupons.usageLimit` |

## API Flow

```
Load     → GET /gyms/:gymId/coupons[?includeInactive=true]   (errors → [])
Create   → POST /gyms/:gymId/coupons {code, type, value, usageLimit?} → reload
Deactivate → DELETE /gyms/:gymId/coupons/:couponId → reload
History  → GET /gyms/:gymId/coupons/:couponId/redemptions   (errors → [])
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Toggle retired | `GET …/coupons?includeInactive=true` | Reload |
| "New Coupon" → Save | `POST …/coupons` | Validation → SnackBar |
| Deactivate | `DELETE …/coupons/:couponId` | Confirmation; soft-delete |
| History sheet | `GET …/coupons/:couponId/redemptions` | Rows: memberName, redeemedAt |

## Database

Reads/writes: Coupons, CouponRedemptions.

## Validation / Error Handling

- Empty code / invalid value → SnackBar; server `{message}` → SnackBar.

## Links

`docs/apis/gym-coupons.md`, `docs/screens/enrollment.md`,
`docs/screens/gym-owner-referrals-tab.md`.