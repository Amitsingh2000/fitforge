# Screen: Home Dashboard (member)

- **File:** `lib/dashboard/screens/home_dashboard.dart`
- **Route:** `/dashboard` — member post-login landing

## Screen Information

Member home dashboard: greeting, plan tiles, and a quick-action grid. **No API calls** —
content is local/static placeholder per `BACKEND_REQUIREMENTS_DASHBOARD.md`. The only
backend touchpoint is the shared `entitlementsProvider`
(`GET /subscriptions/me/entitlements`) used to gate premium feature tiles.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Premium feature tiles (AI plans, trainer chat, nutrition) | Read-only/gated | — | `GET /subscriptions/me/entitlements` (provider) |
| Quick actions | Buttons | — | Navigation only |

## API Flow

```
Load → entitlementsProvider (auto-fetched once)  → gates premium tiles
     → "Upgrade" on locked tile → /billing-plans
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Open locked premium tile | — | Upgrade prompt → Billing Plans |
| Any other interaction | — | None (static content) |

## Database

None touched directly (tier read via entitlements).

## Links

`docs/apis/subscriptions.md`, `docs/screens/dashboard-mock-screens.md`,
`docs/screens/billing-plans.md`.