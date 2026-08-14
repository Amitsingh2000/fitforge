# API Module: Referrals (owner config) & Leads & Communications

Three smaller gym modules share this file: referral reward config, the leads CRM, and the
communications hub.

Backend controller/service details: **Not found in source code** (backend external to this
repo). RBAC per `section2-handoff.md`: coupons/referral-config/announce = GYM_OWNER +
GYM_MANAGER; leads + communications outbox = staff (owner/manager/front desk).

## Part A — Referral reward config

### GET /gyms/:gymId/referrals/config
Used by: Gym Owner Referrals tab. **Response:** raw map `{rewardType, rewardValue,
isActive}` — `rewardType`: `FREE_DAYS` | `FLAT_DISCOUNT_COUPON`. 404 → null (not configured).

### PUT /gyms/:gymId/referrals/config
Used by: Gym Owner Referrals tab (Save Reward Config sheet).

```json
{ "rewardType": "FREE_DAYS", "rewardValue": 7 }
```

| Field | Type | Required | Source |
|---|---|---|---|
| rewardType | String | Yes | Chips: `FREE_DAYS` / `FLAT_DISCOUNT_COUPON` |
| rewardValue | Number | Yes | Preset chips — days `[3,5,7,14,30]` or ₹ `[50,100,150,200,500]` (default 7) |

`FREE_DAYS` extends the referrer's `endDate`; `FLAT_DISCOUNT_COUPON` auto-issues a single-use
coupon. Both grant once the friend's first purchase qualifies.

## Part B — Leads (fitness CRM)

### GET /gyms/:gymId/leads
Used by: Leads screen. Query: `page=1`, `limit=100`, plus `stage` / `source` / `assigneeId`
(only `stage` currently passed from the filter chips). **Response:** list parsed by
`GymLead.fromJson`:

| Field | Aliases read | Description |
|---|---|---|
| id | — | Lead id |
| name | — | Lead name |
| phone / email | — | Contact |
| source | — | `WALK_IN` / `PHONE` / `INSTAGRAM` / `WEBSITE` |
| stage | — | `NEW` / `CONTACTED` / `INTERESTED` / `CONVERTED` / `LOST` |
| assigneeId / assigneeName | `assignee.id`, `assignee.{firstName,lastName}` | Staff assignee |
| notes / followUpAt / createdAt | — | CRM fields |
| convertedUserId | — | Set after conversion |

### POST /gyms/:gymId/leads
Used by: Leads screen (Add Lead sheet).

```json
{ "name": "Rahul", "phone": "9876543210", "email": "r@x.com", "source": "WALK_IN" }
```

Optional fields omitted if empty; `assigneeId`/`notes` supported by the service but not
passed by the current screen. **Response:** `GymLead`.

### PATCH /gyms/:gymId/leads/:leadId
Used by: Leads screen (Move Stage sheet). Body: `{stage}` (service also supports
`notes`, `followUpAt`). **Response:** `GymLead`.

### POST /gyms/:gymId/leads/:leadId/convert
Used by: Leads screen (Convert, confirmation dialog). No body. Finds-or-creates the person and
attaches the MEMBER role (enroll separately via `/memberships`). **Response:** raw map
(unused by the screen).

### GET /gyms/:gymId/leads/metrics
Used by: Leads screen (banner). **Response:** raw map; the screen reads `metrics['total']`
and `metrics['converted']` (falls back to client-side counts). Errors → `{}`.

## Part C — Communications hub

### GET /gyms/:gymId/communications
Used by: Communications screen. Query: `page=1`, `limit=50`, `pendingOnly=true` (toggle).
**Response:** list parsed by `CommunicationLog.fromJson`:

| Field | Aliases read | Description |
|---|---|---|
| id | — | Log id |
| recipientUserId / recipientName | `recipient.id`, `recipient.{firstName,lastName}` | Recipient |
| recipientPhone | `recipient.phone` | Phone |
| channel | — | `EMAIL` / `WHATSAPP` / `SMS` / `PUSH` (default WHATSAPP) |
| messageType | `type` | `EXPIRY_REMINDER` / `DUES_REMINDER` / `ABSENCE` / `BIRTHDAY` / `RECEIPT` / `ANNOUNCEMENT` |
| subject / body | — | Content |
| waLink | `whatsappLink` | wa.me deep link (external send) |
| sentAt / markedSentAt | — | Delivery state |
| estimatedCostInr | — | Cost transparency (₹0 today) |
| isPending | derived | WHATSAPP + no markedSentAt |

### POST /gyms/:gymId/communications/:commId/mark-sent
Used by: Communications screen (Mark Sent). No body — front desk confirms after tapping the
wa.me link.

### POST /gyms/:gymId/communications/announce
Used by: Communications screen (Announce sheet).

```json
{ "title": "New timings", "body": "We open at 6am from Monday." }
```

`channel` and `targetUserIds` supported by the service but not passed (null = all active
members, all channels).

### External action
"Send via WhatsApp" is not an API call — it opens `log.waLink` via `url_launcher`
(`LaunchMode.externalApplication`).

## Entities

ReferralConfig, Leads, CommunicationLogs (see `database-overview.md`).