# API Module: Trainer (profile, certifications, admin review)

Source: `lib/services/trainer_service.dart`, `lib/models/trainer_profile.dart`.
Backend controller/service details: **Not found in source code** (backend external to this
repo). The trainer service is deliberately small: trainer self-service (profile +
certifications) and the super-admin certification review queue. The rest of the trainer
portal is mock (see `screens/trainer-mock-screens.md`).

## 1. GET /trainers/me/profile

Used by: Trainer Profile tab, Trainer Certifications (load).

**Request:** none. Bearer token.

**Response** (parsed by `TrainerProfile.fromJson` — tolerates missing/null fields):

| Field | Type | Description |
|---|---|---|
| id / trainerId / userId | String | Trainer identity |
| name / firstName / lastName / fullName | String | Display name |
| email / phone / avatarUrl | String? | Contact |
| bio | String? | Bio |
| specializations | List\<String\>? | e.g. `["Strength"]` |
| experienceYears | Number? | Years of experience |
| introVideoUrl | String? | Intro video |
| photoUrls | List\<String\>? | Gallery |
| certifications | List\<TrainerCertification\>? | `{id?, title, issuer?, year?, fileUrl?, status?, rejectionReason?, reviewedAt?}` |

## 2. PATCH /trainers/me/profile

Used by: Trainer Edit Profile (Save).

**Request** (only non-null fields sent):

```json
{
  "bio": "Strength coach, 5 yrs exp.",
  "specializations": ["Strength", "Hypertrophy"],
  "experienceYears": 5,
  "introVideoUrl": "https://…/intro.mp4",
  "photoUrls": ["https://…/p1.jpg"]
}
```

| Field | Type | Source |
|---|---|---|
| bio | String? | Bio field |
| specializations | List\<String\>? | Specialization chips (toggled) |
| experienceYears | Number? | `int.tryParse` of the years field |
| introVideoUrl | String? | Presigned upload `purpose: TRAINER_INTRO_VIDEO` |
| photoUrls | List\<String\>? | Presigned uploads `purpose: TRAINER_PHOTO` |

**Response:** updated `TrainerProfile`.

## 3. POST /trainers/me/certifications

Used by: Trainer Certifications (Submit for Review).

**Request:**

```json
{ "title": "ACE Certified Personal Trainer", "issuer": "ACE", "fileUrl": "https://…/cert.pdf" }
```

| Field | Type | Required | Source |
|---|---|---|---|
| title | String | Yes | Title field (SnackBar if empty) |
| issuer | String? | No | Issuer field (omitted if empty) |
| fileUrl | String | Yes | Presigned upload `purpose: TRAINER_CERTIFICATION` (PDF/image; picked via file picker) |

**Response:** `TrainerCertification` (status set to `PENDING_REVIEW`).

## 4. GET /trainers/certifications/pending

Used by: Certification Review (super-admin queue, `isSuperAdmin` gate).

**Request:** none.

**Response:** either a list or `{items: [...]}` (both handled) of raw maps:
`{id, title, issuer, trainerProfile{user{fullName, email}}, fileUrl, status, submittedAt}`.

## 5. PATCH /trainers/certifications/:certificationId/review

Used by: Certification Review (Approve / Reject with reason).

**Request:**

```json
{ "approve": false, "rejectionReason": "Expired credential" }
```

| Field | Type | Required | Source |
|---|---|---|---|
| approve | Boolean | Yes | Approve vs Reject button |
| rejectionReason | String? | Only on reject | Rejection sheet text (omitted if empty) |

**Response:** not parsed; the queue is reloaded.

## Screens using this module

| Screen | Calls |
|---|---|
| Trainer Profile Tab | GET `/trainers/me/profile`, POST `/auth/logout` |
| Trainer Edit Profile | POST `/media/presign-upload` (+ presigned PUT), PATCH `/trainers/me/profile` |
| Trainer Certifications | GET `/trainers/me/profile`, POST `/media/presign-upload` (+ presigned PUT), POST `/trainers/me/certifications` |
| Certification Review (admin) | GET `/trainers/certifications/pending`, PATCH `/trainers/certifications/:id/review` |

## Not implemented (mock-only)

Trainer dashboard, clients list, client detail, analytics, reviews, plan editor, schedule —
no API calls exist in the app for these (`lib/trainer/screens/*` are static/mock; see
`docs/screens/trainer-mock-screens.md` and `BACKEND_REQUIREMENTS_DASHBOARD.md`).

## Entities

TrainerProfiles, TrainerCertifications, Users (see `database-overview.md`).