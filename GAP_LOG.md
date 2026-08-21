# GAP_LOG — Frontend ↔ Backend sync tracker

| Screen / field | Endpoint tried | Result | What I need from backend dev |
|---|---|---|---|
| Billing transactions list | none found | N/A | Need a member-facing transactions/payment-history endpoint (e.g. `GET /subscriptions/me/transactions`), or confirm it's out of scope for now |
| Profile body metrics/goals/nutrition/lifetime stats | none | N/A | Out of scope per §7 — member progress/metrics history, AI coach, photo meal analysis not built yet |
| Gym owner join requests screen (`gym_owner_join_requests_screen.dart`) | `GET/POST /gyms/:gymId/join-requests[/:membershipId/approve\|reject]` | **Resolved** — verified against the live OpenAPI spec (`/docs-json`); the endpoint exists and the screen's request/response shapes match it exactly. This doc predated that endpoint shipping. | None — closing this row. |
| Gym owner referrals tab (`gym_owner_referrals_tab.dart`) | `/referrals/config` | **Resolved** — the tab's `_discountOptions` are preset amounts for the `FLAT_DISCOUNT_COUPON` reward type on `/gyms/:gymId/referrals/config`, not a separate coupon manager. No conflict with `/gyms/:gymId/coupons` (used by `coupons_screen.dart`). | None — closing this row. |
