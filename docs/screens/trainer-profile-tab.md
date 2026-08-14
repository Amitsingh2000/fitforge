# Screen: Trainer — Profile Tab

- **File:** `lib/trainer/screens/trainer_profile_tab.dart`
- **Route:** Tab within the trainer shell

## Screen Information

Trainer identity card: profile fields, certifications list, and logout.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Name / contact / bio / specializations | Read-only | — | `GET /trainers/me/profile` |
| Certifications (status incl. PENDING_REVIEW) | Read-only | — | `GET /trainers/me/profile.certifications` |

## API Flow

```
Load   → GET /trainers/me/profile   (errors → SnackBar)
Logout → POST /auth/logout {refreshToken} → clear → /trainer-login
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load tab | `GET /trainers/me/profile` | — |
| "Edit Profile" | — | Navigation to Trainer Edit Profile |
| "Certifications" | — | Navigation to Trainer Certifications |
| "Logout" | `POST /auth/logout` | Best-effort; local session always cleared |

## Database

Reads: TrainerProfiles, TrainerCertifications.

## Validation / Error Handling

- Profile load failure → SnackBar with retry.

## Links

`docs/apis/trainer.md`, `docs/screens/trainer-edit-profile.md`,
`docs/screens/trainer-certifications.md`.