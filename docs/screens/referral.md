# Screen: Referrals

- **File:** `lib/dashboard/screens/referral_screen.dart`
- **Route:** `MaterialPageRoute` from the dashboard (gym required)

## Screen Information

Member-side referral hub: share the personal code, see the referral list, and redeem the
reward once a referral qualifies. Requires `currentGymIdProvider` (member of a gym).

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Share code | Read-only (copy/share) | — | `GET /gyms/:gymId/referrals/my-code` |
| Referral rows | Read-only | — | `GET /gyms/:gymId/referrals/my-referrals` |
| Redeem button | Button | Reward must be available | `POST /gyms/:gymId/referrals/redeem` |

## API Flow

```
Load    → GET /gyms/:gymId/referrals/my-code
        → GET /gyms/:gymId/referrals/my-referrals
Redeem  → POST /gyms/:gymId/referrals/redeem {code}
        → reload both GETs
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load screen | `GET …/referrals/my-code` + `GET …/referrals/my-referrals` | Parallel |
| Share | — | Clipboard / system share sheet |
| Tap "Redeem" | `POST …/referrals/redeem` | Success → SnackBar + reload |

## Database

Reads/writes: ReferralCodes, Referrals (via backend).

## Validation / Error Handling

- Reward flow: `FREE_DAYS` extends the member's enrollment `endDate`;
  `FLAT_DISCOUNT_COUPON` auto-issues a single-use coupon — both only after the friend's
  first purchase qualifies (backend rule).
- Load failures → error state + retry; redeem failures → SnackBar.

## Links

`docs/apis/gym-member-actions.md`, `docs/screens/gym-owner-referrals-tab.md`,
`docs/screens/join-gym.md`.