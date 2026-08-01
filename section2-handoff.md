# FitOS Backend — Section 2 Handoff (Gym Owner Module)

*For: PM + Flutter/FE developers. Updated 21 July 2026.*
*Companion to the live API reference (Swagger): **https://fitos-backend-55g6.onrender.com/docs***
*Read [section1-handoff.md](section1-handoff.md) first — the envelope, auth, roles, and error
shapes described there apply unchanged here.*

---

## TL;DR

Section 2 of the product spec (Gym Owner Module — §2.1–§2.9 of the feature specification, **minus
the deliberate scope-downs listed at the bottom**) is **implemented, migrated, and tested end to
end** (132-check suite, all green, against the live database). It adds **52 endpoints** across 9 new
areas on top of Section 1.

| What | URL |
|---|---|
| API base | `https://fitos-backend-55g6.onrender.com/api/v1` |
| Interactive API docs (Swagger) | `https://fitos-backend-55g6.onrender.com/docs` |
| Machine-readable OpenAPI spec | `https://fitos-backend-55g6.onrender.com/docs-json` |

Everything in Section 1 still works exactly as before — this release is **purely additive** (new
tables + new nullable columns; no existing shape changed).

---

## The one concept you must understand first: **plan vs enrollment**

Section 1 gave gyms `MembershipPlan` **templates** ("Quarterly, ₹5000, 90 days"). Section 2 adds the
thing a real member actually buys: a **`MemberPlanEnrollment`** — one member's specific instance of a
plan, with its own status, dates, price, sessions-remaining, and freeze state.

- A plan is the *menu item*; an enrollment is the *order*.
- Editing or retiring a plan never rewrites past enrollments — the price/duration/sessions are
  **snapshotted onto the enrollment** at purchase time.
- "Membership management" in the UI = operating on **enrollments**, not plans.

Enrollment status: `ACTIVE` · `FROZEN` · `EXPIRED` · `CANCELLED`.

---

## Features implemented (mapped to spec §2)

### §2.1 Membership management — `[memberships]` + new `[gyms]` member routes
- **Enroll** a member in a plan (`POST /gyms/:gymId/memberships`), optional `couponCode` applies a
  discount at purchase; price is snapshotted.
- **Freeze / unfreeze** (`/freeze`, `/unfreeze`) — unfreeze extends `endDate` by the actual frozen
  duration so the member never loses paid days.
- **Renew** (`/renew`) — creates the next enrollment starting when the current one ends (or now if
  already lapsed); the old one is `CANCELLED`, and `previousEnrollmentId` links the lineage.
- **Change plan** (`/change-plan`) — upgrade/downgrade; **auto-prorates** unused value of the old
  plan as a credit against the new price (staff can still override the final price).
- **Transfer** (`/transfer`) — reassign an enrollment to a different member; no money math.
- **PT / class packs** (`SESSION` plans): `assign-trainer`, log a session (`/session-logs`), which
  decrements the pack; the enrollment auto-flips to `EXPIRED` when the last session is used.
- **Member record**: single walk-in add (`POST /gyms/:gymId/members`), a **360° member view**
  (`GET /gyms/:gymId/members/:membershipId` → profile + recent enrollments *with computed dues* +
  recent attendance), staff edits to photo/ID-proof/emergency-contact (`/profile`), private
  `/notes`. Bulk CSV import from Section 1 is unchanged.
- **Expiry reminders** at 7/3/1 days out run as a daily cron via the communications hub (§2.9).

### §2.2 Payments & billing — `[payments]` *(gateway-free scope — see "Not in this release")*
- Gym owner sets **UPI ID + QR image** on the gym profile (`PATCH /gyms/:gymId` with `upiId`,
  `upiQrCodeUrl`; upload the QR via media presign purpose `GYM_UPI_QR`). Members see these on the
  gym profile and **pay off-platform** via any UPI app.
- **Record** a payment (`POST /gyms/:gymId/payments`) — method `CASH` / `UPI_MANUAL` /
  `BANK_TRANSFER` / `CARD_OFFLINE` / `OTHER`, may be tied to an enrollment or ad-hoc, may be
  backdated. Every payment gets a **unique sequential non-GST receipt number** — the gym's
  uppercased slug + a zero-padded counter (e.g. `SMOKE-TEST-GYM-8RGT5-000042`).
- **Partial payments / dues**: dues are computed live as `enrollment price − Σ(recorded payments)`.
  Dues dashboard (`GET /gyms/:gymId/payments/dues`) lists who owes what.
