# FitForge — API Index

All endpoints are relative to the base URL `https://fitos-backend-55g6.onrender.com/api/v1`.
`<gymId>` = id of the currently selected gym (from `currentGymIdProvider`). All requests carry
`Authorization: Bearer <accessToken>` except where noted. Responses are the `{success, data}`
envelope unwrapped — payloads shown here are the inner `data`.

## A. Frontend-used APIs

### A1. Authentication & session (`apis/authentication.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 1 | POST | `/auth/login` | Login, Gym Owner Login, Trainer Login | Issue access + refresh tokens |
| 2 | POST | `/auth/register` | Register | Create account, issue tokens |
| 3 | POST | `/auth/logout` | Email Verification, Profile, Trainer/Gym-owner Profile tabs | Revoke refresh token |
| 4 | POST | `/auth/refresh` | (Dio interceptor, auto) | Rotate refresh token on 401 |
| 5 | POST | `/auth/forgot-password` | Forgot Password | Send reset link |
| 6 | POST | `/auth/reset-password` | Reset Password | Set new password with token |
| 7 | POST | `/auth/verify-email` | Email Verification | Verify email with token |
| 8 | POST | `/auth/resend-verification` | Email Verification | Resend verification email |
| 9 | GET | `/users/me` | Login/Register/Trainer/Gym-owner login, Create Gym, Edit Profile, app startup | Current user + gymMemberships |
| 10 | GET | `/auth/sessions` | Settings | List active device sessions |
| 11 | DELETE | `/auth/sessions/:sessionId` | Settings | Revoke one session |
| 12 | POST | `/auth/logout-all` | Settings | Revoke all devices |

### A2. Member profile & onboarding (`apis/member-profile.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 13 | GET | `/members/me/profile` | Onboarding (hydrate), Edit Profile, Profile | Goal-intake fitness profile |
| 14 | PATCH | `/members/me/profile` | Onboarding (per step + final), Edit Profile | Partial profile update |
| 15 | POST | `/members/me/complete-onboarding` | Onboarding final step | Mark onboarding complete |
| 16 | PATCH | `/users/me` | Edit Profile | Update name/phone/avatar |

### A3. Subscriptions & entitlements (`apis/subscriptions.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 17 | GET | `/subscriptions/me` | Billing Plans, Profile | Current SaaS subscription/trial |
| 18 | GET | `/subscriptions/me/entitlements` | Billing Plans, Profile, premium gates | Tier + feature flags |
| 19 | POST | `/subscriptions/me/trial` | Billing Plans | Start 7-day premium trial |

### A4. Media upload (`apis/media.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 20 | GET | `/media/status` | Gym Settings | Storage configured? |
| 21 | POST | `/media/presign-upload` | Edit Profile, Gym Settings, Trainer Edit Profile, Trainer Certifications | Get presigned upload URL |
| 22 | PUT | `<uploadUrl>` (presigned storage URL, unauthenticated) | same screens | Upload file bytes |

### A5. Member gym actions (`apis/gym-member-actions.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 23 | POST | `/gyms/join` | Join a Gym | Redeem invite code |
| 24 | POST | `/gyms/:gymId/attendance/check-in` | QR Self Check-in | Self check-in with QR token |
| 25 | GET | `/gyms/:gymId/referrals/my-code` | Referrals | Get/mint shareable referral code |
| 26 | POST | `/gyms/:gymId/referrals/redeem` | Referrals | Redeem friend's code |
| 27 | GET | `/gyms/:gymId/referrals/my-referrals` | Referrals | My referral list + status |

### A6. Gym management (`apis/gym-management.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 28 | POST | `/gyms` | Create Gym | Create gym profile |
| 29 | GET | `/gyms/:gymId` | Gym Settings, Gym Owner Profile tab | Full gym profile |
| 30 | PATCH | `/gyms/:gymId` | Gym Settings | Update gym profile/UPI/working hours etc. |
| 31 | GET | `/gyms/:gymId/subscription` | Gym Owner Profile tab | Gym SaaS subscription/trial state |
| 32 | POST | `/gyms/:gymId/subscription/trial` | Gym Owner Profile tab | Start gym SaaS trial |

