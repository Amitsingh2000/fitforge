# API Module: Coupons

Source: `lib/services/gym_owner_service.dart`, `lib/models/coupon.dart`.
Backend context: `section2-handoff.md` — owner-created codes, `PERCENT` or `FLAT`, validity
window, usage cap, optional plan restriction. Codes are case-insensitive on redemption.
Deactivate is a soft-delete so redemption history survives.

Backend controller/service details: **Not found in source code** (backend external to this
repo).

## 1. GET /gyms/:gymId/coupons

Used by: Coupons screen. Query: `includeInactive=true` when the toggle is on. **Response:**
list parsed by `GymCoupon.fromJson`:

| Field | Aliases read | Description |
|---|---|---|
| id | — | Coupon id |
| code | — | Code |
| type | `discountType` | `PERCENT` / `FLAT` |
| value | `discountValue` | Percent (0–100) or INR amount |
| validFrom / validUntil | — | Validity window |
| usageLimit / usageCount | — | Cap and redemptions |
| applicablePlanIds | — | Plan restriction |
| isActive | — | Active flag |

## 2. POST /gyms/:gymId/coupons

Used by: Coupons screen (New Coupon sheet).

```json
{ "code": "FIT10", "type": "PERCENT", "value": 10, "usageLimit": 50 }
```

| Field | Type | Required | Source |
|---|---|---|---|
| code | String | Yes | Form (uppercased, `[a-zA-Z0-9_\-]` input formatter) |
| type | String | Yes | Type chips (default PERCENT) |
| value | Number | Yes | `double.tryParse` (must be valid + code non-empty) |
| usageLimit | Number | No | Optional `int.tryParse` |
| validFrom / validUntil | ISO date | No | Not passed by the current screen |
| applicablePlanIds | String[] | No | Not passed by the current screen |

**Response:** `GymCoupon`.

## 3. DELETE /gyms/:gymId/coupons/:couponId

Used by: Coupons screen (Deactivate). Soft-delete; redemption history survives.

## 4. GET /gyms/:gymId/coupons/:couponId/redemptions

Used by: Coupons screen (History sheet). **Response:** list of raw maps; the screen reads
`memberName`, `redeemedAt` per row. Errors → `[]`.

## Defined but NOT called by any screen

| Method | Endpoint | Service method | Note |
|---|---|---|---|
| PATCH | `/gyms/:gymId/coupons/:couponId` | `updateCoupon` | Toggle active / update usageLimit — not wired to a screen |

## RBAC (from section2-handoff.md)

Coupons (create/deactivate): GYM_OWNER, GYM_MANAGER.

## Entities

Coupons, CouponRedemptions, MembershipPlans (via `applicablePlanIds`; see
`database-overview.md`).