- **Void** (`POST /gyms/:gymId/payments/:id/void`) — never hard-delete; voiding restores the dues.
- **Receipt** view (`GET /gyms/:gymId/payments/:id/receipt`).
- **Dues reminders** run as a daily cron, forced to the WhatsApp channel so the message points at
  the gym's UPI ID/QR.

### §2.3 Attendance — `[attendance]`
- **QR self check-in** (`POST /gyms/:gymId/attendance/check-in` with `qrToken`) — the token is the
  gym's `qrCheckInSecret`, embedded in the printed QR poster's URL. Rotate it
  (`POST /gyms/:gymId/qr-check-in-token/rotate`) to instantly invalidate a leaked/photographed
  poster. The secret is **never exposed** on the member-facing gym read.
- **Front-desk manual** check-in for today (`/attendance/manual`).
- **Google-Calendar-style CRUD** (`POST/GET/PATCH/DELETE /gyms/:gymId/attendance`) — pick a date,
  add/backfill/edit/delete an entry. One entry per member per day (re-scans are idempotent).
- **History** per member + **absence alerts** ("X hasn't come in N days"), which also drive a daily
  win-back cron. Absence alerts are the seed of the Phase-3 churn engine.

### §2.4 Coupons & offers — `[coupons]`
- Owner-created codes: `PERCENT` or `FLAT`, validity window, usage cap, optional plan restriction
  (`applicablePlanIds`). Codes are case-insensitive on redemption.
- Redemption tracking per code (`/coupons/:id/redemptions`) for campaign analytics.
- Deactivate is a soft-delete so redemption history survives.

