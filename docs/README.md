# FitForge — API & Screen Documentation

Complete, source-code-derived documentation of the **FitForge** application: every screen, every
frontend API call, and how they map to the backend.

## What the project does

FitForge is a **gamified fitness & nutrition app** built with Flutter. It has three user portals:

1. **Member portal** — goal-intake onboarding wizard, home dashboard with daily tracking
   (mock), diet/exercise plans (mock), billing plans (real subscription APIs), profile &
   settings, gym join, QR check-in, referrals.
2. **Gym Owner portal** — gym creation/settings, member management, membership plans &
   enrollments, payments & dues, attendance, coupons, leads CRM, communications outbox,
   invites, referrals config, notifications, support, dashboards & analytics.
3. **Trainer portal** — trainer profile & certification submission (real APIs); clients,
   analytics, reviews and plan review are **mock-only** right now.

## Frontend technology

| Aspect | Technology |
|---|---|
| Framework | Flutter (Dart SDK ^3.10.4), Material Design |
| State management | Riverpod 2.x (`flutter_riverpod`) — `StateNotifierProvider`, `FutureProvider`, `StateProvider` |
| HTTP client | Dio 5.x (single shared instance with interceptor chain) |
| Token storage | `flutter_secure_storage` (keys `fitforge_access_token`, `fitforge_refresh_token`) |
| Deep links | `app_links` (Google OAuth callback, verify-email / reset-password tokens) |
| Other | `qr_flutter` (QR rendering), `image_picker` / `file_picker` / `excel` / `csv` (bulk import), `url_launcher` (Google OAuth browser + wa.me links) |

## Backend technology

The backend is **not part of this repository** (frontend-only repo). The Flutter app talks to the
live **FitOS** backend (NestJS-style, Swagger at `https://fitos-backend-55g6.onrender.com/docs`).

- API base URL: `https://fitos-backend-55g6.onrender.com/api/v1`
- Request/response envelope: `{ "success": true, "data": ... }` (unwrapped by the Dio response
  interceptor; errors use `{ "message": ... }`)
- Auth: JWT **Bearer** access token + rotating refresh token (`POST /auth/refresh`)
- Roles (per-gym): `GYM_OWNER`, `GYM_MANAGER`, `FRONT_DESK`, `TRAINER`, `MEMBER`
- Free-tier Render hosting: 30–50 s cold starts after idle → frontend uses 60 s timeouts.

> Because the backend source is not in this repo, backend-side details (controller classes,
> service/repository internals, DB tables, HTTP status code lists) are marked
> **`Not found in source code`** where they cannot be derived. The companion handoff documents
> in the repo root (`section2-handoff.md`, `BACKEND_REQUIREMENTS_DASHBOARD.md`, `GAP_LOG.md`)
> were used where explicitly noted.

## Database

No database code exists in this repo. What is known about the backend schema comes from
frontend models + the repo-root handoff docs. See [database-overview.md](database-overview.md).

## Authentication

See [authentication.md](authentication.md) for the full flow:

- `POST /auth/login` / `POST /auth/register` → access + refresh tokens
- `GET /users/me` → user + `gymMemberships[]` (drives role-based routing)
- 401 → automatic `POST /auth/refresh` with **shared in-flight deduplication** (refresh tokens
  rotate and are invalidated on every use)
- `POST /auth/logout` revokes the refresh token server-side.

## Documentation structure

```text
docs/
├── README.md                     ← this file
├── project-overview.md           ← architecture, code layout, data-flow walkthrough
├── screen-index.md               ← every screen → route → component → APIs → doc link
├── api-index.md                  ← every API (frontend-used / backend-only / external)
├── api-dependency-matrix.md      ← Screen × API × trigger × backend mapping matrix
├── authentication.md             ← auth flows, tokens, session management
├── database-overview.md          ← entities/tables inferred from frontend models + handoff docs
├── screens/                      ← one doc per screen (or per mock group)
│   ├── login.md
│   ├── ...
└── apis/                         ← one doc per backend module
    ├── authentication.md
    ├── member-profile.md
    ├── ...
```

## How screens map to APIs

Every screen file in `lib/` was traced to its API calls. The pattern is:

```text
Screen/Widget (lib/<module>/screens/*.dart)
  └─ Riverpod provider (ref.read(...Provider))
       └─ Service class (lib/services/*.dart)
            └─ dio.<method>('<endpoint>', data: {...}, queryParameters: {...})
                 └─ https://fitos-backend-55g6.onrender.com/api/v1<endpoint>
```

Exceptions (screens calling `dio` directly, bypassing the service layer):

- `forgot_password_screen.dart` → `POST /auth/forgot-password`
- `reset_password_screen.dart` → `POST /auth/reset-password`
- `email_verification_screen.dart` → `POST /auth/verify-email`, `POST /auth/resend-verification`
- `auth_provider.dart` / `onboarding_provider.dart` → auth + profile endpoints (providers,
  not screens, but still bypass the service classes)

## How APIs map to backend code

Backend source is unavailable in this repo. For each API the docs record:

- the exact HTTP method + endpoint the frontend calls,
- the exact request payload/query the frontend sends (field names verbatim from source),
- the response fields the frontend parses (verbatim from `lib/models/*.dart`),
- the backend controller/method/service/repository/table **only where stated in the repo-root
  handoff docs**; otherwise `Not found in source code`.

## Conventions used in this documentation

- **Endpoints** are written relative to the base URL (`/auth/login` = `https://fitos-backend-55g6.onrender.com/api/v1/auth/login`).
- **Request/response fields are taken verbatim from source code.** Nothing is invented. Unknown
  fields are written as `Not found in source code`.
- **`<gymId>`** means the id of the currently selected gym (Riverpod `currentGymIdProvider`,
  sourced from the logged-in user's `gymMemberships[]` or the create-gym response).
- **Response envelope**: unless noted, all responses are `{ "success": true, "data": <payload> }`
  and the payload shown in the docs is the inner `data`.
- **Error shape**: `{ "message": string | string[] , "error"?: string }`. The Dio error
  interceptor normalizes `message` (arrays are joined with `", "`) into a single string that
  screens display via `friendlyApiError()` or SnackBars.
- Screens showing mock data are explicitly marked **MOCK** — they make no network calls.

## Related documents in the repo root

| File | Purpose |
|---|---|
| `section2-handoff.md` | Backend handoff for the Gym Owner module (52 endpoints, RBAC table, key journeys) |
| `BACKEND_REQUIREMENTS_DASHBOARD.md` | Backend requirements spec for the member dashboard (mostly unimplemented — mock screens) |
| `GAP_LOG.md` | Known frontend↔backend gaps (join-requests vs invites ambiguity, referral tab vs coupons, missing member transaction history) |
