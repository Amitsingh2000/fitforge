# Screen: Bulk Import

- **File:** `lib/gym_owner/screens/bulk_import_screen.dart`
- **Route:** `MaterialPageRoute` from Members tab

## Screen Information

CSV/Excel (`.csv`, `.xlsx`) bulk member import with a **dry-run preview** before commit.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| File picker | CSV/XLSX | Max 500 rows (client-side) | parsed rows → `POST /gyms/:gymId/members/import` |

## API Flow

```
Pick file → parse rows client-side (headers → key/value maps)
Preview  → POST /gyms/:gymId/members/import {dryRun: true, rows}  → per-row report
Commit   → POST /gyms/:gymId/members/import {dryRun: false, rows} → summary chips
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| "Import File" | — | File picker (no network) |
| "Preview Import" | `POST …/members/import {dryRun:true}` | Shows rows: `CREATED` / `LINKED_EXISTING` / `ALREADY_MEMBER` / `ERROR` |
| "Import" (commit) | `POST …/members/import {dryRun:false}` | Summary + SnackBar |

## Database

Writes: Users + GymMemberships (bulk, via backend).

## Validation / Error Handling

- Wrong extension / no file / >500 rows / empty rows → SnackBar.
- Import errors are reported **per row** (`message` + `index`) rather than blocking the batch.

## Links

`docs/apis/gym-members.md`, `docs/screens/add-member.md`.