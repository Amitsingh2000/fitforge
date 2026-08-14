# Screen: Billing Plans

- **File:** `lib/dashboard/screens/billing_plans_screen.dart`
- **Route:** `/billing-plans`

## Screen Information

Member subscription screen: shows the current plan, a 7-day free trial CTA, and plan
comparison. Feature gates read the same entitlements provider as the dashboard.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Plan selection | Radio/selection | Plan must be selected (default shown) | `POST /subscriptions/me/trial.planCode` |

## API Flow

```
Load   → GET /subscriptions/me              (plan + trial status; 404 → NONE)
       → GET /subscriptions/me/entitlements (tier/features; 404 → FREE)
Trial  → POST /subscriptions/me/trial {planCode: "MEMBER_PREMIUM_AI"}
       → reload both GETs
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load screen | `GET /subscriptions/me`, `GET /subscriptions/me/entitlements` | Parallel; errors → SnackBar |
| "Start 7-Day Free Trial" | `POST /subscriptions/me/trial` | `planCode` hardcoded `MEMBER_PREMIUM_AI`; success → reload |
| Buy / Upgrade / Downgrade / Cancel CTAs | — | **SnackBar only** ("This feature is coming soon") — no API wired |
| Billing history list | — | Hardcoded rows — no invoice endpoint consumed |

## Database

Reads: MemberSubscriptions, MemberEntitlements.

## Validation / Error Handling

- No plan selected → prompt to pick one.
- Trial start failure → SnackBar with server message.
- 404s on the GETs are treated as "FREE tier" (graceful degrade).

## Links

`docs/apis/subscriptions.md`, `docs/screens/dashboard-mock-screens.md`,
`docs/screens/profile.md`.