### A7. Gym dashboards & notifications (`apis/gym-dashboard.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 33 | GET | `/gyms/:gymId/dashboard/overview` | Gym Owner Dashboard, Profile tab | KPI widget set |
| 34 | GET | `/gyms/:gymId/dashboard/today` | Gym Owner Dashboard | Today's stats |
| 35 | GET | `/gyms/:gymId/dashboard/monthly` | Analytics tab | Monthly stats |
| 36 | GET | `/gyms/:gymId/dashboard/growth` | Analytics tab | 6-month growth trend |
| 37 | GET | `/gyms/:gymId/dashboard/progress` | Analytics tab | Engagement progress overview |
| 38 | GET | `/gyms/:gymId/dashboard/subscription-usage` | Analytics tab | Members by premium tier |
| 39 | GET | `/gyms/:gymId/dashboard/trainers` | Gym Owner Dashboard, Members tab, Trainers screen | Trainer roster |
| 40 | GET | `/gyms/:gymId/dashboard/notifications` | Notifications | Owner alert feed |
| 41 | POST | `/gyms/:gymId/dashboard/notifications/:logId/read` | Notifications | Mark alert read |

### A8. Members & staff (`apis/gym-members.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 42 | GET | `/gyms/:gymId/members` | Dashboard, Members tab, Attendance picker, Trainers (fallback) | List members |
| 43 | GET | `/gyms/:gymId/members/:membershipId` | Member Detail | 360° member view |
| 44 | POST | `/gyms/:gymId/members` | Add Member | Add walk-in member |
| 45 | POST | `/gyms/:gymId/members/import` | Bulk Import | CSV/Excel import (dry-run + commit) |
| 46 | PATCH | `/gyms/:gymId/members/:membershipId/notes` | Member Detail | Private staff notes |
| 47 | PATCH | `/gyms/:gymId/members/:membershipId/trainer-config` | Members tab | Trainer shift/commission |
| 48 | DELETE | `/gyms/:gymId/members/:membershipId` | Members tab, Member Detail | Remove member/staff |

### A9. Membership plans & enrollments (`apis/gym-memberships.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 49 | GET | `/gyms/:gymId/plans` | Membership Plans, Enrollment | Plan catalog |
| 50 | POST | `/gyms/:gymId/plans` | Membership Plans | Create plan |
| 51 | PATCH | `/gyms/:gymId/plans/:planId` | Membership Plans | Edit plan |
| 52 | DELETE | `/gyms/:gymId/plans/:planId` | Membership Plans | Retire plan |
| 53 | POST | `/gyms/:gymId/memberships` | Enrollment | Enroll member in plan |
| 54 | GET | `/gyms/:gymId/memberships` | Enrollment | List enrollments |
| 55 | POST | `/gyms/:gymId/memberships/:enrollmentId/freeze` | Enrollment | Freeze enrollment |
| 56 | POST | `/gyms/:gymId/memberships/:enrollmentId/unfreeze` | Enrollment | Unfreeze (extends endDate) |
| 57 | POST | `/gyms/:gymId/memberships/:enrollmentId/renew` | Enrollment | Renew membership |

### A10. Payments (`apis/gym-payments.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 58 | GET | `/gyms/:gymId/payments` | Payments | Payment history |
| 59 | POST | `/gyms/:gymId/payments` | Payments | Record manual payment |
| 60 | POST | `/gyms/:gymId/payments/:paymentId/void` | Payments | Void payment (restores dues) |
| 61 | GET | `/gyms/:gymId/payments/dues` | Payments | Dues dashboard |

### A11. Attendance (`apis/gym-attendance.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 62 | GET | `/gyms/:gymId/attendance` | Attendance | Per-day attendance list |
| 63 | POST | `/gyms/:gymId/attendance/manual` | Attendance | Front-desk check-in (today) |
| 64 | DELETE | `/gyms/:gymId/attendance/:attendanceId` | Attendance | Delete entry (owner/manager) |
| 65 | GET | `/gyms/:gymId/attendance/absence-alerts` | Attendance | Members absent N days |

