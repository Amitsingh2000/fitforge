# Screen: Leads

- **File:** `lib/gym_owner/screens/leads_screen.dart`
- **Route:** Tab within the gym owner shell

## Screen Information

Fitness CRM: lead pipeline with stage/source/assignee filters (only `stage` is currently
sent), add, move stage, and convert to member.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| Stage filter chips | Chips | — | `GET …/leads?stage=` |
| Add Lead: name | Text | Required | `POST …/leads.name` |
| Add Lead: phone / email | Text | Optional (format-checked) | `POST …/leads.{phone, email}` |
| Add Lead: source | Chips: WALK_IN / PHONE / INSTAGRAM / WEBSITE | Required | `POST …/leads.source` |
| Move Stage sheet | Stage chips | Required | `PATCH …/leads/:leadId {stage}` |

## API Flow

```
Load    → GET /gyms/:gymId/leads?page=1&limit=100[&stage=…]   (errors → [])
Metrics → GET /gyms/:gymId/leads/metrics                      (errors → {}; banner)
Add     → POST /gyms/:gymId/leads {name, phone?, email?, source}
Stage   → PATCH /gyms/:gymId/leads/:leadId {stage}
Convert → POST /gyms/:gymId/leads/:leadId/convert → reload
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Filter by stage | `GET …/leads?stage=` | Other filters client-side |
| "Add Lead" | `POST …/leads` | — |
| Move stage | `PATCH …/leads/:leadId` | — |
| "Convert to Member" | `POST …/leads/:leadId/convert` | Confirmation; creates/finds user with MEMBER role — enroll separately |

## Database

Reads/writes: Leads, Users.

## Validation / Error Handling

- Required fields/format → SnackBar; convert failure → SnackBar (e.g. phone missing).

## Links

`docs/apis/gym-referrals-leads-communications.md`,
`docs/screens/enrollment.md`, `docs/screens/gym-owner-members-tab.md`.