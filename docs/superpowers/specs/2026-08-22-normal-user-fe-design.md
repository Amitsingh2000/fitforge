# Normal User (Member) Frontend — Design Spec

**Date:** 2026-08-22  
**App:** FitForge Flutter (`/fitforge`)  
**Backend spec:** `GymOS-BE/backend/docs/superpowers/specs/2026-08-22-normal-user-module-design.md`  
**OpenAPI:** `{API_BASE}/docs-json` (Swagger at `/docs`)

## Goal

Wire the existing member UI (currently mock-driven) to the production normal-user backend across **both user paths in parallel per phase**:

- **Gym member path** — joined a gym, trainer-assigned plans, gym-scoped leaderboard
- **Individual path** — no gym / premium, online coaching, AI meals, marketplace checkout

Do **not** rebuild screens from scratch. Swap mock data for API-backed Riverpod providers using the same patterns as gym-owner and trainer modules.

## Current State

| Area | FE | BE |
|---|---|---|
| Auth, onboarding, trial, entitlements | Wired | Done |
| Gym join, QR check-in, referrals | Wired | Done |
| Home / diet / workout / progress tabs | **Mock UI** | Done |
| Rewards, leaderboard | **Mock UI** | Done |
| Billing (beyond trial read) | **Partial mock** | Done |
| Meal builder | **Static catalog** | Done |
| Coaching, member chat, notifications | **Missing** | Done |
| Marketplace | **Missing** | Done |
| AI meal generate | **Missing** (PremiumGate unused) | Done |

Gym owner (~23 screens) and trainer (~17 screens) are production reference implementations for service + provider + screen patterns.

## Architecture

```
Screen (dashboard/*)
  → Riverpod provider (providers/member_flow_providers.dart)
    → Service (services/*_service.dart)
      → Dio (api_client.dart) → BE envelope { success, data, timestamp }
```

- **State:** `flutter_riverpod` — `FutureProvider`, `AsyncNotifier` for mutations
- **Errors:** `api_failure.dart` friendly messages; `state_views.dart` loading/empty/error
- **Gating:** `PremiumGate` + `entitlementsProvider` for `aiPlans`, `trainerChat`, etc.
- **Dual path:** Screens show gym-specific vs individual sections based on `MemberEntitlements` + optional `CoachingAssignment` + gym membership flag from profile/subscription context

## Global Constraints

- Preserve existing dark theme (`lib/theme/app_theme.dart`) and glass cards
- API envelope: unwrap `response.data` in Dio interceptor (already done)
- Auth: Bearer JWT; 401 refresh chain (fix refresh base URL to use `kApiBase`)
- No new state-management library
- Reuse `AdaptiveNavShell` 5-tab shell unless a 6th tab is explicitly needed (marketplace lives under Profile or Home section, not a new tab in v1)
- Platform: iOS, Android, Web (`vercel.json` SPA)
- Local dev: `--dart-define=API_BASE=http://127.0.0.1:3000/api/v1`
- Commits: only when human asks

## Phase 0 — Foundation

### New services

| Service | Endpoints |
|---|---|
| `member_dashboard_service.dart` | `GET dashboard/today`, `POST logs/water`, `POST logs/steps`, `GET/PATCH tasks`, `GET workout/today`, `GET diet/today`, `PATCH diet/meals/:id/check`, `GET analytics/summary`, `GET analytics/export`, `GET/POST notifications` |
| `gamification_service.dart` | `GET rewards/overview`, `POST rewards/check-in`, `GET leaderboards`, `GET/POST challenges`, `GET/POST rewards/store` |
| `nutrition_service.dart` | `GET food-items`, `POST diet/meals`, `POST ai/generate-meals` |
| `billing_service.dart` | `POST subscriptions/me/checkout`, `GET subscriptions/me/invoices` |
| `coaching_service.dart` | `GET members/me/coaching`, `POST members/me/coaching/request-switch` |
| `marketplace_service.dart` | `GET marketplace/products`, `offers`, `POST orders`, `GET orders/me` |

### New models

Under `lib/models/`: `dashboard_today.dart`, `daily_task.dart`, `workout_today.dart`, `diet_today.dart`, `analytics_summary.dart`, `rewards_overview.dart`, `leaderboard.dart`, `food_item.dart`, `checkout_session.dart`, `invoice.dart`, `coaching_assignment.dart`, `marketplace_product.dart`, `marketplace_order.dart`, etc.

