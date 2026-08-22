# Normal User (Member) Frontend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace member mock data with live API integration across gym-member and individual paths, phased to match the completed backend normal-user module.

**Architecture:** Riverpod providers → domain services → Dio (`kApiBase`). Screens stay in `lib/dashboard/`; new marketplace under `lib/marketplace/`. Dual-path behavior driven by entitlements + gym membership + coaching assignment.

**Tech stack:** Flutter 3.x, Riverpod, Dio, existing theme/widgets.

**Spec:** `docs/superpowers/specs/2026-08-22-normal-user-fe-design.md`

**Backend reference:** `GymOS-BE/backend/docs/superpowers/specs/2026-08-22-normal-user-module-design.md`

**OpenAPI:** `http://127.0.0.1:3000/docs-json` (local) or prod `/docs-json`

---

## File Structure (new / modified)

```
fitforge/lib/
  models/                    # NEW: member domain DTOs
  services/
    member_dashboard_service.dart   # NEW
    gamification_service.dart       # NEW
    nutrition_service.dart          # NEW
    billing_service.dart            # NEW (extend beyond trial)
    coaching_service.dart           # NEW
    marketplace_service.dart        # NEW
    api_client.dart                 # FIX refresh URL
  providers/
    member_flow_providers.dart      # NEW
  dashboard/
    home_dashboard.dart             # MODIFY
    diet_plan_screen.dart           # MODIFY
    exercise_plan_screen.dart       # MODIFY
    progress_analytics_screen.dart  # MODIFY
    rewards_screen.dart             # MODIFY
    leaderboard_screen.dart         # MODIFY
    meal_builder_screen.dart        # MODIFY
    billing_plans_screen.dart       # MODIFY
    widgets/premium_gate.dart       # WIRE
  marketplace/                      # NEW module
    screens/
  coaching/                         # NEW (minimal)
    coaching_screen.dart
  notifications/                    # NEW (minimal)
    notifications_screen.dart
fitforge/test/
  member_dashboard_test.dart        # NEW
  premium_gate_test.dart            # NEW
fitforge/GAP_LOG.md                 # UPDATE each phase
```

---

## Phase 0: Foundation (~2–3 days)

### Task 0.1: Fix api_client token refresh

**Files:**
- Modify: `lib/services/api_client.dart`

- [ ] **Step 1:** Locate refresh-token Dio instance; replace hardcoded prod URL with `kApiBase` (same as main client).
- [ ] **Step 2:** Run `flutter analyze lib/services/api_client.dart` — expect no issues.
- [ ] **Step 3:** Manual: login with expired token simulation (or force 401) — refresh should hit same host as `--dart-define=API_BASE`.

### Task 0.2: Member dashboard models

**Files:**
- Create: `lib/models/dashboard_today.dart`, `daily_task.dart`, `workout_today.dart`, `diet_today.dart`, `analytics_summary.dart`, `member_notification.dart`

- [ ] **Step 1:** Read BE DTO shapes from OpenAPI or `GymOS-BE/backend/src/modules/member-dashboard/` controllers.
- [ ] **Step 2:** Add `fromJson` / `toJson` for each model matching envelope `data` payload.
- [ ] **Step 3:** Run `flutter analyze lib/models/` — clean.

### Task 0.3: Gamification + nutrition + billing + coaching + marketplace models

**Files:**
- Create: `lib/models/rewards_overview.dart`, `leaderboard_entry.dart`, `challenge.dart`, `food_item.dart`, `checkout_session.dart`, `invoice.dart`, `coaching_assignment.dart`, `marketplace_product.dart`, `marketplace_order.dart`

- [ ] **Step 1:** Mirror BE response types from respective modules.
- [ ] **Step 2:** Run `flutter analyze lib/models/` — clean.

### Task 0.4: member_dashboard_service

**Files:**
- Create: `lib/services/member_dashboard_service.dart`
- Test: `test/member_dashboard_service_test.dart` (optional unit with mock Dio)

