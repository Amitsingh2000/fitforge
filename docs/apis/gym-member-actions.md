# API Module: Member Gym Actions (join, check-in, referrals)

Source: `lib/services/member_service.dart`. Backend controller/service details:
**Not found in source code** (backend external to this repo).

## 1. POST /gyms/join

Used by: Join a Gym screen.

**Request:**

```json
{ "code": "GYM123" }
```

`code` — the invite/activation code, from the form field (uppercased presentation).

**Response** (raw map, fields the screen reads):

```json
{
  "gymId": "gym_123",
  "membershipId": "mem_456",
  "gymName": "Iron Works",
  "gym": { "id": "gym_123", "name": "Iron Works" }
}
```

| Field | Type | Description |
|---|---|---|
| gymId (or gym.id) | String | Gym id — used to set `selectedGymProvider` |
| membershipId (or id) | String | New membership id |
| gymName (or gym.name) | String | Gym name |

Success → the screen stores a `GymMembership(gymId, gymName, role: member, membershipId)`
into `selectedGymProvider` so gym-scoped features work immediately.

## 2. POST /gyms/:gymId/attendance/check-in

Used by: QR Self Check-in screen.

**Request:**

```json
{ "qrToken": "TOKEN-FROM-POSTER" }
```

`gymId` path param from `currentGymIdProvider`; `qrToken` from the token field (manual paste —
there is no camera scanning in this build).

**Response:** not parsed. Success shows "Check-in successful!". Idempotent per
`section2-handoff.md` (one entry per member per day; re-scans don't duplicate).

## 3. GET /gyms/:gymId/referrals/my-code

Used by: Referrals screen (load).

**Request:** none. `gymId` from `currentGymIdProvider`.

**Response** (parsed by `ReferralCode.fromJson`):

```json
{ "code": "ABC123", "totalReferrals": 2, "qualifiedReferrals": 1 }
```

| Field | Type | Description |
|---|---|---|
| code | String | Shareable code |
| totalReferrals | Number | Total referrals made |
| qualifiedReferrals | Number | Referrals whose purchase qualified the reward |

## 4. GET /gyms/:gymId/referrals/my-referrals

Used by: Referrals screen (load).

**Request:** none.

**Response:** list (or paginated `{items: [...]}` — both handled):

```json
[
  { "id": "r_1", "referee": { "firstName": "S", "lastName": "K" }, "status": "QUALIFIED", "createdAt": "2026-07-01T10:00:00Z" }
]
```

| Field | Type | Description |
|---|---|---|
| id | String | Referral id |
| refereeFirstName / referee.firstName | String? | Referee name |
| refereeLastName / referee.lastName | String? | Referee name |
| status | String | `PENDING` / `QUALIFIED` |
| createdAt | ISO date | When redeemed |

## 5. POST /gyms/:gymId/referrals/redeem

Used by: Referrals screen (Redeem button).

**Request:**

```json
{ "code": "ABC123" }
```

**Response:** not parsed. Success SnackBar + reload of the two GET endpoints above.
The reward (FREE_DAYS extension or auto-issued coupon) is granted once the friend's first
purchase qualifies (per `section2-handoff.md`).

## Backend notes (from section2-handoff.md)

- QR check-in token = the gym's `qrCheckInSecret`, embedded in the printed poster's URL;
  never exposed on member-facing gym reads.
- Referral reward types: `FREE_DAYS` | `FLAT_DISCOUNT_COUPON`, configured by the owner
  (`PUT /gyms/:gymId/referrals/config`).

## Entities

Gyms, GymMemberships, Attendance, ReferralCodes, Referrals (see `database-overview.md`).