### §2.5 Referral system — `[referrals]` + `[owner-referrals]`
- **Member→member**: owner configures the reward (`PUT /gyms/:gymId/referrals/config`); a member
  gets a shareable code (`/referrals/my-code`); a friend redeems it (`/referrals/redeem`); the
  reward grants **once the friend's first purchase qualifies it**. Reward types: `FREE_DAYS`
  (extends the referrer's `endDate`) or `FLAT_DISCOUNT_COUPON` (auto-issues a single-use coupon).
- **Owner→owner** (our GTM channel): an owner mints a platform code (`POST /owner-referrals`); a new
  gym created with that code is attributed (`GET /owner-referrals/mine`). Reward is applied manually
  by platform ops for now (`GET /admin/owner-referrals`, super-admin only).

### §2.6 Fitness CRM / lead pipeline — `[leads]`
- Capture (`POST /gyms/:gymId/leads`, source walk-in/phone/Instagram/website), kanban list
  filterable by stage/source/assignee, follow-up activities, **convert to member** (`/convert` —
  finds-or-creates the person and attaches the MEMBER role; enroll them separately via
  `/memberships`), and **conversion metrics** (`/leads/metrics`).

### §2.7 Owner dashboard — `[dashboard]` *(owner/manager only)*
- **Today**: check-ins, collections (voided excluded), new joins, expiring-soon, dues.
- **Monthly**: revenue, active members, renewals vs churn, attendance trend.
- **Trainers**: roster with assigned-client counts + shift/commission config.

### §2.8 Trainer management — folded into `[gyms]` + `[memberships]`
- Roster is `GET /gyms/:gymId/members?role=TRAINER`; shift schedule + commission rate config via
  `PATCH /gyms/:gymId/members/:membershipId/trainer-config`; PT-session assignment via the
  memberships routes above. *(Commission is config only — no payout engine; trainer scorecards are
  Phase 3.)*

### §2.9 Communication hub — `[communications]`
- One shared pipeline sends expiry/dues/absence/birthday/receipt/announcement messages.
- **Email** delivers automatically (Brevo, from Section 1). **WhatsApp** is delivered as **`wa.me`
  tap-to-send deep links** that queue in a **staff outbox** (`GET /gyms/:gymId/communications`) —
  the front desk taps to send from the gym's own WhatsApp, then confirms with `/:id/mark-sent`.
  This is the funded-later interim (₹0, no WhatsApp Business API bill). SMS/Push are logged-only.
- **Announce** (`/communications/announce`) broadcasts to targeted or all active members
  (reliable delivery is email at scale — WhatsApp broadcast is one tap per member).
- Every log row carries `estimatedCostInr` (₹0 today) for the spec's "cost transparency" promise.

---

## RBAC quick reference (who can call what)

Roles are per-gym (from Section 1). `GymRolesGuard` enforces these; super admin bypasses.

| Capability | GYM_OWNER / GYM_MANAGER | FRONT_DESK | MEMBER |
|---|:--:|:--:|:--:|
| Enroll / freeze / renew / record payment / take attendance | ✅ | ✅ | — |
| Transfer / change-plan / assign-trainer / trainer-config | ✅ | — | — |
| **Browse all payments · dues dashboard · void payment** | ✅ | ❌ | — |
| **Delete a calendar attendance entry** | ✅ | ❌ | — |
| **Owner dashboard** (today/monthly/trainers) | ✅ | ❌ | — |
| Coupons · referral config · announce | ✅ | — | — |
| Leads (capture → convert) | ✅ | ✅ | — |
| Communications outbox / mark-sent | ✅ | ✅ | — |
| QR self check-in · get own referral code / redeem | — | — | ✅ |

The front-desk exclusions are deliberate — they match Section 1's stated boundary ("record
attendance, collect payment, add member — **no financial reports, no exports**") and close obvious
fraud vectors (front desk voiding cash they collected, or erasing an absence).

---

## Key user journeys (build screens from these)

**Owner sets up billing**: `PATCH /gyms/:id` with `upiId` (+ upload a QR via `GYM_UPI_QR` presign)
→ members now see how to pay → staff records each payment as it comes in → dues dashboard tracks the
rest.

**Front desk enrolls a walk-in**: `POST /gyms/:id/members` (or convert a lead) → `POST
/gyms/:id/memberships { userId, planId, couponCode? }` → `POST /gyms/:id/payments` → receipt.

**Member checks in**: scans the printed QR → `POST /gyms/:id/attendance/check-in { qrToken }`.
Front desk fallback: `POST /gyms/:id/attendance/manual { userId }`. Backfill a missed day:
`POST /gyms/:id/attendance { userId, attendedOn }`.

**Renewal/upgrade**: `POST /gyms/:id/memberships/:id/renew` (same plan) or `/change-plan`
(different plan, auto-prorated).

**Referral loop**: owner `PUT /referrals/config` → member `GET /referrals/my-code` shares it →
friend `POST /referrals/redeem` → friend's first enrollment auto-qualifies and grants both rewards.

---

## Not in this release (so nobody is surprised)

| Item | Status / why |
|---|---|
| Payment **gateway** (Razorpay/Cashfree), **UPI Autopay**, **GST invoicing** | **Paused** by product decision — the current build records manual UPI/QR + cash only. Resume when an aggregator is contracted. |
| Real **WhatsApp Business API** (automated sends) | Deferred until funded — `wa.me` tap-to-send links are the ₹0 interim (per backend-tech-stack.md). |
| **SMS** | No free Indian SMS provider — logged-only. |
| **Push (FCM)** | Free, but no mobile client exists yet to register a device token — nothing to push to. |
| **Cash-credit** referral rewards, trainer **commission payout**, revenue-share ledger | Needs a wallet/billing engine — that's Phase 4 (§7.3). Only config/tracking is built now. |
| **Trainer scorecards** (retention/adherence analytics) | Phase 3 — needs workout/chat/adherence data that doesn't exist until §3/§4 ship. |
| **Biometric attendance**, **multi-branch** (§2.10) | Later phases per the spec's own phase map. |

## Platform quirks (unchanged from Section 1)

Free-tier hosting: expect 30–50 s cold starts after idle (a keep-alive pinger mitigates it) and
~30–60 s downtime per deploy. Build FE timeouts/retries generously (60 s + one retry).

## Test status

A 132-check journey suite runs the full golden path plus edge cases and RBAC boundaries against the
**live database**: enroll/freeze/renew/transfer/change-plan (with proration verified to the rupee),
session-pack exhaustion, coupons (percent/flat/plan-restricted/expired), payments + void + dues
math, QR/manual/calendar attendance with secret-leak checks, the full referral reward loop, leads →
convert → metrics, all three dashboards with numbers checked against known state, the wa.me outbox,
media presign for the new purposes, owner-referral attribution, and **cross-gym isolation** (owner
of gym B is 403'd from gym A). All green. Two real bugs were found and fixed by this suite (a
proration over-credit on not-yet-started enrollments; a transaction timeout under pooled-DB latency).

The three daily crons (expiry / dues / absence reminders) are logic-tested through their underlying
service calls; the `@Cron` trigger itself is the same pattern already running in Section 1.