### A12. Coupons (`apis/gym-coupons.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 66 | GET | `/gyms/:gymId/coupons` | Coupons | List coupons |
| 67 | POST | `/gyms/:gymId/coupons` | Coupons | Create coupon |
| 68 | DELETE | `/gyms/:gymId/coupons/:couponId` | Coupons | Deactivate coupon |
| 69 | GET | `/gyms/:gymId/coupons/:couponId/redemptions` | Coupons | Redemption history |

### A13. Referral config (owner-side) (`apis/gym-referrals-leads-communications.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 70 | GET | `/gyms/:gymId/referrals/config` | Referrals tab | Get reward config |
| 71 | PUT | `/gyms/:gymId/referrals/config` | Referrals tab | Set reward config |

### A14. Leads (`apis/gym-referrals-leads-communications.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 72 | GET | `/gyms/:gymId/leads` | Leads | List leads (stage/source/assignee filter) |
| 73 | POST | `/gyms/:gymId/leads` | Leads | Capture lead |
| 74 | PATCH | `/gyms/:gymId/leads/:leadId` | Leads | Update stage/notes/follow-up |
| 75 | POST | `/gyms/:gymId/leads/:leadId/convert` | Leads | Convert lead to member |
| 76 | GET | `/gyms/:gymId/leads/metrics` | Leads | Conversion metrics |

### A15. Communications (`apis/gym-referrals-leads-communications.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 77 | GET | `/gyms/:gymId/communications` | Communications | Staff outbox |
| 78 | POST | `/gyms/:gymId/communications/:commId/mark-sent` | Communications | Confirm WhatsApp sent |
| 79 | POST | `/gyms/:gymId/communications/announce` | Communications | Broadcast announcement |

### A16. Invites (`apis/gym-invites-joins-support.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 80 | GET | `/gyms/:gymId/invites` | Invite Codes | List invite codes |
| 81 | POST | `/gyms/:gymId/invites` | Invite Codes | Create invite |
| 82 | POST | `/gyms/:gymId/invites/:inviteId/revoke` | Invite Codes | Revoke invite |

### A17. Join requests (`apis/gym-invites-joins-support.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 83 | GET | `/gyms/:gymId/join-requests` | Join Requests | Pending self-serve joins |
| 84 | POST | `/gyms/:gymId/join-requests/:membershipId/approve` | Join Requests | Approve (activate membership) |
| 85 | POST | `/gyms/:gymId/join-requests/:membershipId/reject` | Join Requests | Reject with reason |

### A18. Support (`apis/gym-invites-joins-support.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 86 | GET | `/gyms/:gymId/support` | Support | List support requests |
| 87 | POST | `/gyms/:gymId/support` | Support | Create support request |

### A19. Trainer (`apis/trainer.md`)

| # | Method | Endpoint | Used by screens | Purpose |
|---|---|---|---|---|
| 88 | GET | `/trainers/me/profile` | Trainer Profile tab, Certifications | Trainer profile + certifications |
| 89 | PATCH | `/trainers/me/profile` | Trainer Edit Profile | Update trainer profile |
| 90 | POST | `/trainers/me/certifications` | Trainer Certifications | Submit certification |
| 91 | GET | `/trainers/certifications/pending` | Certification Review (admin) | Pending review queue |
| 92 | PATCH | `/trainers/certifications/:certificationId/review` | Certification Review (admin) | Approve/reject certification |

## B. Backend APIs defined in the service layer but NOT called by any screen

(Verified by grepping every screen/widget file for the service method name.)

