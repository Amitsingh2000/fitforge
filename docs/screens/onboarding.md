# Screen: Onboarding (wizard)

- **Files:** `lib/onboarding/screens/{welcome,goal_selection,personal_details,lifestyle,final}_screen.dart`
- **Route:** `/onboarding` — reached when the member profile is incomplete
- **State:** `onboardingProvider` (Riverpod) drives step flow, saves, and the final submit

## Screen Information

A 5-step wizard (Welcome → Goal Selection → Personal Details → Lifestyle → Final) built on
**progressive save**: each step that collects data immediately calls
`PATCH /members/me/profile` with only the fields of that step (fire-and-forget). On revisit
it hydrates from `GET /members/me/profile` and resumes. The final step runs the complete
profile payload then `POST /members/me/complete-onboarding`.

## Fields per step

| Step | Fields | Field → API |
|---|---|---|
| Welcome | (static; buttons Next) | — |
| Goal Selection | Goal cards | `PATCH /members/me/profile {goal}` |
| Personal Details | Gender, Age slider | `PATCH … {sex, dateOfBirth}` (age→`YYYY-MM-01` derived from birth year) |
| Lifestyle | Height, Weight sliders | `PATCH … {heightCm, weightKg}` |
| Final | (confirmation; "Generate My Plan") | `PATCH /members/me/profile` (all collected) then `POST /members/me/complete-onboarding` |

Goal enum values sent: `FAT_LOSS` / `MUSCLE_GAIN` / `GENERAL_FITNESS` (the wizard only
offers these three; `STRENGTH`/`SPORT_SPECIFIC` exist on Edit Profile).

## API Flow

```
Open (resume) → GET /members/me/profile  (hydrateFromBackend; failure tolerated → start fresh)
Step save     → PATCH /members/me/profile {step fields}
Final         → PATCH /members/me/profile {goal, sex, dateOfBirth, heightCm, weightKg}
              → POST /members/me/complete-onboarding {}
              → refresh user → route to dashboard
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Select goal | `PATCH /members/me/profile` | Fire-and-forget, non-blocking |
| Set gender/age | `PATCH /members/me/profile` | — |
| Set height/weight | `PATCH /members/me/profile` | — |
| Tap "Generate My Plan" | `PATCH /members/me/profile` → `POST /members/me/complete-onboarding` | POST failure aborts with SnackBar |
| App restart mid-wizard | `GET /members/me/profile` | Resumes at the correct step |

## Database

Writes: MemberProfiles (goal intake, metrics). See `database-overview.md`.

## Validation / Error Handling

- PATCH saves are best-effort; a failed POST on the final step shows a SnackBar and keeps
  the wizard open (`isCompleteForBackend` gates whether all backend-required fields are set).
- Hydration failure does not block a fresh wizard.

## Links

`docs/apis/member-profile.md`, `docs/screens/edit-profile.md`,
`docs/screens/dashboard-mock-screens.md` (plan screens the wizard unlocks).