- [ ] **Step 1:** Follow pattern from `lib/services/gym_owner_service.dart` — class taking `Dio`, methods per endpoint table in spec.
- [ ] **Step 2:** Implement: `getToday()`, `logWater()`, `logSteps()`, `getTasks()`, `toggleTask()`, `getWorkoutToday()`, `getDietToday()`, `checkMeal()`, `getAnalyticsSummary()`, `exportAnalytics()`, `getNotifications()`, `markNotificationRead()`.
- [ ] **Step 3:** Run `flutter analyze lib/services/member_dashboard_service.dart`.

### Task 0.5: Remaining services

**Files:**
- Create: `gamification_service.dart`, `nutrition_service.dart`, `billing_service.dart`, `coaching_service.dart`, `marketplace_service.dart`

- [ ] **Step 1:** Implement gamification: overview, check-in, leaderboards (query `scope`), challenges, store redeem.
- [ ] **Step 2:** Implement nutrition: food catalog, create meal, AI generate.
- [ ] **Step 3:** Implement billing: checkout, list invoices.
- [ ] **Step 4:** Implement coaching: get assignment, request switch.
- [ ] **Step 5:** Implement marketplace: products, offers, create order, my orders.
- [ ] **Step 6:** Run `flutter analyze lib/services/`.

### Task 0.6: member_flow_providers

**Files:**
- Create: `lib/providers/member_flow_providers.dart`

- [ ] **Step 1:** Add `memberDashboardServiceProvider`, `gamificationServiceProvider`, etc. (mirror `gymOwnerServiceProvider` pattern).
- [ ] **Step 2:** Add `todayDashboardProvider`, `dietTodayProvider`, `workoutTodayProvider`, `analyticsSummaryProvider`, `rewardsOverviewProvider`, `leaderboardProvider(scope)`, `coachingProvider`, `marketplaceProductsProvider`.
- [ ] **Step 3:** Export from provider file; run `flutter analyze`.

### Task 0.7: Wire PremiumGate + entitlements invalidation helper

**Files:**
- Modify: `lib/dashboard/widgets/premium_gate.dart`
- Create helper in `member_flow_providers.dart`: `invalidateMemberCommerce(ref)`

- [ ] **Step 1:** Ensure `PremiumGate` reads `entitlementsProvider` and shows lock UI + upgrade CTA.
- [ ] **Step 2:** Add `invalidateMemberCommerce` to refresh entitlements + subscription after checkout.
- [ ] **Step 3:** Run `flutter analyze`.

**Phase 0 checkpoint:** Services compile; providers exist; api_client fixed. No screen changes yet.

---

## Phase 1: Daily loop (~3–4 days)

### Task 1.1: home_dashboard.dart

**Files:**
- Modify: `lib/dashboard/home_dashboard.dart`

- [ ] **Step 1:** Remove mock lists/constants; `ref.watch(todayDashboardProvider)`.
- [ ] **Step 2:** Wire water + steps buttons to service mutations; `ref.invalidate(todayDashboardProvider)` on success.
- [ ] **Step 3:** Tasks section from API; toggle via `toggleTask`.
- [ ] **Step 4:** Show gym name chip if profile/subscription indicates gym member (reuse existing profile provider).
- [ ] **Step 5:** Loading/error via `StateViews` pattern used in owner dashboard.
- [ ] **Step 6:** Run app → home tab shows live data against local BE.

### Task 1.2: diet_plan_screen.dart

**Files:**
- Modify: `lib/dashboard/diet_plan_screen.dart`

- [ ] **Step 1:** `ref.watch(dietTodayProvider)`.
- [ ] **Step 2:** Meal check toggles → `checkMeal(mealId)`.
- [ ] **Step 3:** Empty state: gym → "Trainer hasn't assigned a plan"; individual → CTA to meal builder.
- [ ] **Step 4:** Manual QA both user types.

