# Screen: Payments

- **File:** `lib/gym_owner/screens/payments_screen.dart`
- **Route:** Tab within the gym owner shell

## Screen Information

Payments ledger (All tab) + dues dashboard (Dues tab, owner/manager only). Record cash/UPI
payments, void mistakes (restores dues), browse receipts (receipt printing endpoint not
wired).

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Amount (₹) | Number | `double.tryParse`, > 0 | `POST …/payments.amountInr` |
| Method | Chips: CASH / UPI_MANUAL / BANK_TRANSFER / CARD_OFFLINE / OTHER | Required (default CASH) | `POST …/payments.method` |
| Notes | Text | Optional (omitted if empty) | `POST …/payments.notes` |
| Dues rows | Read-only | — | `GET …/payments/dues` |

## API Flow

```
Load   → GET /gyms/:gymId/payments?page=1&limit=50   (errors → [])
       → GET /gyms/:gymId/payments/dues              (errors → []; owner/manager only)
Record → POST /gyms/:gymId/payments {amountInr, method, notes?} → reload
Void   → POST /gyms/:gymId/payments/:paymentId/void {} → reload
```

> The current screen never sends `enrollmentId`/`paidAt` (ad-hoc payments). The enrollment
> picker exists in the API (`enrollmentId` query for filtering) but is not used here.

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Tab switch | `GET …/payments` / `GET …/payments/dues` | Reload per tab |
| "Record Payment" | `POST …/payments` | — |
| "Void" | `POST …/payments/:paymentId/void` | Owner/manager; confirmation |
| Receipt download | — | No API wired (`getPaymentReceipt` unused) |

## Database

Reads/writes: Payments; dues computed live over Enrollments + Payments.

## Validation / Error Handling

- Invalid/zero amount → SnackBar; void requires confirmation; errors → SnackBar.

## Links

`docs/apis/gym-payments.md`, `docs/screens/enrollment.md`,
`docs/screens/member-detail.md`.