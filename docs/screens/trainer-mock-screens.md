# Screens: Trainer Portal (mock feature screens)

- **Files:** `lib/trainer/screens/{trainer_dashboard,trainer_clients_tab,trainer_client_detail_screen,trainer_analytics_tab,trainer_reviews_tab,trainer_plan_review_screen}.dart` + widgets
- **Route:** `/trainer-dashboard` (shell); tabs/features inside

## Screen Information

The trainer portal shell and its feature screens are **UI-only mocks** — they make **no API
calls** (verified against `lib/services/trainer_service.dart`, which contains only profile,
certifications, and admin-review endpoints). Data shown is static/placeholder per
`BACKEND_REQUIREMENTS_DASHBOARD.md`; the real endpoints (clients, session logs, analytics,
reviews, plans, schedule) are backend-side requirements **not yet consumed by the app**.

## Screens and their APIs

| Screen | File | Real API calls |
|---|---|---|
| Trainer Dashboard | `trainer_dashboard.dart` | None (static stats, today's sessions placeholder, schedule card) |
| Clients tab | `trainer_clients_tab.dart` | None (static client rows) |
| Client Detail | `trainer_client_detail_screen.dart` | None (static metrics; "Log Session" sheet static) |
| Analytics tab | `trainer_analytics_tab.dart` | None (static charts) |
| Reviews tab | `trainer_reviews_tab.dart` | None (static review cards) |
| Plan Review / Plan Editor | `trainer_plan_review_screen.dart` | None (local draft exercises only) |
| Schedule card | `widgets/trainer_schedule_card.dart` | None (static day/slot grid) |

## Real API touchpoints in the trainer portal

| Feature | API |
|---|---|
| Profile tab (see `trainer-profile-tab.md`) | `GET /trainers/me/profile`, `POST /auth/logout` |
| Edit Profile (see `trainer-edit-profile.md`) | presign upload + `PATCH /trainers/me/profile` |
| Certifications (see `trainer-certifications.md`) | `GET /trainers/me/profile`, `POST /trainers/me/certifications` |

## Backend status (per `BACKEND_REQUIREMENTS_DASHBOARD.md`)

The trainer dashboard/clients/sessions/analytics/reviews/plans/schedule endpoints are
documented requirements; wiring them into these screens is future work (see
`docs/api-index.md` "Required but not called").

## Links

`docs/apis/trainer.md`, `docs/screens/trainer-profile-tab.md`,
`docs/screens/trainer-edit-profile.md`, `docs/screens/trainer-certifications.md`.