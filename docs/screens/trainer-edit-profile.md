# Screen: Trainer — Edit Profile

- **File:** `lib/trainer/screens/trainer_edit_profile_screen.dart`
- **Route:** `MaterialPageRoute` from Trainer Profile tab

## Screen Information

Trainer profile editor: bio, specializations, experience, intro video, and photo gallery
(via the shared presigned-upload helper).

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Bio | Text (multiline) | Optional | `PATCH /trainers/me/profile.bio` |
| Specializations | Chips | Optional | `PATCH /trainers/me/profile.specializations` |
| Experience (years) | Number | Optional (`int.tryParse`) | `PATCH /trainers/me/profile.experienceYears` |
| Intro video | Media picker → upload | — | presign (`TRAINER_INTRO_VIDEO`) → PUT → `introVideoUrl` |
| Photos | Media picker → upload | — | presign (`TRAINER_PHOTO`) → PUT → `photoUrls[]` |

## API Flow

```
Load → GET /trainers/me/profile (hydrate form; failure → default)
Save → PATCH /trainers/me/profile {bio?, specializations?, experienceYears?, introVideoUrl?, photoUrls?}
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Add/remove intro video | `POST /media/presign-upload` → PUT storage | Result feeds `introVideoUrl` |
| Add/remove photos | `POST /media/presign-upload` → PUT storage | Result feeds `photoUrls` |
| "Save Changes" | `PATCH /trainers/me/profile` | Only non-null fields |

## Database

Writes: TrainerProfiles.

## Validation / Error Handling

- Invalid experience value → SnackBar; save errors → SnackBar; success → pop.
- Upload failures leave prior values intact.

## Links

`docs/apis/trainer.md`, `docs/apis/media.md`, `docs/screens/trainer-profile-tab.md`.