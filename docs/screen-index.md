# FitForge — Screen Index

Every user-facing screen/page/tab/sheet in the application. Columns: route (named route, or how
it's reached), frontend component, APIs used, and the documentation file.

Legend: ✅ real API · 🧪 mock data · 🔗 navigation only.

## Auth & Onboarding

| # | Screen | Route / entry | Frontend Component | APIs | Documentation |
|---|---|---|---|---|---|
| 1 | Welcome | page 0 of `/onboarding` (auto at startup) | `lib/onboarding/screens/welcome_screen.dart` | — | [onboarding.md](screens/onboarding.md) |
| 2 | Register (also onboarding page 1) | `/register` + embedded in `OnboardingFlow` | `lib/auth/screens/register_screen.dart` | POST `/auth/register`, GET `/users/me` | [register.md](screens/register.md) |
| 3 | Login | `/login` | `lib/auth/screens/login_screen.dart` | POST `/auth/login`, GET `/users/me`, external `GET /auth/google` | [login.md](screens/login.md) |
| 4 | Gym Owner Login | `/gym-owner-login` | `lib/auth/screens/gym_owner_login_screen.dart` | POST `/auth/login`, GET `/users/me` | [gym-owner-login.md](screens/gym-owner-login.md) |
| 5 | Trainer Login | `/trainer-login` | `lib/auth/screens/trainer_login_screen.dart` | POST `/auth/login`, GET `/users/me` | [trainer-login.md](screens/trainer-login.md) |
| 6 | Forgot Password | `/forgot-password` | `lib/auth/screens/forgot_password_screen.dart` | POST `/auth/forgot-password` | [forgot-password.md](screens/forgot-password.md) |
| 7 | Reset Password | `/reset-password` (deep link) | `lib/auth/screens/reset_password_screen.dart` | POST `/auth/reset-password` | [reset-password.md](screens/reset-password.md) |
| 8 | Email Verification | `/verify-email` (+ deep link) | `lib/auth/screens/email_verification_screen.dart` | POST `/auth/verify-email`, POST `/auth/resend-verification`, POST `/auth/logout` | [email-verification.md](screens/email-verification.md) |
| 9 | Onboarding wizard (Goal → Personal → Lifestyle → Final) | pages 2–5 of `/onboarding` | `goal_selection_screen.dart`, `personal_details_screen.dart`, `lifestyle_screen.dart`, `final_screen.dart` | PATCH `/members/me/profile`, GET `/members/me/profile`, POST `/members/me/complete-onboarding` | [onboarding.md](screens/onboarding.md) |

## Member Dashboard portal

| # | Screen | Route / entry | Frontend Component | APIs | Documentation |
|---|---|---|---|---|---|
| 10 | Home Dashboard | `/dashboard` | `lib/dashboard/screens/home_dashboard.dart` | — (mock) | [home-dashboard.md](screens/home-dashboard.md) |
| 11 | Diet Plan | embedded tab in Home Dashboard | `lib/dashboard/screens/diet_plan_screen.dart` | — (mock) | [dashboard-mock-screens.md](screens/dashboard-mock-screens.md) |
| 12 | Meal Builder | `MaterialPageRoute` from Diet Plan | `lib/dashboard/screens/meal_builder_screen.dart` | — (mock) | [dashboard-mock-screens.md](screens/dashboard-mock-screens.md) |
| 13 | Exercise Plan | embedded tab in Home Dashboard | `lib/dashboard/screens/exercise_plan_screen.dart` | — (mock) | [dashboard-mock-screens.md](screens/dashboard-mock-screens.md) |
| 14 | Exercise Detail | `MaterialPageRoute` from Exercise Plan | `lib/dashboard/screens/exercise_detail_screen.dart` | — (mock) | [dashboard-mock-screens.md](screens/dashboard-mock-screens.md) |
| 15 | Progress Analytics | embedded tab in Home Dashboard | `lib/dashboard/screens/progress_analytics_screen.dart` | — (mock) | [dashboard-mock-screens.md](screens/dashboard-mock-screens.md) |
| 16 | Streak & Rewards | embedded + pushed | `lib/dashboard/screens/rewards_screen.dart` | — (mock) | [dashboard-mock-screens.md](screens/dashboard-mock-screens.md) |
| 17 | Leaderboard | pushed from Rewards | `lib/dashboard/screens/leaderboard_screen.dart` | — (mock) | [dashboard-mock-screens.md](screens/dashboard-mock-screens.md) |
| 18 | Billing Plans | `/billing-plans` | `lib/dashboard/screens/billing_plans_screen.dart` | GET `/subscriptions/me`, GET `/subscriptions/me/entitlements`, POST `/subscriptions/me/trial` | [billing-plans.md](screens/billing-plans.md) |
| 19 | Profile | embedded tab in Home Dashboard | `lib/dashboard/screens/profile_screen.dart` | GET `/subscriptions/me`, GET `/subscriptions/me/entitlements`, GET `/members/me/profile`, POST `/auth/logout` | [profile.md](screens/profile.md) |
| 20 | Edit Profile | `MaterialPageRoute` from Profile | `lib/dashboard/screens/edit_profile_screen.dart` | GET/PATCH `/members/me/profile`, PATCH `/users/me`, POST `/media/presign-upload` (+ presigned PUT), GET `/users/me` | [edit-profile.md](screens/edit-profile.md) |
| 21 | Settings | `/settings` | `lib/dashboard/screens/settings_screen.dart` | GET `/auth/sessions`, DELETE `/auth/sessions/:id`, POST `/auth/logout-all` | [settings.md](screens/settings.md) |
| 22 | Join a Gym | `MaterialPageRoute` from Profile | `lib/dashboard/screens/join_gym_screen.dart` | POST `/gyms/join` | [join-gym.md](screens/join-gym.md) |
| 23 | QR Self Check-in | `MaterialPageRoute` from Profile | `lib/dashboard/screens/qr_checkin_screen.dart` | POST `/gyms/:gymId/attendance/check-in` | [qr-checkin.md](screens/qr-checkin.md) |
| 24 | Referrals | `MaterialPageRoute` from Profile | `lib/dashboard/screens/referral_screen.dart` | GET `/gyms/:gymId/referrals/my-code`, GET `/gyms/:gymId/referrals/my-referrals`, POST `/gyms/:gymId/referrals/redeem` | [referral.md](screens/referral.md) |

## Gym Owner portal

| # | Screen | Route / entry | Frontend Component | APIs | Documentation |
|---|---|---|---|---|---|
| 25 | Gym Owner Dashboard | `/gym-owner-dashboard` | `lib/gym_owner/screens/gym_owner_dashboard.dart` | GET `/gyms/:gymId/dashboard/overview`, GET `/gyms/:gymId/dashboard/today`, GET `/gyms/:gymId/dashboard/trainers`, GET `/gyms/:gymId/members` | [gym-owner-dashboard.md](screens/gym-owner-dashboard.md) |
| 26 | Members Tab | embedded tab (bottom nav) | `lib/gym_owner/screens/gym_owner_members_tab.dart` | GET `/gyms/:gymId/members`, GET `/gyms/:gymId/dashboard/trainers`, DELETE `/gyms/:gymId/members/:id`, PATCH `/gyms/:gymId/members/:id/trainer-config` | [gym-owner-members-tab.md](screens/gym-owner-members-tab.md) |
| 27 | Member Detail | `MaterialPageRoute` from Members tab | `lib/gym_owner/screens/member_detail_screen.dart` | GET `/gyms/:gymId/members/:id`, PATCH `/gyms/:gymId/members/:id/notes`, DELETE `/gyms/:gymId/members/:id` | [member-detail.md](screens/member-detail.md) |
| 28 | Add Member | `MaterialPageRoute` | `lib/gym_owner/screens/add_member_screen.dart` | POST `/gyms/:gymId/members` | [add-member.md](screens/add-member.md) |
| 29 | Bulk Import | `MaterialPageRoute` from Members tab | `lib/gym_owner/screens/bulk_import_screen.dart` | POST `/gyms/:gymId/members/import` (dryRun + commit) | [bulk-import.md](screens/bulk-import.md) |
| 30 | Attendance | `MaterialPageRoute` from Dashboard quick actions | `lib/gym_owner/screens/attendance_screen.dart` | GET `/gyms/:gymId/attendance`, GET `/gyms/:gymId/attendance/absence-alerts`, GET `/gyms/:gymId/members`, POST `/gyms/:gymId/attendance/manual`, DELETE `/gyms/:gymId/attendance/:id` | [attendance.md](screens/attendance.md) |
| 31 | Check-in Poster | `MaterialPageRoute` from Profile tab | `lib/gym_owner/screens/checkin_poster_screen.dart` | POST `/gyms/:gymId/qr-check-in-token/rotate` | [checkin-poster.md](screens/checkin-poster.md) |
| 32 | Create Gym | `/create-gym` | `lib/gym_owner/screens/create_gym_screen.dart` | POST `/gyms`, GET `/users/me` | [create-gym.md](screens/create-gym.md) |
| 33 | Gym Settings | `MaterialPageRoute` from Profile tab | `lib/gym_owner/screens/gym_settings_screen.dart` | GET `/gyms/:gymId`, PATCH `/gyms/:gymId`, GET `/media/status`, POST `/media/presign-upload` (+ presigned PUT) | [gym-settings.md](screens/gym-settings.md) |
| 34 | Membership Plans | `MaterialPageRoute` from Profile tab | `lib/gym_owner/screens/membership_plans_screen.dart` | GET/POST `/gyms/:gymId/plans`, PATCH/DELETE `/gyms/:gymId/plans/:id` | [membership-plans.md](screens/membership-plans.md) |
| 35 | Enrollment (member lifecycle) | `MaterialPageRoute` from Member Detail | `lib/gym_owner/screens/enrollment_screen.dart` | GET `/gyms/:gymId/memberships`, GET `/gyms/:gymId/plans`, POST `/gyms/:gymId/memberships`, POST `/gyms/:gymId/memberships/:id/freeze`, `/unfreeze`, `/renew` | [enrollment.md](screens/enrollment.md) |
| 36 | Payments | `MaterialPageRoute` from Dashboard quick actions | `lib/gym_owner/screens/payments_screen.dart` | GET/POST `/gyms/:gymId/payments`, POST `/gyms/:gymId/payments/:id/void`, GET `/gyms/:gymId/payments/dues` | [payments.md](screens/payments.md) |
| 37 | Coupons | `MaterialPageRoute` from Dashboard quick actions | `lib/gym_owner/screens/coupons_screen.dart` | GET/POST `/gyms/:gymId/coupons`, DELETE `/gyms/:gymId/coupons/:id`, GET `/gyms/:gymId/coupons/:id/redemptions` | [coupons.md](screens/coupons.md) |
| 38 | Leads (CRM) | `MaterialPageRoute` from Dashboard quick actions | `lib/gym_owner/screens/leads_screen.dart` | GET/POST `/gyms/:gymId/leads`, PATCH `/gyms/:gymId/leads/:id`, POST `/gyms/:gymId/leads/:id/convert`, GET `/gyms/:gymId/leads/metrics` | [leads.md](screens/leads.md) |
| 39 | Communications | `MaterialPageRoute` from Dashboard quick actions | `lib/gym_owner/screens/communications_screen.dart` | GET `/gyms/:gymId/communications`, POST `/gyms/:gymId/communications/:id/mark-sent`, POST `/gyms/:gymId/communications/announce`, external `wa.me` links | [communications.md](screens/communications.md) |
| 40 | Invite Codes | `MaterialPageRoute` from Profile tab | `lib/gym_owner/screens/invite_management_screen.dart` | GET/POST `/gyms/:gymId/invites`, POST `/gyms/:gymId/invites/:id/revoke` | [invite-management.md](screens/invite-management.md) |
| 41 | Referrals Config Tab | embedded tab (bottom nav) | `lib/gym_owner/screens/gym_owner_referrals_tab.dart` | GET/PUT `/gyms/:gymId/referrals/config` | [gym-owner-referrals-tab.md](screens/gym-owner-referrals-tab.md) |
| 42 | Notifications | `/gym-owner-notifications` | `lib/gym_owner/screens/gym_owner_notifications_screen.dart` | GET `/gyms/:gymId/dashboard/notifications`, POST `/gyms/:gymId/dashboard/notifications/:id/read` | [gym-owner-notifications.md](screens/gym-owner-notifications.md) |
| 43 | Support | `/gym-owner-support` | `lib/gym_owner/screens/gym_owner_support_screen.dart` | GET/POST `/gyms/:gymId/support` | [gym-owner-support.md](screens/gym-owner-support.md) |
| 44 | Join Requests | `/gym-owner-join-requests` | `lib/gym_owner/screens/gym_owner_join_requests_screen.dart` | GET `/gyms/:gymId/join-requests`, POST `/gyms/:gymId/join-requests/:id/approve`, POST `/gyms/:gymId/join-requests/:id/reject` | [gym-owner-join-requests.md](screens/gym-owner-join-requests.md) |
| 45 | Trainers | `/gym-owner-trainers` | `lib/gym_owner/screens/gym_owner_trainers_screen.dart` | GET `/gyms/:gymId/dashboard/trainers` (fallback GET `/gyms/:gymId/members?role=TRAINER`) | [gym-owner-trainers.md](screens/gym-owner-trainers.md) |
| 46 | Profile Tab | embedded tab (bottom nav) | `lib/gym_owner/screens/gym_owner_profile_tab.dart` | GET `/gyms/:gymId`, GET `/gyms/:gymId/subscription`, GET `/gyms/:gymId/dashboard/overview`, POST `/gyms/:gymId/subscription/trial`, POST `/auth/logout` | [gym-owner-profile-tab.md](screens/gym-owner-profile-tab.md) |
| 47 | Analytics Tab | embedded tab (bottom nav) | `lib/gym_owner/screens/gym_owner_analytics_tab.dart` | GET `/gyms/:gymId/dashboard/monthly`, GET `/gyms/:gymId/dashboard/growth`, GET `/gyms/:gymId/dashboard/progress`, GET `/gyms/:gymId/dashboard/subscription-usage` | [gym-owner-analytics-tab.md](screens/gym-owner-analytics-tab.md) |

## Trainer portal

| # | Screen | Route / entry | Frontend Component | APIs | Documentation |
|---|---|---|---|---|---|
| 48 | Trainer Dashboard | `/trainer-dashboard` | `lib/trainer/screens/trainer_dashboard.dart` | — (mock) | [trainer-mock-screens.md](screens/trainer-mock-screens.md) |
| 49 | Clients Tab | embedded tab | `lib/trainer/screens/trainer_clients_tab.dart` | — (mock) | [trainer-mock-screens.md](screens/trainer-mock-screens.md) |
| 50 | Client Detail | `MaterialPageRoute` from Clients tab | `lib/trainer/screens/trainer_client_detail_screen.dart` | — (mock) | [trainer-mock-screens.md](screens/trainer-mock-screens.md) |
| 51 | Analytics Tab | embedded tab | `lib/trainer/screens/trainer_analytics_tab.dart` | — (mock) | [trainer-mock-screens.md](screens/trainer-mock-screens.md) |
| 52 | Reviews Tab | embedded tab | `lib/trainer/screens/trainer_reviews_tab.dart` | — (mock) | [trainer-mock-screens.md](screens/trainer-mock-screens.md) |
| 53 | Plan Review | `MaterialPageRoute` from Reviews tab | `lib/trainer/screens/trainer_plan_review_screen.dart` | — (mock) | [trainer-mock-screens.md](screens/trainer-mock-screens.md) |
| 54 | Profile Tab | embedded tab | `lib/trainer/screens/trainer_profile_tab.dart` | GET `/trainers/me/profile`, POST `/auth/logout` | [trainer-profile-tab.md](screens/trainer-profile-tab.md) |
| 55 | Edit Profile | `MaterialPageRoute` from Profile tab | `lib/trainer/screens/trainer_edit_profile_screen.dart` | POST `/media/presign-upload` (+ presigned PUT), PATCH `/trainers/me/profile` | [trainer-edit-profile.md](screens/trainer-edit-profile.md) |
| 56 | Certifications | `MaterialPageRoute` from Profile tab | `lib/trainer/screens/trainer_certifications_screen.dart` | GET `/trainers/me/profile`, POST `/media/presign-upload` (+ presigned PUT), POST `/trainers/me/certifications` | [trainer-certifications.md](screens/trainer-certifications.md) |
| 57 | Feedback Sheet | bottom sheet from Client Detail | `lib/trainer/widgets/trainer_feedback_sheet.dart` | — (mock) | [trainer-mock-screens.md](screens/trainer-mock-screens.md) |
| 58 | Plan Editor Sheet | bottom sheet from Client Detail | `lib/trainer/widgets/trainer_plan_editor_sheet.dart` | — (mock) | [trainer-mock-screens.md](screens/trainer-mock-screens.md) |
| 59 | Schedule Card | presentational widget | `lib/trainer/widgets/trainer_schedule_card.dart` | — (mock) | [trainer-mock-screens.md](screens/trainer-mock-screens.md) |

## Admin

| # | Screen | Route / entry | Frontend Component | APIs | Documentation |
|---|---|---|---|---|---|
| 60 | Certification Review Queue | `MaterialPageRoute` from Settings (super-admin only) | `lib/admin/screens/certification_review_screen.dart` | GET `/trainers/certifications/pending`, PATCH `/trainers/certifications/:id/review` | [certification-review.md](screens/certification-review.md) |

**Total: 60 documented entries** (52 distinct screens + 8 shared/grouped widget entries).