# GAP_LOG — Frontend ↔ Backend sync tracker

| Screen / field | Endpoint tried | Result | What I need from backend dev |
|---|---|---|---|
| Billing transactions list | none found | N/A | Need a member-facing transactions/payment-history endpoint (e.g. `GET /subscriptions/me/transactions`), or confirm it's out of scope for now |
| Profile body metrics/goals/nutrition/lifetime stats | none | N/A | Out of scope per §7 — member progress/metrics history, AI coach, photo meal analysis not built yet |
| Gym owner join requests screen (`gym_owner_join_requests_screen.dart`) | `gyms/invites` vs `leads` | Pending backend clarification | Confirm whether Join Requests maps to Invite Approvals (`POST /gyms/:gymId/invites/approve`) or Walk-in Leads (`GET /gyms/:gymId/leads`) |
| Gym owner referrals tab (`gym_owner_referrals_tab.dart`) | `/coupons` vs `/referrals/config` | Pending backend clarification | UI contains coupon options (`_discountOptions`) and referral rules. Backend separates `/gyms/:gymId/coupons` from `/gyms/:gymId/referrals/config`. Confirm if referral tab should host coupon manager or referral reward config |
