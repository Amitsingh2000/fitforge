# Screens: Member Dashboard & Mock Feature Screens

- **Files:** `lib/dashboard/screens/{home_dashboard,diet_plan_screen,meal_builder_screen,exercise_plan_screen,exercise_detail_screen,progress_analytics_screen,rewards_screen,leaderboard_screen}.dart`
- **Route:** `/dashboard` (Home Dashboard); the rest are reached from its quick-action grid

## Screen Information

The member home dashboard is the post-login landing for members. **It makes no API calls**
— the greeting, plan tiles, and stats are local/static placeholders. Its quick actions open
feature screens that are also mock (static UI per `BACKEND_REQUIREMENTS_DASHBOARD.md`),
with premium gates (`entitlementsProvider`) that DO hit the backend.

## Screens and their APIs

| Screen | File | Real API calls |
|---|---|---|
| Home Dashboard | `home_dashboard.dart` | None (static; uses cached user/tier only) |
| Diet Plan | `diet_plan_screen.dart` | None (static sample meal plan) |
| Meal Builder | `meal_builder_screen.dart` | None (static ingredient builder) |
| Exercise Plan | `exercise_plan_screen.dart` | None (static plan list) |
| Exercise Detail | `exercise_detail_screen.dart` | None (static video/description) |
| Progress Analytics | `progress_analytics_screen.dart` | None (static chart data) |
| Rewards | `rewards_screen.dart` | None (static reward cards) |
| Leaderboard | `leaderboard_screen.dart` | None (static ranks) |

**Shared exception:** premium feature tiles gate on `entitlementsProvider`
(`GET /subscriptions/me/entitlements`, see `docs/apis/subscriptions.md`) — locked tiles show
an upgrade prompt that navigates to Billing Plans.

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Open any premium tile | `GET /subscriptions/me/entitlements` (provider) | Unlocks/locks features |
| "Upgrade" prompt | — | Navigation to `/billing-plans` |
| Every other interaction | — | No network |

## Database

None touched by these screens (UI-only placeholders).

## Backend status (per `BACKEND_REQUIREMENTS_DASHBOARD.md`)

These screens are documented requirements; the AI-plan endpoints
(`/members/me/plans`, `/members/me/nutrition`, …) are **not yet consumed by the app** —
see `docs/api-index.md` "Required but not called" section.

## Links

`docs/apis/subscriptions.md`, `docs/screens/billing-plans.md`,
`docs/screens/onboarding.md`.