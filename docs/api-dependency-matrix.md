# FitForge — API Dependency Matrix

Complete matrix: for every screen, every API it calls, when, with what request, and what
response. Backend controller/service/repository columns are **Not found in source code** unless
explicitly derived from the repo-root handoff docs (marked *handoff*). DB column lists the
frontend-observed entity (see [database-overview.md](database-overview.md)).

Request/response details are summarized here; full payloads are in the linked API docs.

## Auth & Onboarding screens

| Screen | API (Method + Endpoint) | Trigger | Request | Response | Backend Controller | DB |
|---|---|---|---|---|---|---|
| Login | POST `/auth/login` | Sign In | `{email, password}` | `{accessToken, refreshToken}` | Not found in source code | Tokens / Users |
| Login | GET `/users/me` | after login | — | User + `gymMemberships[]` | Not found in source code | Users, GymMemberships |
| Login | GET `/auth/google` (external) | Google button | — | browser redirect w/ tokens | Not found in source code | — |
| Gym Owner Login | POST `/auth/login` | Login | `{email, password}` | tokens | Not found in source code | Tokens / Users |
| Gym Owner Login | GET `/users/me` | after login | — | User | Not found in source code | Users |
| Trainer Login | POST `/auth/login` | Sign In | `{email, password}` | tokens | Not found in source code | Tokens / Users |
| Trainer Login | GET `/users/me` | after login | — | User | Not found in source code | Users |
| Register | POST `/auth/register` | Register | `{email, password, firstName, lastName}` | tokens | Not found in source code | Users |
| Register | GET `/users/me` | after register | — | User | Not found in source code | Users |
| Forgot Password | POST `/auth/forgot-password` | Send Reset Link | `{email}` | — | Not found in source code | Users |
| Reset Password | POST `/auth/reset-password` | Reset Password | `{token, newPassword}` | — | Not found in source code | Users |
| Email Verification | POST `/auth/verify-email` | auto/deep link | `{token}` | — | Not found in source code | Users |
| Email Verification | POST `/auth/resend-verification` | Resend button | — | — | Not found in source code | Users |
| Email Verification | POST `/auth/logout` | Use different account | `{refreshToken}` | — | Not found in source code | Sessions |
| Onboarding (all pages) | PATCH `/members/me/profile` | each step + final | partial `{sex, dateOfBirth, heightCm, weightKg, goal?, experienceLevel?, dietaryPreference?, equipmentAccess?, budgetBand?}` | MemberProfile | Not found in source code | MemberProfiles |
| Onboarding (resume) | GET `/members/me/profile` | app start (hydrate) | — | MemberProfile | Not found in source code | MemberProfiles |
| Onboarding (final) | POST `/members/me/complete-onboarding` | Generate My Plan | — | — | Not found in source code | MemberProfiles |

## Member dashboard screens

