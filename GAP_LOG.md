# GAP_LOG — Frontend ↔ Backend sync tracker

| Screen / field | Endpoint tried | Result | What I need from backend dev |
|---|---|---|---|
| Member home / diet / workout / progress | `GET /members/me/dashboard/today`, `diet/today`, `workout/today`, `analytics/summary` | **Resolved** — wired via `member_flow_providers` (Aug 2026) | None |
| Member rewards / leaderboard / check-in | `GET/POST /members/me/rewards/*`, `GET /leaderboards`, `GET /challenges` | **Resolved** | Community activity feed still mock (no BE endpoint) |
| Member billing checkout + invoices | `POST /subscriptions/me/checkout`, `GET /subscriptions/me/invoices` | **Resolved** — Razorpay native SDK not integrated (WebView/deep link deferred) | None for mock-provider dev |
| Meal builder + AI meals | `GET /food-items`, `POST /members/me/diet/meals`, `POST /members/me/ai/generate-meals` | **Resolved** — AI behind PremiumGate | None |
| Marketplace | `GET /marketplace/products`, `POST /marketplace/orders`, `GET /marketplace/orders/me` | **Resolved** | None |
| Online coaching | `GET /members/me/coaching` | **Resolved** — `CoachingScreen` + profile nav | Member chat UI still uses trainer pattern (separate task) |
| Member notifications | `GET /members/me/notifications` | **Resolved** — `NotificationsScreen` + home badge | Push notifications out of scope |
| Billing transactions list | `GET /subscriptions/me/invoices` | **Resolved** — invoices used instead of separate transactions endpoint | None |
| Profile body metrics/goals/nutrition/lifetime stats | none | N/A | Out of scope per §7 — member progress/metrics history, AI coach, photo meal analysis not built yet |
| Gym owner join requests screen (`gym_owner_join_requests_screen.dart`) | `GET/POST /gyms/:gymId/join-requests[/:membershipId/approve\|reject]` | **Resolved** — verified against the live OpenAPI spec (`/docs-json`); the endpoint exists and the screen's request/response shapes match it exactly. This doc predated that endpoint shipping. | None — closing this row. |
| Gym owner referrals tab (`gym_owner_referrals_tab.dart`) | `/referrals/config` | **Resolved** — the tab's `_discountOptions` are preset amounts for the `FLAT_DISCOUNT_COUPON` reward type on `/gyms/:gymId/referrals/config`, not a separate coupon manager. No conflict with `/gyms/:gymId/coupons` (used by `coupons_screen.dart`). | None — closing this row. |
