# Screen: Edit Profile

- **File:** `lib/dashboard/screens/edit_profile_screen.dart`
- **Route:** `MaterialPageRoute` from Profile

## Screen Information

Member profile editor. Combines two resource updates: `PATCH /users/me` (identity + avatar)
and `PATCH /members/me/profile` (fitness intake), followed by a `GET /users/me` refresh so
the header updates.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| First Name | Text | Required | `PATCH /users/me.firstName` |
| Last Name | Text | Required | `PATCH /users/me.lastName` |
| Email | Text | Read-only (not editable) | — |
| Phone | Text | Optional (non-empty sends) | `PATCH /users/me.phone` |
| Avatar | Image picker → upload | — | `POST /media/presign-upload` (`AVATAR`) → presigned PUT → `PATCH /users/me.avatarUrl` |
| Injuries / Notes | Text | Optional | `PATCH /members/me/profile.injuriesNotes` |
| Weekly Focus | Text | Optional | `PATCH /members/me/profile.weeklyFocus` |
| Goal | Dropdown | Optional | `PATCH /members/me/profile.goal` (incl. `STRENGTH`/`SPORT_SPECIFIC`) |
| Experience | Dropdown | Optional | `PATCH /members/me/profile.experienceLevel` |
| Diet Preference | Dropdown | Optional | `PATCH /members/me/profile.dietaryPreference` |
| Budget Band | Dropdown | Optional | `PATCH /members/me/profile.budgetBand` |
| Equipment Access | Dropdown | Optional | `PATCH /members/me/profile.equipmentAccess` |

## API Flow

```
Load   → GET /users/me (current user, via auth state) + GET /members/me/profile
Save   → PATCH /users/me {firstName, lastName, phone?, avatarUrl?}
       → PATCH /members/me/profile {goal?, experienceLevel?, …}  (non-null only)
       → GET /users/me (refreshUser)
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Tap avatar / "Upload" | `POST /media/presign-upload` → PUT storage → `PATCH /users/me` | Upload helper shared with Gym Settings |
| Tap "Save Changes" | `PATCH /users/me` + `PATCH /members/me/profile` + `GET /users/me` | Sequential |
| Back | — | Header refreshed from provider state |

## Database

Writes: Users, MemberProfiles.

## Validation / Error Handling

- Required names enforced; photo-picker cancelled = no-op.
- Save errors → SnackBar with server message; success → SnackBar + pop.
- Upload failure keeps the old avatar.

## Links

`docs/apis/member-profile.md`, `docs/apis/media.md`, `docs/screens/profile.md`,
`docs/screens/onboarding.md`.