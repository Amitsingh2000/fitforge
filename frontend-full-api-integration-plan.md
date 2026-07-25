# FitForge — Full API Integration Plan (All Roles)

*Purpose: wire the existing Flutter app to the live FitOS backend across every role — Normal User
(Member), Gym Owner, and Trainer. This is an integration task, not a redesign.*

**Hard rule #1: do not break any existing working flow.** Auth (login/register/logout/refresh/
forgot-password/verify-email/Google OAuth) and member onboarding (`/members/me/profile`,
`/members/me/complete-onboarding`) are already fully wired and working — leave their logic alone
unless a fix below explicitly touches them.

**Hard rule #2: never call `dio` directly from a screen widget.** Put every API call behind a small
service function that returns your own clean Dart model — the screen only ever talks to that model.
This is what protects your already-built UI from breaking when the backend contract shifts (see §1).

---

## 0. Context

- **Backend base URL**: `https://fitos-backend-55g6.onrender.com/api/v1`
- **Swagger**: `https://fitos-backend-55g6.onrender.com/docs`
- **Client**: reuse the existing `dioProvider` (`lib/services/api_client.dart`). Response envelope is
  already unwrapped by the interceptor — every call receives `data` directly, not `{ success, data }`.
- **Auth**: Bearer token + auto-refresh already handled. Nothing to change here.
- **Backend is still moving.** Your friend is building against the shared spec, not a frozen
  contract — field names, response shapes, even whole endpoints may change. §1 and §8 exist
  specifically to make that safe to absorb without touching your screens each time.

---

## 1. The pattern to use everywhere (do this first, once)

```
lib/
  services/
    api_client.dart          ← already exists, don't touch
    member_service.dart      ← new
    gym_owner_service.dart   ← new
    trainer_service.dart     ← new
  models/
    (one clean model per resource: GymMembership, MembershipPlan, Enrollment, Payment, ...)
```

Rules for every service function:
1. Takes plain Dart params (`gymId`, `userId`, etc.), never a raw Map.
2. Returns your own model, not the raw JSON — do the parsing/mapping *inside* the service.
3. Screen code changes **only** which service function it calls and what model it renders — the
   widget tree, layout, and state variables it already has stay the same shape.
4. If your friend renames a field or changes a response shape, you fix **one function** in one
   service file. The screen never needs to change.

Example shape (illustrative, not literal code to paste):
```dart
// services/member_service.dart
class MemberService {
  final Dio dio;
  MemberService(this.dio);

  Future<GymProfile> getMyGym(String gymId) async {
    final res = await dio.get('/gyms/$gymId');
    return GymProfile.fromJson(res.data); // mapping lives here, nowhere else
  }
}
```

---

## 2. Blocking fix — do this before wiring any gym-scoped screen

**Problem**: `GET /users/me` returns `gymMemberships` (gym associations + per-gym role), but
`User.fromBackendJson()` (`lib/models/user.dart`) only uses it to derive one flat
`UserRole {client, trainer, gymOwner}` and **discards `gymId` and `membershipId`**. Every gym-scoped
endpoint (Gym Owner *and* Member check-in/referrals) is shaped `/gyms/:gymId/...` — none of it works
without a stored `gymId`. `FRONT_DESK` also isn't mapped today (falls through to `client`).

### Required changes
1. Add a `GymMembership` model: `{ gymId, gymName, role (GYM_OWNER | GYM_MANAGER | FRONT_DESK |
   TRAINER | MEMBER), membershipId, status }`.
2. Extend `User` to hold `List<GymMembership> gymMemberships` — keep the existing derived `role`
   getter for backward compatibility, but base it on the richer list instead of discarding data.
3. Add a `selectedGymProvider` (Riverpod) holding the active gym context. A `MEMBER` typically has
   zero or one gym; a staff user may have more — don't hard-code to a single gym.
4. Map `FRONT_DESK` to its own role value.

**Don't change** how login/registration/onboarding work — only extend what `User` carries after
`/users/me` resolves. This is additive and low-risk.

---

## 3. Role A — Normal User (Member)