### Task 1.3: exercise_plan_screen.dart

**Files:**
- Modify: `lib/dashboard/exercise_plan_screen.dart`

- [ ] **Step 1:** `ref.watch(workoutTodayProvider)`.
- [ ] **Step 2:** Render exercises/sets from API; empty states per dual-path rules.
- [ ] **Step 3:** Manual QA.

### Task 1.4: progress_analytics_screen.dart

**Files:**
- Modify: `lib/dashboard/progress_analytics_screen.dart`

- [ ] **Step 1:** `ref.watch(analyticsSummaryProvider)`.
- [ ] **Step 2:** Replace mock charts with API metrics (keep existing chart widgets; feed real numbers).
- [ ] **Step 3:** Manual QA.

### Task 1.5: Widget test — home dashboard

**Files:**
- Create: `test/member_dashboard_test.dart`

- [ ] **Step 1:** Override `todayDashboardProvider` with fake data.
- [ ] **Step 2:** Pump `HomeDashboard`; expect task title visible.
- [ ] **Step 3:** Run `flutter test test/member_dashboard_test.dart` — PASS.

**Phase 1 checkpoint:** 4 main tabs live. Update `GAP_LOG.md` rows for home/diet/workout/progress.

---

## Phase 2: Commerce & coaching (~2–3 days)

### Task 2.1: billing_plans_screen.dart

**Files:**
- Modify: `lib/dashboard/billing_plans_screen.dart`

- [ ] **Step 1:** Keep trial display from existing subscription provider.
- [ ] **Step 2:** Premium CTA → `billingService.checkout(planId, idempotencyKey)`.
- [ ] **Step 3:** On success: show payment URL / mock success dialog; call `invalidateMemberCommerce`.
- [ ] **Step 4:** Invoices list section from `GET subscriptions/me/invoices`.
- [ ] **Step 5:** Manual QA: mock checkout (`PAYMENT_PROVIDER=mock` on BE).

### Task 2.2: Coaching screen (individual path)

**Files:**
- Create: `lib/coaching/coaching_screen.dart`
- Modify: profile or billing navigation to link

- [ ] **Step 1:** `ref.watch(coachingProvider)` — show assigned coach name, status.
- [ ] **Step 2:** Request switch button → API.
- [ ] **Step 3:** Hide or show gym-specific copy based on path.
- [ ] **Step 4:** Manual QA after premium checkout on BE e2e fixture pattern.

### Task 2.3: Member chat entry (if thread exists)

**Files:**
- Modify: existing chat navigation or add link from coaching/home

- [ ] **Step 1:** Reuse trainer chat screen pattern with member role + `gymId` nullable for online coach.
- [ ] **Step 2:** Gate with `trainerChat` entitlement via PremiumGate.
- [ ] **Step 3:** Manual QA with online coaching assignment from BE.

**Phase 2 checkpoint:** Individual can complete trial → premium → coach visible. Update GAP_LOG billing/coaching rows.

---

## Phase 3: Gamification (~2 days)

### Task 3.1: rewards_screen.dart

**Files:**
- Modify: `lib/dashboard/rewards_screen.dart`

- [ ] **Step 1:** `rewardsOverviewProvider` — XP, streak, badges.
- [ ] **Step 2:** Daily check-in button → POST check-in; invalidate overview.
- [ ] **Step 3:** Points store section (list + redeem) if UI slot exists; else sub-screen.

### Task 3.2: leaderboard_screen.dart

**Files:**
- Modify: `lib/dashboard/leaderboard_screen.dart`

- [ ] **Step 1:** Scope selector: GYM (if member) vs ONLINE/GLOBAL.
- [ ] **Step 2:** `leaderboardProvider(scope)` — replace mock ranks.
- [ ] **Step 3:** Challenges list + join from gamification service.

**Phase 3 checkpoint:** Rewards + leaderboard live. GAP_LOG gamification rows closed.