| Screen | API (Method + Endpoint) | Trigger | Request | Response | Backend Controller | DB |
|---|---|---|---|---|---|---|
| Home Dashboard | — | — | **MOCK — no APIs** | — | — | — |
| Diet Plan / Meal Builder / Exercise Plan / Exercise Detail / Progress Analytics / Rewards / Leaderboard | — | — | **MOCK — no APIs** | — | — | — |
| Billing Plans | GET `/subscriptions/me` | screen load | — | `{planCode, status, trialPhase, startDate, endDate, trialStartDate, trialEndDate}` | Not found in source code | MemberSubscriptions |
| Billing Plans | GET `/subscriptions/me/entitlements` | screen load | — | `{tier, features{aiPlans, trainerChat, nutritionAnalysis}}` | Not found in source code | MemberEntitlements |
| Billing Plans | POST `/subscriptions/me/trial` | Start trial CTA | `{planCode: "MEMBER_PREMIUM_AI"}` | — | Not found in source code | MemberSubscriptions |
| Profile | GET `/subscriptions/me` | screen load | — | MemberSubscription | Not found in source code | MemberSubscriptions |
| Profile | GET `/subscriptions/me/entitlements` | screen load | — | MemberEntitlements | Not found in source code | MemberEntitlements |
| Profile | GET `/members/me/profile` | screen load | — | MemberProfile | Not found in source code | MemberProfiles |
| Profile | POST `/auth/logout` | Log Out | `{refreshToken}` | — | Not found in source code | Sessions |
| Edit Profile | GET `/members/me/profile` | screen load | — | MemberProfile | Not found in source code | MemberProfiles |
| Edit Profile | POST `/media/presign-upload` | avatar pick | `{purpose: "AVATAR", contentType, sizeBytes}` | `{uploadUrl, publicUrl, requiredHeaders}` | Not found in source code | Media/Storage |
| Edit Profile | PUT `<uploadUrl>` | avatar pick | raw bytes | — | Not found in source code | Storage |
| Edit Profile | PATCH `/users/me` | Save | partial `{firstName?, lastName?, phone?, avatarUrl?}` | — | Not found in source code | Users |
| Edit Profile | PATCH `/members/me/profile` | Save | partial profile fields | MemberProfile | Not found in source code | MemberProfiles |
| Edit Profile | GET `/users/me` | Save (refreshUser) | — | User | Not found in source code | Users |
| Settings | GET `/auth/sessions` | screen load | — | `[{id, userAgent, createdAt, lastUsedAt}]` | Not found in source code | UserSessions |
| Settings | DELETE `/auth/sessions/:sessionId` | Revoke chip | — | — | Not found in source code | UserSessions |
| Settings | POST `/auth/logout-all` | Log out all devices | — | — | Not found in source code | UserSessions |
| Join a Gym | POST `/gyms/join` | Join Gym | `{code}` | `{gymId, membershipId, gymName, gym}` | Not found in source code | Gyms, GymMemberships |
| QR Self Check-in | POST `/gyms/:gymId/attendance/check-in` | Check In | `{qrToken}` | — | Not found in source code | Attendance |
| Referrals | GET `/gyms/:gymId/referrals/my-code` | screen load | — | `{code, totalReferrals, qualifiedReferrals}` | Not found in source code | ReferralCodes |
| Referrals | GET `/gyms/:gymId/referrals/my-referrals` | screen load | — | `[{id, referee, status, createdAt}]` (list or `{items}`) | Not found in source code | Referrals |
| Referrals | POST `/gyms/:gymId/referrals/redeem` | Redeem | `{code}` | — | Not found in source code | Referrals, Coupons |

## Gym owner screens

