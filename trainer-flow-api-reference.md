# FitForge — Trainer flow → API reference

*Maps every bullet in `fitforge_trainer_flow.pdf` to the actual backend endpoint. Base URL:
`{API_PREFIX}` = `/api/v1`. This is a from-scratch build (`feature-specification.md` §3 Trainer
Module + the §4.1–4.7 manual member-side counterparts needed for it to have real data) — nothing
here existed before this pass except auth/profile/certification (Section 1) and the gym-owner's
trainer roster config (Section 2). Chat is real-time: REST persists, a Socket.IO gateway at the
`/chat` namespace pushes live `newMessage`/`typing`/`read` events — see the Gaps section for the
one thing curl can't exercise (verified separately with a raw Socket.IO client).*

Legend: ✅ built · ⚠️ built as a proxy/approximation, or partially built (see note on that row)

---

## Page 1 — Login, profile verification & trainer dashboard

| PDF item | Endpoint |
|---|---|
| Login / register | ✅ `POST /auth/login`, `POST /auth/register` (Section 1) |
| Profile verification (certs/experience reviewed) | ✅ `POST /trainers/me/certifications` (submit) → `GET/PATCH /trainers/certifications/pending[/:id/review]` (super-admin review queue, Section 1) |
| Trainer dashboard | ✅ `GET /trainers/me/dashboard` — cross-gym (a trainer can work multiple gyms) |
| — Assigned members | ✅ `dashboard.assignedMembersCount`; full list at `GET /gyms/:gymId/trainer/clients` |
| — Pending workout plans | ✅ `dashboard.pendingWorkoutPlansCount` (DRAFT-status plans you authored) |
| — Pending diet plans | ✅ `dashboard.pendingDietPlansCount` |
| — Progress summary | ✅ Per-client via `trainer/clients` (each entry embeds `progressSummary`) or aggregate via `trainer/analytics` |
| — Messages | ✅ `dashboard.unreadMessagesCount`; full feed at `GET /gyms/:gymId/chat/threads` |
| — Notifications | ✅ `dashboard.unreadNotificationsCount`; full feed at `GET /trainers/me/notifications` |

---

## Page 2 — Member management & progress tracking

### Member management

| PDF item | Endpoint |
|---|---|
| View assigned members | ✅ `GET /gyms/:gymId/trainer/clients` — **self-scoped**: server derives "mine" from `assignedTrainerId`/plan authorship, never a client-supplied filter |
| View member profile | ✅ `GET /gyms/:gymId/members/:userId/profile` (goal, dietary preference, injuries, etc.) |
| View fitness goals | ✅ Included in the profile endpoint above and in each `trainer/clients` entry |
| View attendance | ✅ `GET /gyms/:gymId/members/:userId/attendance` |
| View workout history | ✅ `GET /gyms/:gymId/members/:userId/workout-logs` |
| View nutrition history | ✅ `GET /gyms/:gymId/members/:userId/nutrition-logs` |
| View progress history | ✅ `GET /gyms/:gymId/members/:userId/progress-entries` (weight/measurements/photos) |

All six `members/:userId/...` reads share one access rule: `GYM_OWNER`/`GYM_MANAGER`/`FRONT_DESK`
see any member (matches the existing 360° member-view convention); a `TRAINER` only sees a member
who's actually assigned to them (active enrollment or a plan they authored for that member) —
enforced server-side (`ProgressService.assertCanAccessMember`), not just role-gated.

### Progress tracking (trainer can monitor)

| PDF item | Endpoint |
|---|---|
| Workout completion | ✅ `GET /gyms/:gymId/members/:userId/progress-summary` → `workoutCompletionRatePercent` — completed plan-linked workout logs ÷ scheduled plan days elapsed |
| Exercise performance | ✅ Raw sets/reps/weight per exercise in each `workout-logs` entry |
| Weight progress | ✅ `progress-entries[].weightKg`, trend direction in `progress-summary.weightTrend` |
| Body measurements | ✅ `progress-entries[].measurements` (flexible body-part → cm map) |
| Progress photos | ✅ `progress-entries[].photoUrls` (private by default — `MediaPurpose.PROGRESS_PHOTO`) |
| Nutrition compliance | ✅ `progress-summary.nutritionComplianceRatePercent` — days logged ÷ days elapsed on the active diet plan |
| Attendance | ✅ `members/:userId/attendance` (above) |
| Goal achievement | ⚠️ `progress-summary.goalAchievement` (`ON_TRACK`/`OFF_TRACK`/`UNKNOWN`) — a **heuristic**, not a tracked field: weight-trend direction vs `MemberProfile.goal` for FAT_LOSS/MUSCLE_GAIN, workout-completion-rate fallback for GENERAL_FITNESS/STRENGTH/SPORT_SPECIFIC |

---

## Page 3 — Workout & diet plan management, analytics

### Workout plan management

| PDF item | Endpoint |
|---|---|
| Create workout plans | ✅ `POST /gyms/:gymId/workout-plans` — omit `memberId` to save as a reusable template |
| Edit workout plans | ✅ `PATCH /gyms/:gymId/workout-plans/:id` — passing `days[]` replaces the whole day/exercise tree (no partial diffing) |
| Assign plans to members | ✅ `POST /gyms/:gymId/workout-plans/:id/assign {memberId, startDate?}` |
| Update plans based on progress | ✅ Same `PATCH` endpoint — read `progress-summary` first, then edit |

A plan is a flat ordered list of days (`dayNumber`), not a week×day matrix — the client sees it
day-by-day either way; the trainer's `label` text ("Week 1 Day 1") carries any grouping. Exercises
come from `GET/POST /exercises` (platform-wide library, search by name/category/equipment;
trainers can add custom exercises alongside platform-curated ones).

