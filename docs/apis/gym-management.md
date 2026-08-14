# API Module: Gym Management (profile, SaaS subscription)

Source: `lib/services/gym_owner_service.dart`. Backend controller/service details:
**Not found in source code** (backend external to this repo).

## 1. POST /gyms

Used by: Create Gym screen.

**Request** (matches backend `CreateGymDto` exactly — unknown fields 400 under strict
validation, e.g. `upiId` or `address` must NOT be sent here):

```json
{
  "name": "Iron Works",
  "phone": "9876543210",
  "email": "gym@example.com",
  "addressLine": "12 MG Road",
  "city": "Pune",
  "state": "MH",
  "pincode": "411001",
  "referralCode": "OWNER-CODE"
}
```

| Field | Type | Required | Source |
|---|---|---|---|
| name | String | Yes | Form (≥2 chars validated) |
| phone / email | String | No | Optional form fields (omitted if empty) |
| addressLine | String | Yes (from form) | Form |
| city / state / pincode | String | No | Optional (pincode ≥4 digits if filled) |
| referralCode | String | No | Optional owner-referral code |

**Response:** raw map; the screen reads `res['id']` or `res['gymId']` → gymId and
`res['membershipId']` → membershipId, then sets `selectedGymProvider`.

## 2. GET /gyms/:gymId

Used by: Gym Settings (load), Gym Owner Profile tab (load).

**Request:** none.

**Response** (raw map; fields the screens read):

| Field | Type | Description |
|---|---|---|
| name | String | Gym name |
| phone / email | String? | Contact |
| addressLine / city / state / pincode | String? | Address |
| upiId / upiQrCodeUrl | String? | Payout details |
| logoUrl / photoUrls | String / String[] | Images |
| facilities | String[] | Facility list |
| workingHours | Object[] | `{day, isClosed, opensAt, closesAt}` × 7 |
| mutedOwnerAlertTypes | String[] | Owner notification-mute prefs |

## 3. PATCH /gyms/:gymId

Used by: Gym Settings (Save Changes).

**Request** (only non-null fields are sent):

```json
{
  "name": "Iron Works",
  "phone": "9876543210",
  "email": "gym@example.com",
  "addressLine": "12 MG Road",
  "city": "Pune",
  "state": "MH",
  "pincode": "411001",
  "logoUrl": "https://.../logo.jpg",
  "upiId": "gym@upi",
  "upiQrCodeUrl": "https://.../qr.jpg",
  "facilities": ["Cardio", "Strength"],
  "workingHours": [
    { "day": "MONDAY", "isClosed": false, "opensAt": "06:00", "closesAt": "22:00" }
  ],
  "photoUrls": ["https://.../p1.jpg"],
  "mutedOwnerAlertTypes": ["OWNER_RENEWAL_DUE"]
}
```

UPI fields must be set here (not via `POST /gyms`).

## 4. GET /gyms/:gymId/subscription

Used by: Gym Owner Profile tab.

**Request:** none. **Response:** raw map `{planCode, status, trialEndsAt}` (404 → null).

## 5. POST /gyms/:gymId/subscription/trial

Used by: Gym Owner Profile tab ("Start Free Trial").

**Request:**

```json
{ "planCode": "GYM_PRO" }
```

`planCode` hardcoded to `GYM_PRO` (service default). **Response:** not parsed.

## Unused endpoint in this module

| Method | Endpoint | Service method | Note |
|---|---|---|---|
| POST | `/gyms/:gymId/join-code/rotate` | `rotateJoinCode` | Defined but no screen calls it |

## Entities

Gyms, GymMemberships, GymSubscriptions (see `database-overview.md`).