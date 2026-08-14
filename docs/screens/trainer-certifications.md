# Screen: Trainer — Certifications

- **File:** `lib/trainer/screens/trainer_certifications_screen.dart`
- **Route:** `MaterialPageRoute` from Trainer Profile tab

## Screen Information

Certification management: list existing (with status: PENDING_REVIEW / APPROVED /
REJECTED) and submit new ones for super-admin review.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Title | Text | Required (SnackBar if empty) | `POST /trainers/me/certifications.title` |
| Issuer | Text | Optional (omitted if empty) | `POST /trainers/me/certifications.issuer` |
| File | File picker (PDF/image) | Required | presign (`TRAINER_CERTIFICATION`) → PUT → `fileUrl` |

## API Flow

```
Load   → GET /trainers/me/profile  (certifications list; errors → [])
Submit → POST /media/presign-upload → PUT storage
       → POST /trainers/me/certifications {title, issuer?, fileUrl} → reload
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load list | `GET /trainers/me/profile` | Reuses the profile payload |
| "Add Certification" → Submit | `POST /media/presign-upload` → PUT → `POST /trainers/me/certifications` | Status becomes PENDING_REVIEW |
| Open file | `url_launcher` | View the certificate |

## Database

Writes: TrainerCertifications.

## Validation / Error Handling

- Empty title → SnackBar; upload/submit failures → SnackBar with retry.

## Links

`docs/apis/trainer.md`, `docs/apis/media.md`,
`docs/screens/certification-review.md`, `docs/screens/trainer-profile-tab.md`.