---

## Phase 4: Nutrition & AI (~2–3 days)

### Task 4.1: meal_builder_screen.dart — catalog

**Files:**
- Modify: `lib/dashboard/meal_builder_screen.dart`

- [ ] **Step 1:** Search/filter → `GET food-items`.
- [ ] **Step 2:** Build meal → `POST diet/meals`; invalidate diet today.

### Task 4.2: AI meal generation

**Files:**
- Modify: `meal_builder_screen.dart` or new bottom sheet

- [ ] **Step 1:** Wrap AI entry with `PremiumGate(feature: aiPlans)`.
- [ ] **Step 2:** Form → `POST ai/generate-meals`; display generated meals + provider label.
- [ ] **Step 3:** Manual QA with BE `MEAL_AI_PROVIDER=groq`.

**Phase 4 checkpoint:** Meal builder + AI gated. GAP_LOG nutrition row closed.

---

## Phase 5: Marketplace (~2–3 days)

### Task 5.1: Marketplace screens

**Files:**
- Create: `lib/marketplace/screens/marketplace_home.dart`, `product_detail.dart`, `orders_screen.dart`

- [ ] **Step 1:** Product grid + offers from API; optional gym filter query param.
- [ ] **Step 2:** Order flow → marketplace checkout → reuse billing invalidation.
- [ ] **Step 3:** Order history + digital fulfillment code display.
- [ ] **Step 4:** Add entry from Profile or Home section (not new tab).
- [ ] **Step 5:** Manual QA mirroring `marketplace-order.e2e-spec.ts`.

**Phase 5 checkpoint:** Marketplace browse + order works. GAP_LOG marketplace row closed.

---

## Phase 6: Harden (~2 days)

### Task 6.1: Notifications

**Files:**
- Create: `lib/notifications/notifications_screen.dart`
- Modify: `home_dashboard.dart` — unread badge

- [ ] **Step 1:** List + mark read from member dashboard notifications API.
- [ ] **Step 2:** Navigate from home app bar.

### Task 6.2: Analytics CSV export

**Files:**
- Modify: `progress_analytics_screen.dart`

- [ ] **Step 1:** Export button → `GET analytics/export`; web download / mobile share via `share_plus` if already in pubspec else url_launcher.

### Task 6.3: Premium gate widget test

**Files:**
- Create: `test/premium_gate_test.dart`

- [ ] **Step 1:** Locked entitlements → shows upgrade; unlocked → shows child.
- [ ] **Step 2:** Run `flutter test` — PASS.

### Task 6.4: QA checklist + GAP_LOG final

**Files:**
- Modify: `GAP_LOG.md`

- [ ] **Step 1:** Run manual QA script (below) against local BE with member-journey seed data.
- [ ] **Step 2:** Mark all member rows resolved or document remaining gaps.
- [ ] **Step 3:** Run full `flutter analyze` + `flutter test`.

---

## Manual QA Checklist (mirrors BE member-journey)

**Gym member path:**
1. Login as gym member with assigned diet/workout
2. Home: water, steps, tasks mutate and persist
3. Diet: check meals; progress updates
4. Workout: today's plan visible
5. Leaderboard scope GYM shows ranks
6. Marketplace: gym-filtered product if seeded

**Individual path:**
1. Register → onboarding → trial entitlements
2. Premium mock checkout → entitlements refresh
3. Coaching assignment visible
4. AI meals (premium) returns meals
5. Marketplace order completes

**Regression:**
1. Gym owner dashboard loads
2. Trainer schedule loads

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-08-22-normal-user-fe.md`.

**Two execution options:**

1. **Subagent-driven (this session)** — dispatch fresh subagent per task, review between tasks, fast iteration  
2. **Parallel session (separate)** — open new session with executing-plans, batch execution with checkpoints  

**Which approach?**

If no reply: start **Phase 0** in this session (subagent-driven, beginning with Task 0.1 api_client fix).
