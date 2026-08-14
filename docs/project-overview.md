# FitForge — Project Overview

## 1. What this document is

A structural walkthrough of the FitForge Flutter application: the code layout, the architecture
layers, and the full data-flow from screen to backend and back. Everything below is derived from
the source code in this repository.

## 2. Application architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ UI LAYER (lib/<portal>/screens/*.dart)                          │
│   Member dashboard · Gym owner · Trainer · Auth · Onboarding    │
│   + widgets/ (reusable cards, sheets, state views)              │
└───────────────┬─────────────────────────────────────────────────┘
                │ ref.watch / ref.read (flutter_riverpod)
┌───────────────▼─────────────────────────────────────────────────┐
│ STATE LAYER (lib/providers/*.dart)                              │
│   authProvider          — login/register/logout/session restore │
│   onboardingProvider    — wizard state + progressive save        │
│   entitlementsProvider  — premium feature-gating truth           │
│   gymProvider           — selected gym context (gymId)           │
│   api_client.dart       — dioProvider + token providers          │
└───────────────┬─────────────────────────────────────────────────┘
                │ service method calls
┌───────────────▼─────────────────────────────────────────────────┐
│ SERVICE LAYER (lib/services/*.dart)                             │
│   MemberService · GymOwnerService · TrainerService              │
│   MediaUploadService · TokenStorageService                       │
└───────────────┬─────────────────────────────────────────────────┘
                │ Dio instance (single, interceptors)
┌───────────────▼─────────────────────────────────────────────────┐
│ HTTP LAYER (Dio + interceptors in api_client.dart)              │
│   1. attach Authorization: Bearer <accessToken>                  │
│   2. unwrap { success, data } envelope                          │
│   3. on 401 → shared POST /auth/refresh → retry once             │
│   4. normalize error message (message: string|string[])          │
└───────────────┬─────────────────────────────────────────────────┘
                │ HTTPS JSON
┌───────────────▼─────────────────────────────────────────────────┐
│ BACKEND (external, NOT in this repo)                            │
│   FitOS — https://fitos-backend-55g6.onrender.com/api/v1        │
│   (NestJS-style; Swagger at .../docs)                           │
└─────────────────────────────────────────────────────────────────┘
```

## 3. Code layout

| Path | Contents |
|---|---|
| `lib/main.dart` | App entry, named routes, deep-link handling, session-restore router (`_AppEntry`) |
| `lib/auth/screens/` | Login (3 portals), register, forgot/reset password, email verification |
| `lib/onboarding/` | 6-page goal-intake wizard (`OnboardingFlow`) + widgets |
| `lib/dashboard/screens/` | Member portal screens (home dashboard + embedded tabs) |
| `lib/dashboard/widgets/` | Glass cards, progress bars, `premium_gate.dart`, `state_views.dart` (loading/error/empty views + `friendlyApiError`) |
| `lib/gym_owner/screens/` | Gym owner portal screens + tabs |
| `lib/trainer/screens/` | Trainer portal screens + tabs + sheets |
| `lib/admin/screens/` | Super-admin certification review queue |
| `lib/providers/` | Riverpod state: `auth_provider`, `onboarding_provider`, `entitlements_provider`, `gym_provider` |
| `lib/services/` | `api_client` (Dio), `member_service`, `gym_owner_service`, `trainer_service`, `media_upload_service`, `token_storage_service` |
| `lib/models/` | Plain Dart models matching backend response shapes |
| `lib/theme/` | `AppTheme.darkTheme` |

## 4. Key architectural decisions (from source comments)

- **Single Dio instance with a full interceptor chain** (`api_client.dart`): Bearer-token
  injection, `{success,data}` envelope unwrapping, and 401 auto-refresh with **shared in-flight
  refresh deduplication** — the backend rotates-and-invalidates refresh tokens on every use, so
  concurrent 401s must share one refresh call or the second one is treated as token theft.
- **Service layer returns clean Dart models** — screens never see raw JSON.
- **Gym-scoped API calls** read `gymId` from `currentGymIdProvider`
  (`selectedGymProvider` ← user's `gymMemberships[]`). Auto-selected when the user has exactly
  one membership.
- **Progressive-save design**: `PATCH /members/me/profile` accepts partial payloads; the
  onboarding wizard saves after every step (fire-and-forget) and rehydrates from the backend on
  resume.
- **Premium gating** is driven exclusively by `GET /subscriptions/me/entitlements` via the
  `entitlementsProvider` (`premium_gate.dart`), per the feature spec.
- **Media upload** is a 3-step flow: `POST /media/presign-upload` → raw `PUT` of bytes to the
  returned signed URL (deliberately token-less, separate `Dio()`) → submit the returned
  `publicUrl` to the target endpoint.
- **WhatsApp delivery** is ₹0 tap-to-send: backend queues `wa.me` deep links, front desk opens
  them externally and confirms with `mark-sent`.

## 5. Routing map (named routes in `lib/main.dart`)

| Route | Screen |
|---|---|
| `/onboarding` | `OnboardingFlow(initialPage: args)` |
| `/login` | `LoginScreen` |
| `/dashboard` | `HomeDashboard` |
| `/gym-owner-login` | `GymOwnerLoginScreen` |
| `/gym-owner-dashboard` | `GymOwnerDashboard` |
| `/trainer-login` | `TrainerLoginScreen` |
| `/trainer-dashboard` | `TrainerDashboard` |
| `/gym-owner-trainers` | `GymOwnerTrainersScreen` |
| `/gym-owner-join-requests` | `GymOwnerJoinRequestsScreen` |
| `/gym-owner-notifications` | `GymOwnerNotificationsScreen` |
| `/gym-owner-support` | `GymOwnerSupportScreen` |
| `/billing-plans` | `BillingPlansScreen` |
| `/settings` | `SettingsScreen` |
| `/register` | `RegisterScreen(isEmbeddedInOnboarding: false)` |
| `/create-gym` | `CreateGymScreen` |
| `/forgot-password` | `ForgotPasswordScreen` |
| `/reset-password` | `ResetPasswordScreen` |
| `/verify-email` | `EmailVerificationScreen` |

Startup routing (`_AppEntry.build` in `main.dart`):

- `unauthenticated` / `error` → `OnboardingFlow` (welcome page)
- `authenticated`:
  - role `gymOwner`/`frontDesk` (or targetRole gymOwner) → `CreateGymScreen` if no gym
    memberships, else `GymOwnerDashboard`
  - role/targetRole `trainer` → `TrainerDashboard`
  - user `isOnboardingComplete == false` → `OnboardingFlow(initialPage: 2)` + hydrate wizard
    from `GET /members/me/profile`
  - otherwise → `HomeDashboard`

Deep links (`app_links`):

- `fitforge://oauth/callback?accessToken=...&refreshToken=...` → Google OAuth callback
- `fitforge://<host>/verify-email?token=...` → `/verify-email`
- `fitforge://<host>/reset-password?token=...` → `/reset-password`

## 6. Data-flow walkthrough (one example end-to-end)

**Screen → Component → Service → API → Response → Screen** for the "Members" tab:

1. `GymOwnerMembersTab` (embedded tab of `GymOwnerDashboard`) reads
   `ref.read(currentGymIdProvider)` → gymId.
2. Calls `gymOwnerServiceProvider.getMembers(gymId)` →
   `GymOwnerService.getMembers` builds `GET /gyms/<gymId>/members?page=1&limit=100`.
3. The Dio request interceptor attaches `Authorization: Bearer <token>`.
4. The response interceptor unwraps `{success:true, data:[...]}`.
5. `GymMember.fromJson` maps each row (with tolerant fallbacks like `user.firstName`).
6. The tab filters/sorts client-side (search, status chips, trainer filter) and renders cards.
7. Errors flow back through the Dio error interceptor (normalized `message`) →
   `friendlyApiError` → `ErrorRetryView` with a Retry button.

## 7. Mock vs real data

| Portal | Screens |
|---|---|
| **Real API** | All auth screens, onboarding, billing plans, edit profile, profile (partial), settings, join gym, QR check-in, referral, ALL gym-owner screens, trainer profile/certifications, admin certification review |
| **Mock only** | Home dashboard, diet plan, meal builder, exercise plan, exercise detail, progress analytics, rewards, leaderboard, trainer dashboard, trainer clients, trainer client detail, trainer analytics, trainer reviews, trainer plan review |

The mock member-dashboard APIs the backend should eventually provide are specified in
`BACKEND_REQUIREMENTS_DASHBOARD.md` (e.g. `GET /members/me/dashboard/today`,
`POST /members/me/logs/water`).

## 8. Known limitations (documented in GAP_LOG.md)

- No member-facing transaction/invoice history endpoint exists yet.
- "Join Requests" may map to either invite approvals or walk-in leads — pending backend
  clarification.
- The gym-owner referrals tab UI contains coupon options; backend separates `/coupons` from
  `/referrals/config` — pending clarification.