*Scope: `lib/dashboard/*`, `lib/onboarding/*` (onboarding already done, don't touch).*

### Already real — leave alone
- Auth, `/members/me/profile`, `/members/me/complete-onboarding`.

### Wire existing mock screens
| Screen | Mock field | Real endpoint |
|---|---|---|
| `profile_screen.dart` | basic info | already via `authProvider`; edits → `PATCH /users/me`, `PATCH /members/me/profile` |
| `profile_screen.dart` | photo upload | `POST /media/presign-upload` |
| `settings_screen.dart` | session mgmt | `GET /auth/sessions`, `DELETE /auth/sessions/:sessionId`, `POST /auth/logout-all` |
| `billing_plans_screen.dart` | `_plans` | `GET /subscriptions/me`, `GET /subscriptions/me/entitlements`, `POST /subscriptions/me/trial` |
| `billing_plans_screen.dart` | `_transactions` | ❌ no member-facing endpoint exists — flag as unavailable, don't fake it |

### New screens (backend ready, no UI exists yet)
- **Join a gym**: `POST /gyms/join` (invite code/QR) → then `GET /gyms/:gymId` to show gym profile
  (incl. owner's UPI ID/QR for off-platform payment).
- **QR self check-in**: `POST /gyms/:gymId/attendance/check-in { qrToken }`.
- **Referral code**: `GET /gyms/:gymId/referrals/my-code`, `POST .../referrals/redeem`,
  `GET .../referrals/my-referrals`.

### Leave as mock for now (no backend yet — don't invent calls)
`home_dashboard.dart` tasks, `diet_plan_screen.dart`, `meal_builder_screen.dart`,
`progress_analytics_screen.dart`, `leaderboard_screen.dart`, `rewards_screen.dart` — Phase 2/3 features
(§4/§5/§6 of the spec), not built on the backend yet.

### RBAC for this role
Can only: self check-in, own referral code/redeem, view own gym's public profile, manage own
account/subscription. Everything else gym-scoped will 403 — don't build UI that would call it.

---

## 4. Role B — Gym Owner

*Scope: `lib/gym_owner/*`. Currently 100% hardcoded mock data — no `dio` calls anywhere in this
folder, so there's no existing working flow to protect here; you're building the wiring from
scratch.*

### New: gym creation screen (doesn't exist yet)
No screen calls `POST /gyms`. A freshly-registered gym owner has nowhere to create a gym today.
Add a "Create your gym" screen shown when a `gymOwner`-role user has an empty `gymMemberships` list;
on success store the returned `gymId` in `selectedGymProvider` and route to the dashboard.

### Wire existing mock screens
| Screen | Mock field | Real endpoint |
|---|---|---|
| `gym_owner_dashboard.dart` | stat cards | `GET /gyms/:gymId/dashboard/today`, `/monthly` |
| `gym_owner_dashboard.dart` | trainer preview | `GET /gyms/:gymId/dashboard/trainers` |
| `gym_owner_members_tab.dart` | `_allMembers` | `GET /gyms/:gymId/members` (supports `?role=`) |
| `gym_owner_members_tab.dart` | member detail | `GET /gyms/:gymId/members/:membershipId` (360° view) |
| `gym_owner_members_tab.dart` | add/edit/remove | `POST /members`, `POST /members/import`, `PATCH .../profile`, `.../notes`, `DELETE .../members/:membershipId` |
| `gym_owner_trainers_screen.dart` | `_allTrainers` | `GET /gyms/:gymId/members?role=TRAINER` |
| `gym_owner_trainers_screen.dart` | shift/commission | `PATCH /gyms/:gymId/members/:membershipId/trainer-config` |
| `gym_owner_analytics_tab.dart` | `_revenueData` etc | partially `GET /gyms/:gymId/dashboard/monthly` — check `/docs` for exact shape before assuming full coverage |

### New sub-flow: membership lifecycle (needed inside member detail, no screen exists yet)
Plan templates first: `GET/POST/PATCH/DELETE /gyms/:gymId/plans`, then:
- Enroll: `POST /gyms/:gymId/memberships { userId, planId, couponCode? }`
- Freeze/unfreeze: `POST .../memberships/:enrollmentId/freeze` / `/unfreeze`
- Renew: `POST .../memberships/:enrollmentId/renew`
- Change plan (auto-prorated): `POST .../memberships/:enrollmentId/change-plan`
- Transfer: `POST .../memberships/:enrollmentId/transfer`
- PT/class packs: `POST .../assign-trainer`, `POST/GET .../session-logs`

### New screens (backend ready, zero UI exists)
- **Payments**: `POST /gyms/:gymId/payments`, `POST .../payments/:id/void`, `GET .../payments/:id/receipt`, `GET .../payments/dues`
- **Attendance**: `POST/GET/PATCH/DELETE /gyms/:gymId/attendance`, `POST .../attendance/manual`, `GET .../attendance/absence-alerts`, `POST .../qr-check-in-token/rotate`
- **Communications**: `GET /gyms/:gymId/communications`, `POST .../mark-sent`, `POST .../announce`
- **Owner-referrals** (platform GTM): `POST /owner-referrals`, `GET /owner-referrals/mine`

### ⚠️ Needs a product decision before wiring
- **`gym_owner_referrals_tab.dart`**: current mock (`_discountOptions`, `_validityOptions`) reads like
  **coupons** (`POST/GET/PATCH/DELETE /gyms/:gymId/coupons`), but the backend also has a separate
  `referrals` module (member-to-member reward config: `PUT/GET .../referrals/config`). Confirm which
  this screen is meant to be — may need to split into two screens.
- **`gym_owner_join_requests_screen.dart`**: no direct backend match. Closest candidates are
  `gyms/invites` (invite-code approvals) or `leads` (walk-in/inquiry pipeline). Confirm intent before
  wiring.

### RBAC for this role
`GYM_OWNER`/`GYM_MANAGER` get everything above. `FRONT_DESK` (same screens, restricted): can
enroll/freeze/renew/pay/attend/leads/communications but **not** dues dashboard, void, delete-
attendance, or dashboard analytics — gate those buttons in the UI, not just rely on the backend 403.

---

## 5. Role C — Trainer

*Scope: `lib/trainer/*`. UI exists (clients, plan review, analytics) but is ahead of the backend —
confirm with your friend what actually exists before wiring anything here.*

### Currently backed (confirmed in the Postman collection)
- `GET/PATCH /trainers/me/profile`
- `POST /trainers/me/certifications`
- `GET /trainers/certifications/pending`, `PATCH /trainers/certifications/:certificationId/review`
  (admin review side, not the trainer's own screens)

### Not backed yet — don't wire, log as a gap instead
Client list, client timeline, workout plan builder, priority queue, trainer scorecards — these are
spec §3 (Trainer Module) and mostly haven't shipped on the backend per the Section 2 handoff. Wiring
these now means inventing endpoints. Only build:
- `trainer_profile_tab.dart` → `GET/PATCH /trainers/me/profile`
- Certification upload flow → `POST /trainers/me/certifications`

Leave `trainer_clients_tab.dart`, `trainer_client_detail_screen.dart`, `trainer_plan_review_screen.dart`,
`trainer_analytics_tab.dart`, `trainer_reviews_tab.dart` as mock until your friend confirms/ships the
matching endpoints.

---

## 6. RBAC quick reference (all roles)

| Capability | GYM_OWNER/MANAGER | FRONT_DESK | TRAINER | MEMBER |
|---|:--:|:--:|:--:|:--:|
| Enroll/freeze/renew/pay/attend | ✅ | ✅ | — | — |
| Transfer/change-plan/assign-trainer | ✅ | — | — | — |
| Dues dashboard · void payment | ✅ | ❌ | — | — |
| Delete attendance entry | ✅ | ❌ | — | — |
| Owner dashboard | ✅ | ❌ | — | — |
| Coupons · referral config · announce | ✅ | — | — | — |
| Leads (capture → convert) | ✅ | ✅ | — | — |
| Communications outbox | ✅ | ✅ | — | — |
| QR self check-in · own referral code | — | — | — | ✅ |
| Own trainer profile/certifications | — | — | ✅ | — |

---

## 7. Explicitly out of scope (across all roles) — will 404 or doesn't exist

- Payment gateway/UPI Autopay/GST invoicing (manual UPI/cash only for now).
- Real WhatsApp Business API sends (only `wa.me` tap-to-send outbox exists).
- SMS sending, push notifications (no provider / no device-token registration yet).
- Trainer commission payouts, cash-credit referral payouts, trainer scorecards.
- Biometric attendance, multi-branch.
- Member progress/metrics history, AI coach chat, photo meal analysis, diet/workout plan generation.

---

## 8. The gap log — how you and your friend stay in sync

Don't send one-off docs each time you hit a wall. Keep a single running table, update it as you go,
and let him reply against it directly:

| Screen / field | Endpoint tried | Result | What I need |
|---|---|---|---|
| Profile photo upload | `POST /media/presign-upload` | ✅ works | — |
| Billing transactions list | none found | 404 / N/A | Need a member-facing transactions endpoint, or confirm it's not in scope yet |
| Gym owner referrals tab | unclear: coupons vs referrals | — | Confirm which module this screen maps to |

Add a row the moment something doesn't match what you expected — don't re-explain context each time,
just point at the row.

---

## 9. Suggested build order (protects existing flows, unblocks the rest fastest)

1. §1 — service-layer pattern in place (one-time setup, touches nothing existing).
2. §2 — gym-membership/role model fix (additive, no existing screen changes).
3. §3 — Normal User: profile/settings/subscription wiring (lowest risk, already-stable screens).
4. §3 — Normal User: join-gym + QR check-in + referral code (new screens, unlocks gym-scoped member features).
5. §4 — Gym Owner: gym creation screen, then dashboard stat cards, then members tab + membership lifecycle.
6. §4 — Gym Owner: payments, attendance, then the two ⚠️ product-decision screens once confirmed.
7. §5 — Trainer: only the two confirmed-backed screens (profile, certifications); everything else
   waits on your friend confirming the backend exists.

---

## 10. Acceptance checklist per screen

- [ ] No hard-coded mock data left where a real endpoint exists.
- [ ] API call lives in a service function, not inline in the widget.
- [ ] Uses the existing `dioProvider` — no new Dio instance created.
- [ ] Reads `gymId`/`userId` from state, never hard-coded.
- [ ] Loading + error + empty states present.
- [ ] Action visibility respects the RBAC table in §6.
- [ ] Any endpoint that didn't behave as expected got a row in the gap log (§8), not a guess.
- [ ] Existing auth/onboarding flows still work unchanged (manual smoke test: login → onboarding →
      dashboard, per role).
