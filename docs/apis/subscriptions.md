# API Module: Member Subscriptions & Entitlements

Source: `lib/services/member_service.dart`, `lib/models/member_subscription.dart`,
`lib/models/member_entitlements.dart`, `lib/providers/entitlements_provider.dart`.
Backend controller/service details: **Not found in source code**.

## 1. GET /subscriptions/me

Used by: Billing Plans (`billing_plans_screen.dart`), Profile (`profile_screen.dart`).

**Request:** none. Bearer token.

**Response** (parsed by `MemberSubscription.fromJson`):

```json
{
  "planCode": "MEMBER_PREMIUM_AI",
  "status": "TRIALING",
  "trialPhase": "FULL_ACCESS",
  "startDate": "2026-08-01T00:00:00Z",
  "endDate": "2026-08-14T00:00:00Z",
  "trialStartDate": "2026-08-01T00:00:00Z",
  "trialEndDate": "2026-08-08T00:00:00Z"
}
```

| Field | Type | Description |
|---|---|---|
| planCode | String? | Plan id, e.g. `MEMBER_PREMIUM_AI` |
| status | String | `ACTIVE` / `TRIALING` / `EXPIRED` / `NONE` (default `NONE`) |
| trialPhase | String? | `FULL_ACCESS` / `LIMITED` |
| startDate / endDate | ISO date? | Plan validity |
| trialStartDate / trialEndDate | ISO date? | Trial window |

Error handling: 404 → `MemberSubscription.none()` (no subscription yet); other errors rethrown
(most screens swallow them and keep the FREE default display).

## 2. GET /subscriptions/me/entitlements

Used by: Billing Plans, Profile, and every premium gate via the shared
`entitlementsProvider` (`lib/providers/entitlements_provider.dart`).

**Request:** none.

**Response** (parsed by `MemberEntitlements.fromJson` — features are **nested**, not top-level):

```json
{
  "tier": "TRIAL_FULL",
  "features": { "aiPlans": true, "trainerChat": true, "nutritionAnalysis": true }
}
```

| Field | Type | Description |
|---|---|---|
| tier | String | `FREE` / `TRIAL_LIMITED` / `TRIAL_FULL` / `PREMIUM` |
| features.aiPlans | Boolean | AI workout plans gate |
| features.trainerChat | Boolean | Trainer chat gate |
| features.nutritionAnalysis | Boolean | Nutrition analysis gate |

Feature matrix (from model docs): FREE = none; TRIAL_LIMITED = trainerChat; TRIAL_FULL and
PREMIUM = all. `isPremium` = tier PREMIUM or TRIAL_FULL.

Error handling: 404 → `MemberEntitlements.free()`.

## 3. POST /subscriptions/me/trial

Used by: Billing Plans ("Start 7-Day Free Trial").

**Request:**

```json
{ "planCode": "MEMBER_PREMIUM_AI" }
```

`planCode` is hardcoded to `MEMBER_PREMIUM_AI` (service default).

**Response:** not parsed. Screen then reloads `GET /subscriptions/me` and
`GET /subscriptions/me/entitlements`.

## Gaps (documented, not fixed)

- **No upgrade / downgrade / cancel / purchase API is called by the frontend** — those CTAs
  only show SnackBars (see `screens/billing-plans.md`).
- **No invoice/transaction history endpoint** (`GET /subscriptions/me/invoices` is a stated
  requirement in `BACKEND_REQUIREMENTS_DASHBOARD.md`; the billing history list is hardcoded).

## Entities

MemberSubscriptions, MemberEntitlements (see `database-overview.md`).