| Screen | API (Method + Endpoint) | Trigger | Request | Response | Backend Controller | DB |
|---|---|---|---|---|---|---|
| Gym Owner Dashboard | GET `/gyms/:gymId/dashboard/overview` | load | — | `{totalMembers, totalTrainers, activeMemberships, pendingJoinRequests, membershipRenewalsDue, revenueOverview{todayInr, monthInr}, unreadNotifications}` | Not found in source code | (aggregate) |
| Gym Owner Dashboard | GET `/gyms/:gymId/dashboard/today` | load | — | `{totalCheckIns, collectionsAmount, newJoinsCount, expiringSoonCount, totalDuesAmount}` | Not found in source code | (aggregate) |
| Gym Owner Dashboard | GET `/gyms/:gymId/dashboard/trainers` | load | — | `[GymTrainer]` (fallback: members?role=TRAINER) | Not found in source code | Users, GymMemberships |
| Gym Owner Dashboard | GET `/gyms/:gymId/members?page=1&limit=10&role=MEMBER` | load | query | `[GymMember]` | Not found in source code | GymMemberships |
| Members Tab | GET `/gyms/:gymId/members?page=1&limit=100` | load | query | `[GymMember]` | Not found in source code | GymMemberships |
| Members Tab | GET `/gyms/:gymId/dashboard/trainers` | load | — | `[GymTrainer]` | Not found in source code | — |
| Members Tab | DELETE `/gyms/:gymId/members/:membershipId` | Remove | — | — | Not found in source code | GymMemberships |
| Members Tab | PATCH `/gyms/:gymId/members/:membershipId/trainer-config` | Shift & Pay save | `{shiftSchedule?, commissionPercent?}` | — | Not found in source code | GymMemberships |
| Member Detail | GET `/gyms/:gymId/members/:membershipId` | load | — | GymMember 360° (profile + enrollments + attendance) | Not found in source code | GymMemberships, Enrollments, Attendance |
| Member Detail | PATCH `/gyms/:gymId/members/:membershipId/notes` | Save Notes | `{staffNotes}` | — | Not found in source code | GymMemberships |
| Member Detail | DELETE `/gyms/:gymId/members/:membershipId` | Remove from Gym | — | — | Not found in source code | GymMemberships |
| Add Member | POST `/gyms/:gymId/members` | Add Member | `{firstName, lastName?, email?, phone?}` | GymMember | Not found in source code | Users, GymMemberships |
| Bulk Import | POST `/gyms/:gymId/members/import` | preview (dryRun=true) then commit (dryRun=false) | `{dryRun, rows: [{...headers}]}` | `{rows: [{status, fullName, message, phone, email, index}], created, linkedExisting, alreadyMember, errors}` | Not found in source code | Users, GymMemberships |
| Attendance | GET `/gyms/:gymId/attendance?page=1&limit=100&date=YYYY-MM-DD` | load / date pick | query | `[AttendanceRecord]` | Not found in source code | Attendance |
| Attendance | GET `/gyms/:gymId/attendance/absence-alerts` | load tab 2 | — | `[AbsenceAlert]` | Not found in source code | (derived) |
| Attendance | GET `/gyms/:gymId/members?page=1&limit=200&role=MEMBER` | open manual picker | query | `[GymMember]` | Not found in source code | GymMemberships |
| Attendance | POST `/gyms/:gymId/attendance/manual` | Check In | `{userId}` | — | Not found in source code | Attendance |
| Attendance | DELETE `/gyms/:gymId/attendance/:attendanceId` | delete (owner/mgr) | — | — | Not found in source code | Attendance |
| Check-in Poster | POST `/gyms/:gymId/qr-check-in-token/rotate` | Generate/Rotate | — | `{qrCheckInSecret, ...}` | Not found in source code | Gyms |
| Create Gym | POST `/gyms` | Create Gym Profile | `{name, phone?, email?, addressLine, city?, state?, pincode?, referralCode?}` | `{id/gymId, membershipId}` | Not found in source code | Gyms, GymMemberships |
| Create Gym | GET `/users/me` | after create (refreshUser) | — | User | Not found in source code | Users |
| Gym Settings | GET `/gyms/:gymId` | load | — | full gym map | Not found in source code | Gyms |
| Gym Settings | GET `/media/status` | load | — | `{configured: bool}` | Not found in source code | Media config |
| Gym Settings | POST `/media/presign-upload` + PUT | uploads (logo/UPI QR/photo) | `{purpose: GYM_LOGO/GYM_UPI_QR/GYM_PHOTO, contentType, sizeBytes}` | `{uploadUrl, publicUrl}` | Not found in source code | Storage |
| Gym Settings | PATCH `/gyms/:gymId` | Save Changes | partial gym fields incl. `upiId`, `workingHours[7]`, `facilities[]`, `photoUrls[]`, `mutedOwnerAlertTypes[]` | — | Not found in source code | Gyms |
| Membership Plans | GET `/gyms/:gymId/plans?includeInactive=true?` | load / toggle | query | `[plan maps]` | Not found in source code | MembershipPlans |
| Membership Plans | POST `/gyms/:gymId/plans` | Create Plan | `{name, description?, type, durationDays?/sessionCount?, priceInr}` | plan map | Not found in source code | MembershipPlans |
| Membership Plans | PATCH `/gyms/:gymId/plans/:planId` | Edit | `{name?, description?, priceInr?}` | plan map | Not found in source code | MembershipPlans |
| Membership Plans | DELETE `/gyms/:gymId/plans/:planId` | Retire | — | — | Not found in source code | MembershipPlans |
| Enrollment | GET `/gyms/:gymId/memberships?page=1&limit=50&userId=<member>` | load | query | `[Enrollment]` | Not found in source code | Enrollments |
| Enrollment | GET `/gyms/:gymId/plans` | open enroll sheet | — | `[plan maps]` | Not found in source code | MembershipPlans |
| Enrollment | POST `/gyms/:gymId/memberships` | Confirm Enrollment | `{userId, planId, couponCode?, priceOverride?}` | Enrollment | Not found in source code | Enrollments |
| Enrollment | POST `/gyms/:gymId/memberships/:id/freeze` | Freeze | — | — | Not found in source code | Enrollments |
| Enrollment | POST `/gyms/:gymId/memberships/:id/unfreeze` | Unfreeze | — | — | Not found in source code | Enrollments |
| Enrollment | POST `/gyms/:gymId/memberships/:id/renew` | Renew | `{}` | Enrollment | Not found in source code | Enrollments |
| Payments | GET `/gyms/:gymId/payments?page=1&limit=50` | load | query | `[GymPayment]` | Not found in source code | Payments |
| Payments | GET `/gyms/:gymId/payments/dues` | load tab 2 | — | `[DuesSummary]` | Not found in source code | (computed) |
| Payments | POST `/gyms/:gymId/payments` | Record Payment | `{amountInr, method, enrollmentId?, paidAt?, notes?}` | GymPayment | Not found in source code | Payments |
| Payments | POST `/gyms/:gymId/payments/:paymentId/void` | Void | `{}` (reason omitted) | — | Not found in source code | Payments |
| Coupons | GET `/gyms/:gymId/coupons?includeInactive=true?` | load / toggle | query | `[GymCoupon]` | Not found in source code | Coupons |
| Coupons | POST `/gyms/:gymId/coupons` | New Coupon | `{code, type, value, usageLimit?}` | GymCoupon | Not found in source code | Coupons |
| Coupons | DELETE `/gyms/:gymId/coupons/:couponId` | Deactivate | — | — | Not found in source code | Coupons |
| Coupons | GET `/gyms/:gymId/coupons/:couponId/redemptions` | History sheet | — | `[{memberName, redeemedAt, ...}]` | Not found in source code | CouponRedemptions |
| Leads | GET `/gyms/:gymId/leads?page=1&limit=100&stage=?` | load / filter | query | `[GymLead]` | Not found in source code | Leads |
| Leads | GET `/gyms/:gymId/leads/metrics` | load | — | `{total, converted, ...}` | Not found in source code | (aggregate) |
| Leads | POST `/gyms/:gymId/leads` | Add Lead | `{name, phone?, email?, source}` | GymLead | Not found in source code | Leads |
| Leads | PATCH `/gyms/:gymId/leads/:leadId` | Move Stage | `{stage}` | GymLead | Not found in source code | Leads |
| Leads | POST `/gyms/:gymId/leads/:leadId/convert` | Convert | — | map (unused) | Not found in source code | Leads, Users, GymMemberships |
| Communications | GET `/gyms/:gymId/communications?page=1&limit=50&pendingOnly=?` | load / toggle | query | `[CommunicationLog]` | Not found in source code | CommunicationLogs |
| Communications | POST `/gyms/:gymId/communications/:commId/mark-sent` | Mark Sent | — | — | Not found in source code | CommunicationLogs |
| Communications | POST `/gyms/:gymId/communications/announce` | Send Announcement | `{title, body}` | — | Not found in source code | CommunicationLogs |
| Invite Codes | GET `/gyms/:gymId/invites` | load | — | `[{role, code, revokedAt, expiresAt, maxUses, usesCount}]` | Not found in source code | InviteCodes |
| Invite Codes | POST `/gyms/:gymId/invites` | New Invite | `{role, maxUses?, expiresAt?}` | map (unused) | Not found in source code | InviteCodes |
| Invite Codes | POST `/gyms/:gymId/invites/:inviteId/revoke` | Revoke | — | — | Not found in source code | InviteCodes |
| Referrals Tab | GET `/gyms/:gymId/referrals/config` | load | — | `{rewardType, rewardValue, isActive}` (404→null) | Not found in source code | ReferralConfig |
| Referrals Tab | PUT `/gyms/:gymId/referrals/config` | Save Reward Config | `{rewardType, rewardValue}` | — | Not found in source code | ReferralConfig |
| Notifications | GET `/gyms/:gymId/dashboard/notifications?unreadOnly=?` | load / toggle | query | `[OwnerNotification]` | Not found in source code | OwnerNotifications |
| Notifications | POST `/gyms/:gymId/dashboard/notifications/:logId/read` | tap card | — | — | Not found in source code | OwnerNotifications |
| Support | GET `/gyms/:gymId/support` | load | — | `[SupportRequest]` | Not found in source code | SupportRequests |
| Support | POST `/gyms/:gymId/support` | Submit Request | `{category, subject, message}` | SupportRequest | Not found in source code | SupportRequests |
| Join Requests | GET `/gyms/:gymId/join-requests` | load | — | `[JoinRequest]` | Not found in source code | GymMemberships |
| Join Requests | POST `/gyms/:gymId/join-requests/:membershipId/approve` | Accept | — | — | Not found in source code | GymMemberships |
| Join Requests | POST `/gyms/:gymId/join-requests/:membershipId/reject` | Reject | `{reason}` | — | Not found in source code | GymMemberships |
| Trainers | GET `/gyms/:gymId/dashboard/trainers` | load | — | `[GymTrainer]` | Not found in source code | Users, GymMemberships |
| Trainers (fallback) | GET `/gyms/:gymId/members?role=TRAINER` | if roster fails | query | `[GymTrainer]` | Not found in source code | GymMemberships |
| Profile Tab | GET `/gyms/:gymId` | load | — | gym map | Not found in source code | Gyms |
| Profile Tab | GET `/gyms/:gymId/subscription` | load | — | `{planCode, status, trialEndsAt}` (404→null) | Not found in source code | GymSubscriptions |
| Profile Tab | GET `/gyms/:gymId/dashboard/overview` | load | — | GymDashboardOverview | Not found in source code | (aggregate) |
| Profile Tab | POST `/gyms/:gymId/subscription/trial` | Start Free Trial | `{planCode: "GYM_PRO"}` | — | Not found in source code | GymSubscriptions |
| Profile Tab | POST `/auth/logout` | Log Out | `{refreshToken}` | — | Not found in source code | Sessions |
| Analytics Tab | GET `/gyms/:gymId/dashboard/monthly` | load | — | GymDashboardMonthly | Not found in source code | (aggregate) |
| Analytics Tab | GET `/gyms/:gymId/dashboard/growth` | load | — | `[{month, newMembers}]` | Not found in source code | (aggregate) |
| Analytics Tab | GET `/gyms/:gymId/dashboard/progress` | load | — | GymProgressOverview | Not found in source code | (aggregate) |
| Analytics Tab | GET `/gyms/:gymId/dashboard/subscription-usage` | load | — | GymSubscriptionUsage | Not found in source code | (aggregate) |

