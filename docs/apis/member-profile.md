# API Module: Member Profile & Onboarding

Source: `lib/services/member_service.dart`, `lib/providers/onboarding_provider.dart`,
`lib/models/member_profile.dart`, `lib/models/onboarding_state.dart`.
Backend controller/service details: **Not found in source code**.

## 1. GET /members/me/profile

Used by: Onboarding wizard resume/hydrate (`onboarding_provider.dart:77`), Edit Profile
(`edit_profile_screen.dart` load), Profile (`profile_screen.dart` load).

**Request:** none. Bearer token.

**Response** (fields read by `MemberProfile.fromJson`):

```json
{
  "dateOfBirth": "2001-01-01",
  "sex": "MALE",
  "heightCm": 170,
  "weightKg": 70,
  "goal": "FAT_LOSS",
  "experienceLevel": "INTERMEDIATE",
  "dietaryPreference": "VEG",
  "budgetBand": "MEDIUM",
  "equipmentAccess": "FULL_GYM",
  "injuriesNotes": null,
  "weeklyFocus": null,
  "onboardingCompletedAt": "2026-08-01T10:00:00Z"
}
```

| Field | Type | Description |
|---|---|---|
| dateOfBirth | String (date) | Date of birth |
| sex | String | `MALE` / `FEMALE` |
| heightCm / weightKg | Number | Body metrics |
| goal | String | `FAT_LOSS` / `MUSCLE_GAIN` / `STRENGTH` / `SPORT_SPECIFIC` / `GENERAL_FITNESS` |
| experienceLevel | String | `BEGINNER` / `INTERMEDIATE` / `ADVANCED` |
| dietaryPreference | String | `VEG` / `VEGAN` / `NON_VEG` / `EGGETARIAN` / `JAIN` |
| budgetBand | String | `LOW` / `MEDIUM` / `HIGH` |
| equipmentAccess | String | `FULL_GYM` / `HOME_EQUIPMENT` / `NO_EQUIPMENT` |
| injuriesNotes / weeklyFocus | String? | Free text |
| onboardingCompletedAt | ISO date? | Set by `POST /members/me/complete-onboarding` |

404 handling: none for this endpoint (it must exist once registered). The wizard's
`hydrateFromBackend` tolerates failure and starts fresh.

## 2. PATCH /members/me/profile

Used by: Onboarding (every step, fire-and-forget, and final), Edit Profile.
**Progressive-save design** — only non-null fields are sent.

**Request** (payload built by `OnboardingState.toBackendJson` or Edit Profile mappers):

```json
{
  "sex": "MALE",
  "dateOfBirth": "2001-01-01",
  "heightCm": 170,
  "weightKg": 70,
  "goal": "FAT_LOSS",
  "experienceLevel": "INTERMEDIATE",
  "dietaryPreference": "VEG",
  "budgetBand": "MEDIUM",
  "equipmentAccess": "FULL_GYM",
  "injuriesNotes": "knee",
  "weeklyFocus": "legs"
}
```

| Field | Type | Required | Source |
|---|---|---|---|
| sex | String | Always in onboarding payload | Gender selector |
| dateOfBirth | String `YYYY-MM-DD` | Always in onboarding payload | Derived from age slider: `(currentYear − age)-01-01` |
| heightCm / weightKg | Number | Always in onboarding payload | Sliders |
| goal | String | Conditional | Goal cards → `FAT_LOSS`/`MUSCLE_GAIN`/`GENERAL_FITNESS`; Edit Profile adds `STRENGTH`/`SPORT_SPECIFIC` |
| experienceLevel | String | Conditional | Experience cards |
| dietaryPreference | String | Conditional | Diet chips |
| budgetBand | String | Conditional | Budget chips |
| equipmentAccess | String | Conditional | Equipment chips |
| injuriesNotes / weeklyFocus | String? | Optional | Edit Profile text fields |

**Response:** updated `MemberProfile` (same shape as GET).

Edit Profile additionally calls `PATCH /users/me` (`{firstName?, lastName?, phone?, avatarUrl?}`)
and then `GET /users/me` (`refreshUser`) so the header reflects the save immediately.

## 3. POST /members/me/complete-onboarding

Used by: Onboarding final step ("Generate My Plan", `onboarding_provider.dart:136`).

**Request:** empty body.

**Response:** not parsed. Sets `memberProfile.onboardingCompletedAt` server-side, which flips
`User.isOnboardingComplete` on the next `GET /users/me`.

Sequence: `PATCH /members/me/profile` → `POST /members/me/complete-onboarding`. Errors from
the POST abort the wizard with a SnackBar (client `isCompleteForBackend` gates whether the
backend's required fields are all present).

## 4. PATCH /users/me

Used by: Edit Profile (`MemberService.updateUserProfile`).

**Request:**

```json
{ "firstName": "A", "lastName": "B", "phone": "9876543210", "avatarUrl": "https://..." }
```

All fields optional — only non-null values are included. `avatarUrl` comes from the presigned
upload result (`purpose: "AVATAR"`).

## Entities

MemberProfiles (goal intake), Users (see `database-overview.md`).