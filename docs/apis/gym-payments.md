# API Module: Payments & Billing

Source: `lib/services/gym_owner_service.dart`, `lib/models/payment.dart`.
Backend context: `section2-handoff.md` — gateway-free scope: cash + manual UPI (QR on gym
profile) + bank transfer + offline card + other. Payments are never hard-deleted; voiding
restores the dues amount. Every payment gets a unique sequential receipt number (gym slug +
zero-padded counter).

Backend controller/service details: **Not found in source code** (backend external to this
repo).

## 1. GET /gyms/:gymId/payments

Used by: Payments screen. Query: `page=1`, `limit=50`, `enrollmentId` (supported by the
service, not currently passed). **Response:** list parsed by `GymPayment.fromJson`:

| Field | Aliases read | Description |
|---|---|---|
| id | — | Payment id |
| receiptNumber | — | e.g. `SMOKE-TEST-GYM-8RGT5-000042` |
| enrollmentId | — | Linked enrollment (optional) |
| memberName | `member.name` | Who paid |
| amountInr | — | Amount |
| method | — | `CASH` / `UPI_MANUAL` / `BANK_TRANSFER` / `CARD_OFFLINE` / `OTHER` |
| paidAt / voidedAt | — | Timestamps (voidedAt non-null ⇒ voided) |
| notes | — | Free text |
| isVoided | — | Derived from voidedAt / flag |

## 2. POST /gyms/:gymId/payments

Used by: Payments screen (Record Payment sheet).

```json
{ "amountInr": 5000, "method": "UPI_MANUAL", "enrollmentId": "enr_1", "paidAt": "2026-08-01T10:00:00Z", "notes": "First installment" }
```

| Field | Type | Required | Source |
|---|---|---|---|
| amountInr | Number | Yes | Amount field (`double.tryParse`, must be > 0) |
| method | String | Yes | Method chips (default CASH) |
| enrollmentId | String | No | Not passed by the current screen (ad-hoc payment) |
| paidAt | String (ISO) | No | Backdating — not passed by the current screen |
| notes | String | No | Notes field (omitted if empty) |

**Response:** `GymPayment`.

## 3. POST /gyms/:gymId/payments/:paymentId/void

Used by: Payments screen (Void, owner/manager only, confirmation dialog).

**Request:** `{}` (the screen omits `reason`). Void restores the dues amount.

## 4. GET /gyms/:gymId/payments/dues

Used by: Payments screen (Dues tab, owner/manager only). **Response:** list of
`DuesSummary`:

| Field | Aliases read | Description |
|---|---|---|
| membershipId | `userId` | Member |
| memberName | — | Name |
| enrollmentId | — | Enrollment |
| planName | — | Plan |
| dueAmountInr | `dues` | Enrollment price − Σ recorded payments |

Errors → `[]`.

## Defined but NOT called by any screen

| Method | Endpoint | Service method | Note |
|---|---|---|---|
| GET | `/gyms/:gymId/payments/:paymentId/receipt` | `getPaymentReceipt` | Printable receipt data — not wired to a screen yet |

## RBAC (from section2-handoff.md)

- Record payments: GYM_OWNER, GYM_MANAGER, FRONT_DESK.
- Browse all payments / dues dashboard / void: GYM_OWNER, GYM_MANAGER only.

## Entities

Payments; dues computed live over Enrollments + Payments (see `database-overview.md`).