| # | Method | Endpoint | Service method | Why unused |
|---|---|---|---|---|
| B1 | POST | `/gyms/:gymId/join-code/rotate` | `GymOwnerService.rotateJoinCode` | No screen calls it (join codes are rotated via invite revoke) |
| B2 | GET | `/gyms/:gymId` (member variant) | `MemberService.getGymProfile` | No member screen calls it |
| B3 | GET | `/gyms/:gymId/memberships/:enrollmentId` | `GymOwnerService.getEnrollment` | Screens use the list endpoint instead |
| B4 | POST | `/gyms/:gymId/memberships/:enrollmentId/change-plan` | `GymOwnerService.changePlan` | Not wired to any screen yet |
| B5 | POST | `/gyms/:gymId/memberships/:enrollmentId/transfer` | `GymOwnerService.transferEnrollment` | Not wired to any screen yet |
| B6 | POST | `/gyms/:gymId/memberships/:enrollmentId/assign-trainer` | `GymOwnerService.assignTrainerToEnrollment` | Not wired to any screen yet |
| B7 | POST | `/gyms/:gymId/memberships/:enrollmentId/session-logs` | `GymOwnerService.logSession` | Not wired to any screen yet |
| B8 | GET | `/gyms/:gymId/memberships/:enrollmentId/session-logs` | `GymOwnerService.getSessionLogs` | Not wired to any screen yet |
| B9 | GET | `/gyms/:gymId/payments/:paymentId/receipt` | `GymOwnerService.getPaymentReceipt` | Not wired to any screen yet |
| B10 | POST | `/gyms/:gymId/attendance` | `GymOwnerService.addAttendanceEntry` | Screens use manual + QR check-in only |
| B11 | PATCH | `/gyms/:gymId/attendance/:attendanceId` | `GymOwnerService.updateAttendanceEntry` | Not wired to any screen yet |
| B12 | PATCH | `/gyms/:gymId/coupons/:couponId` | `GymOwnerService.updateCoupon` | Screens only create/deactivate |
| B13 | PATCH | `/gyms/:gymId/members/:membershipId/profile` | `GymOwnerService.updateMemberRecord` | Staff record edit (photo/ID/emergency) not wired yet |
| B14 | GET | `/media/status` (member service variant) | `MemberService.getMediaStatus` | Duplicate of `MediaUploadService.isStorageConfigured` |

## C. External APIs / non-HTTP integrations

| # | Type | Target | Used by | Purpose |
|---|---|---|---|---|
| C1 | Browser OAuth | `GET https://fitos-backend-55g6.onrender.com/api/v1/auth/google` (via `url_launcher`) | Login screen | Google social login |
| C2 | Deep links | `fitforge://oauth/callback?...`, `fitforge://<host>/verify-email?token=`, `fitforge://<host>/reset-password?token=` (`app_links`) | app entry | OAuth + email-verification + password-reset |
| C3 | WhatsApp | `wa.me` tap-to-send links returned by `GET /gyms/:gymId/communications` (`url_launcher`) | Communications screen | Front-desk WhatsApp send |
| C4 | Storage | `PUT <presignedUrl>` (raw `Dio()`, no auth) | all upload flows | Direct-to-storage file upload |
| C5 | OpenAPI spec | `https://fitos-backend-55g6.onrender.com/docs` / `docs-json` | (reference) | Live backend reference |

## D. APIs the backend should provide but does not (per BACKEND_REQUIREMENTS_DASHBOARD.md)

These are documented as *requirements*, not implemented endpoints, for the mock member-dashboard
screens: `GET /members/me/dashboard/today`, `POST /members/me/logs/water`,
`PATCH /members/me/tasks/:taskId`, `GET /members/me/diet/today`,
`PATCH /members/me/diet/meals/:mealId/check`, `GET /food-items`, `POST /members/me/diet/meals`,
`POST /ai/generate-meal-plan`, `GET /members/me/analytics/summary`,
`POST /members/me/logs/weight`, `POST /members/me/logs/measurements`,
`GET /members/me/analytics/export`, `GET /members/me/rewards/overview`,
`POST /members/me/rewards/check-in`, `GET /rewards/store`,
`POST /rewards/store/:rewardId/redeem`, `GET /leaderboards`,
`GET /subscriptions/me/invoices`.