### Providers

`lib/providers/member_flow_providers.dart` — one provider per aggregate (today dashboard, diet, workout, rewards, leaderboard scoped, coaching, marketplace products).

### Fixes (same phase)

1. `api_client.dart` — token refresh Dio must use `kApiBase`, not hardcoded Render URL
2. Wire `PremiumGate` on AI entry points
3. After checkout success → `ref.invalidate(entitlementsProvider)` + `ref.invalidate(memberSubscriptionProvider)`

## Phase 1 — Daily loop (both paths)

| Screen | Gym path | Individual path |
|---|---|---|
| `home_dashboard.dart` | Show gym name if member; tasks from API | Same API; no gym badge |
| `diet_plan_screen.dart` | Trainer-assigned plan meals + checks | Empty state → link to meal builder |
| `exercise_plan_screen.dart` | Trainer plan day | Empty state → generic workout or CTA |
| `progress_analytics_screen.dart` | Same analytics API | Same |

**Dual-path UX rules:**

- If `GET workout/today` returns null → show "No plan assigned" with gym: "Ask your trainer" / individual: "Upgrade for coaching"
- Water/steps/tasks work identically for both paths

## Phase 2 — Commerce & coaching (individual-heavy, gym-aware)

| Feature | Gym path | Individual path |
|---|---|---|
| `billing_plans_screen.dart` | Optional gym dues remain separate (owner-recorded) | Premium checkout + invoices |
| Coaching card | Usually N/A (gym trainer) | `GET coaching` after premium |
| Member chat | Gym trainer thread if assigned | Online coach thread (`gymId=null`) |

Checkout flow: idempotency key (UUID) → `POST checkout` → show mock/Razorpay widget placeholder (WebView/deep link follow-up) → poll subscription/entitlements.

## Phase 3 — Gamification (both paths)

| Feature | Gym path | Individual path |
|---|---|---|
| Leaderboard | Default scope `GYM` if member | Default `ONLINE` or `GLOBAL` |
| Rewards / check-in | Same API | Same |
| Challenges | Gym-scoped if available | Global / online cohort |

## Phase 4 — Nutrition & AI (both paths, gated)

- Meal builder: `GET food-items?search=&category=`
- Save custom meal → logs to today
- AI generate sheet: `POST ai/generate-meals` behind `PremiumGate` (`aiPlans`)
- Show `provider` field from response (e.g. groq)

## Phase 5 — Marketplace (both paths)

New `lib/marketplace/screens/`:

- Product list (+ optional gym filter)
- Offers carousel
- Product detail → order → checkout (reuse billing)
- Order history + digital code display

Browse is free; purchase uses same checkout infrastructure.

## Phase 6 — Harden

- Notifications screen + home badge
- Analytics CSV export (web: anchor download; mobile: share)
- Real QR scanner (`mobile_scanner`) optional upgrade
- Widget tests: home dashboard with fake provider
- Integration smoke script / manual QA checklist mirroring BE `member-journey.e2e`
- Update `GAP_LOG.md` — close billing transactions row (use invoices)

## Testing Strategy

| Layer | Scope |
|---|---|
| Unit | Model `fromJson`, service parsing with mocked Dio |
| Widget | Home tab loading/error/data states; PremiumGate locked/unlocked |
| Manual QA | Full journey: gym member + individual premium (checklist in plan) |
| Regression | Owner/trainer flows unchanged — spot-check after each phase |

## Success Criteria

1. Member home/diet/workout/progress show **live BE data** (not mocks)
2. Individual user can: trial → premium checkout → see coach → AI meals → marketplace order
3. Gym member can: daily loop + gym leaderboard + gym marketplace products
4. No regressions in owner/trainer dashboards
5. `GAP_LOG.md` updated; known mocks removed from member screens

## Out of Scope (v1)

- Razorpay native SDK (show checkout URL / WebView stub; mock provider for dev)
- Photo meal analysis camera flow
- Push notifications (in-app feed only)
- Offline-first sync / local DB
- 6th nav tab for marketplace (use Profile section entry)
