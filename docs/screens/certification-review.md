# Screen: Certification Review Queue (admin)

- **File:** `lib/admin/screens/certification_review_screen.dart`
- **Route:** `MaterialPageRoute` from Settings — shown only when `user.isSuperAdmin`

## Screen Information

Super-admin queue for approving/rejecting trainer certification submissions. Gate:
`isSuperAdmin` from `GET /users/me` (Settings → super-admin).

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Certification card (title, issuer, trainer name/email, file URL) | Read-only list | — | `GET /trainers/certifications/pending` |
| Rejection reason | Text | Optional (only on Reject) | `PATCH …/review.rejectionReason` |

## API Flow

```
Open     → GET /trainers/certifications/pending   (list or {items} — both handled)
Approve  → PATCH /trainers/certifications/:id/review {approve: true}
Reject   → PATCH /trainers/certifications/:id/review {approve: false, rejectionReason?}
         → reload the queue
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Load queue | `GET /trainers/certifications/pending` | — |
| Tap Approve (✓) | `PATCH …/review {approve:true}` | — |
| Tap Reject (✕) | `PATCH …/review {approve:false, rejectionReason?}` | Reason from the rejection sheet |
| Open file URL | `url_launcher` | View the certification PDF/image |

## Database

Writes: TrainerCertifications (status/review fields).

## Validation / Error Handling

- Loading state + error message + retry; empty queue shows a friendly empty state.
- Approve/reject errors → SnackBar; queue reloaded after success.

## Links

`docs/apis/trainer.md`, `docs/screens/settings.md`,
`docs/screens/trainer-certifications.md`.