### Diet plan management

| PDF item | Endpoint |
|---|---|
| Create personalized diet plans | ✅ `POST /gyms/:gymId/diet-plans` |
| Edit diet plans | ✅ `PATCH /gyms/:gymId/diet-plans/:id` — passing `meals[]` replaces the whole meal/item tree |
| Assign plans to members | ✅ `POST /gyms/:gymId/diet-plans/:id/assign` |
| Update plans based on progress | ✅ Same `PATCH` endpoint |

Food items are **freeform** (`foodName` + manually entered `calories`/`proteinG`/etc.) — no Indian
food database integration in this pass (that's its own licensed-dataset workstream, §8 platform
content curation). Daily macro totals still work; they're just not looked up from a catalog.

### Analytics

| PDF item | Endpoint |
|---|---|
| Active members | ✅ `GET /gyms/:gymId/trainer/analytics` → `activeMembers` |
| Workout completion rate | ✅ `avgWorkoutCompletionRatePercent` (averaged across your clients) |
| Nutrition compliance | ✅ `avgNutritionComplianceRatePercent` |
| Member progress | ✅ Per-client breakdown via `trainer/clients` |
| Goal completion rate | ✅ `goalCompletionRatePercent` — share of clients with `goalAchievement: ON_TRACK` |
| Member engagement | ✅ `engagedClientsLast7dPercent` — share of clients with a workout log in the last 7 days |

---

## Page 4 — Communication & profile

### Communication

| PDF item | Endpoint |
|---|---|
| Chat with members | ✅ `POST /gyms/:gymId/chat/threads {otherUserId}` (get-or-create), `GET .../threads`, `GET .../threads/:id/messages` |
| Answer member queries | ✅ `POST /gyms/:gymId/chat/threads/:id/messages` — same send endpoint, either direction |
| Share workout tips / diet guidance | ✅ Same send endpoint, `type: TEXT`; or attach a plan directly (`type: WORKOUT_PLAN_REF`/`DIET_PLAN_REF` + `refWorkoutPlanId`/`refDietPlanId`) |
| Send motivational messages | ✅ `POST /gyms/:gymId/chat/broadcast {body}` — fans out to every one of your active clients at this gym |

Real-time: messages persist via REST (reliable, correctly RBAC'd, no loss on a dropped socket)
and push live over Socket.IO (`/chat` namespace) to anyone connected — `newMessage` on send,
`read` on read-receipt, `typing`/`stopTyping` for indicators. Client connects with
`io(url + '/chat', { auth: { token } })` using the same access token as REST calls, then emits
`joinThread { threadId }` for each thread it wants live updates on (server verifies you're an
actual participant before allowing the room join).

### Profile

| PDF item | Endpoint |
|---|---|
| Personal profile | ✅ `GET/PATCH /trainers/me/profile` (bio, photos) |
| Certifications | ✅ `POST /trainers/me/certifications` (Section 1) |
| Experience | ✅ `PATCH /trainers/me/profile` → `experienceYears` |
| Specializations | ✅ `PATCH /trainers/me/profile` → `specializations[]` |
| Availability | ✅ `PATCH /trainers/me/profile` → `availability` (weekly schedule, same 7-day shape as the gym's `workingHours`) |
| Settings | ✅ `PATCH /trainers/me/profile` → `mutedAlertTypes` (Settings > Notifications — suppress `TRAINER_NEW_MESSAGE`/`TRAINER_NEW_CLIENT_ASSIGNED` on your own alert feed) |

---

## Page 5 — Operating flow

The full loop (login → dashboard → select member → review profile → create workout+diet plan →
assign → member performs it → track progress → review analytics → update plan if needed → chat →
repeat) is just the endpoints above called in sequence. No new endpoints beyond what's listed.

---

## Notifications wired

`CommunicationTemplateType` gained two trainer-facing values, reusing the exact `IN_APP` alert
pipeline built for the gym-owner dashboard last session (`CommunicationsService.notifyTrainer()`
mirrors `notifyOwner()`):

- `TRAINER_NEW_MESSAGE` — fires when a member messages you (not the reverse — no member-facing
  `IN_APP` feed exists yet, so a trainer messaging a member doesn't generate one).
- `TRAINER_NEW_CLIENT_ASSIGNED` — fires when a gym owner/manager assigns you to an enrollment via
  the existing `POST /gyms/:gymId/memberships/:id/assign-trainer`.

---

## What's genuinely still open

- **"Goal achievement" is a heuristic**, not real goal-tracking — flagged inline above. Same
  honesty pattern as the gym-owner progress-monitoring proxy from last session, but this time
  the *other* two metrics (workout completion, nutrition compliance) are computed from real
  logged data, not attendance proxies.
- **No Indian food database** — diet plan items and nutrition logs are freeform text + manual
  macros. Building/licensing a real food catalog (IFCT 2017 or similar) is its own project
  (`feature-specification.md` §8), not attempted here.
- **AI-assisted coaching (§3.6)** and **online coaching marketplace (§3.7)** are explicitly
  Phase 2/4 in the spec's own cutline — excluded by design, not an oversight.
- **Standalone (no-gym) trainer↔client pairing** — `gymId` is nullable on `WorkoutPlan`/
  `DietPlan`/`ChatThread` so this doesn't require a schema migration later, but the pairing
  mechanism itself (how an online-only member gets assigned a trainer with no gym relationship)
  isn't solved — the user-journey PDF's "Individual user flow" mentions it but no flow specifies
  how the match happens. Not addressed in this pass.
