# Screen: Add Member

- **File:** `lib/gym_owner/screens/add_member_screen.dart`
- **Route:** `MaterialPageRoute` from Members tab

## Screen Information

Single member creation with optional contact details.

## Fields

| Field | Type | Validation | Destination |
|---|---|---|---|
| First Name | Text | Required | `POST /gyms/:gymId/members.firstName` |
| Last Name | Text | Required | `POST /gyms/:gymId/members.lastName` |
| Email | Text | Optional (email format if filled) | `POST /gyms/:gymId/members.email` |
| Phone | Text | Optional (digits if filled) | `POST /gyms/:gymId/members.phone` |

## API Flow

```
Submit → POST /gyms/:gymId/members {firstName, lastName, email?, phone?}
       → success: pop with the created GymMember → Members list reloads
```

## User Action → API Mapping

| User Action | API Call | Notes |
|---|---|---|
| Tap "Add Member" | `POST /gyms/:gymId/members` | Optional fields omitted when empty |

## Database

Writes: Users + GymMemberships (backend creates/links the user).

## Validation / Error Handling

- Empty first/last name → SnackBar; invalid email/phone → SnackBar.
- Server `{message}` (e.g. email already registered) → SnackBar.

## Links

`docs/apis/gym-members.md`, `docs/screens/bulk-import.md`,
`docs/screens/enrollment.md`.