## Trainer screens

| Screen | API (Method + Endpoint) | Trigger | Request | Response | Backend Controller | DB |
|---|---|---|---|---|---|---|
| Trainer Dashboard / Clients / Client Detail / Analytics / Reviews / Plan Review / sheets | — | — | **MOCK — no APIs** | — | — | — |
| Trainer Profile Tab | GET `/trainers/me/profile` | load | — | TrainerProfile + certifications[] | Not found in source code | TrainerProfiles |
| Trainer Profile Tab | POST `/auth/logout` | Log Out | `{refreshToken}` | — | Not found in source code | Sessions |
| Trainer Edit Profile | POST `/media/presign-upload` + PUT | photo upload | `{purpose: "TRAINER_PHOTO", contentType, sizeBytes}` | `{uploadUrl, publicUrl}` | Not found in source code | Storage |
| Trainer Edit Profile | PATCH `/trainers/me/profile` | Save Changes | `{bio?, specializations?, experienceYears?, introVideoUrl?, photoUrls?}` | TrainerProfile | Not found in source code | TrainerProfiles |
| Trainer Certifications | GET `/trainers/me/profile` | load | — | TrainerProfile | Not found in source code | TrainerProfiles |
| Trainer Certifications | POST `/media/presign-upload` + PUT | file pick | `{purpose: "TRAINER_CERTIFICATION", contentType, sizeBytes}` | `{uploadUrl, publicUrl}` | Not found in source code | Storage |
| Trainer Certifications | POST `/trainers/me/certifications` | Submit for Review | `{title, issuer?, fileUrl}` | TrainerCertification | Not found in source code | TrainerCertifications |

## Admin

| Screen | API (Method + Endpoint) | Trigger | Request | Response | Backend Controller | DB |
|---|---|---|---|---|---|---|
| Certification Review | GET `/trainers/certifications/pending` | load | — | `[{id, title, issuer, trainerProfile{user{fullName, email}}, ...}]` or `{items}` | Not found in source code | TrainerCertifications |
| Certification Review | PATCH `/trainers/certifications/:id/review` | Approve/Reject | `{approve, rejectionReason?}` | — | Not found in source code | TrainerCertifications |

## Cross-cutting services

| Service | API | Trigger | Request | Response | Backend | DB |
|---|---|---|---|---|---|---|
| Token refresh (interceptor) | POST `/auth/refresh` | any 401 | `{refreshToken}` | `{accessToken, refreshToken}` | Not found in source code | Tokens |
| Media (all portals) | GET `/media/status` | gym settings / upload gating | — | `{configured}` | Not found in source code | Config |
| Media (all portals) | POST `/media/presign-upload` | any upload | `{purpose, contentType, sizeBytes}` | `{uploadUrl, publicUrl, requiredHeaders}` | Not found in source code | Storage |
| Media (all portals) | PUT `<uploadUrl>` | any upload | raw bytes | — | Not found in source code | Storage |

> Backend controller/service/repository names: **Not found in source code** — the backend is
> external to this repo. RBAC expectations (who may call what) are documented in
> `section2-handoff.md` (GymRolesGuard table) and in [authentication.md](authentication.md).