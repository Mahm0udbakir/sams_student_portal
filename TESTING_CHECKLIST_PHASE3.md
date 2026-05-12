# Phase 3 Testing Checklist

## Environment & Secrets
- [ ] Copy `.env.example` to `.env` and fill `BREVO_API_KEY`, `BREVO_TEMPLATE_ID`, `BREVO_SENDER_EMAIL`, and `BREVO_SENDER_NAME`.
- [ ] Confirm `flutter_dotenv` loads values in `main.dart` without crashing when `.env` is absent.
- [ ] Confirm Brevo OTP delivery fails with a clear message when API keys are missing.

## Auth Flow
- [ ] Launch the app with no signed-in user and confirm it lands on the login screen.
- [ ] Sign up with a valid university email and confirm a verification code is sent.
- [ ] Verify OTP with a correct code and confirm the app navigates to Home.
- [ ] Try an invalid email and confirm the error message is specific to `AuthErrorType.invalidEmail`.
- [ ] Try an email outside the approved university domain list and confirm signup is blocked with the allowed-domain message.
- [ ] Try a weak password and confirm the weak-password validation is shown.
- [ ] Try signing in with the wrong password and confirm the error message is specific to `AuthErrorType.invalidCredential` or `AuthErrorType.wrongPassword`.
- [ ] Confirm logout returns the user to the signed-out state.
- [ ] Confirm the profile/home identity updates when the Firestore `users/{uid}` document changes.
- [ ] Confirm `studentId`, `firstName`, and `lastName` are stored in the user document after signup.

## Admin Flow
- [ ] Sign in with an account whose Firestore user document has `role: admin` or the `admin` custom claim enabled in security rules.
- [ ] Confirm the Admin tools option appears only for admins in the Profile screen.
- [ ] Open `/admin` or tap Admin tools and confirm the attendance admin screen loads.
- [ ] Create a sample `attendance_sessions` document and confirm it includes `sessionId`, `subject`, `date`, `time`, `room`, `isActive`, and `createdBy`.
- [ ] Create a live QR attendance session and confirm a QR card appears with the generated payload.
- [ ] Confirm non-admin accounts are redirected away from `/admin`.

## QR Attendance
- [ ] Open the attendance screen on a physical device with a working camera.
- [ ] Grant camera permission and confirm the scanner opens only after permission approval.
- [ ] Scan a valid QR payload containing a `sessionId`.
- [ ] Confirm the attendance record is written to `attendance_records` with `studentUid`, `studentId`, `sessionId`, and `timestamp`.
- [ ] Confirm the active sessions list updates in realtime from `attendance_sessions`.
- [ ] Confirm the overall attendance percentage updates automatically after the write.
- [ ] Confirm the subject/class percentages update automatically when records change.
- [ ] Scan the same session twice and confirm the duplicate-prevention message appears.
- [ ] Scan an invalid QR payload and confirm the user sees a clear failure message.
- [ ] Confirm the session QR widget generates a scannable code that contains `sessionId` metadata.

## Firestore Rules
- [ ] Confirm authenticated users can read their own profile document.
- [ ] Confirm authenticated users can only write their own attendance record entries.
- [ ] Confirm unauthenticated users cannot read/write attendance records.
- [ ] Confirm `attendance_sessions` are readable by authenticated users and writable only by admin/custom claim users.
- [ ] Confirm `announcements` are readable by authenticated users and writable only by admin/custom claim users.
- [ ] Confirm `users/{uid}` rejects writes where `uid != request.auth.uid`.
- [ ] Confirm the `users` document schema includes `firstName`, `lastName`, `studentId`, `email`, `role`, `emailVerified`, `createdAt`, and `updatedAt`.
- [ ] Confirm the Firestore console suggests any missing composite indexes before release and create them if prompted.

## Offline Behavior
- [ ] Disable network and open the app after a successful sign-in.
- [ ] Confirm previously cached profile/home data still renders if Firestore cache is available.
- [ ] Confirm attendance writes either queue or fail gracefully with a clear offline message.
- [ ] Confirm duplicate scans still do not create multiple attendance records after reconnecting.
- [ ] Confirm the app does not crash when the camera is unavailable or permission is denied.
- [ ] Re-enable network and confirm data refreshes correctly.

## Regression Checks
- [ ] Home, Profile, Bus, Hostel, Messages, Help Desk, and Announcements screens still open correctly.
- [ ] Widget tests pass.
- [ ] Analyzer reports no errors.
- [ ] Firestore collection names match the code: `users`, `attendance_sessions`, `attendance_records`, and `auth_otps`.

## Release Prep
- [ ] Confirm Android camera permission is declared in `AndroidManifest.xml`.
- [ ] Confirm iOS camera usage description exists in `Info.plist`.
- [ ] Confirm app version/build numbers are set for release.
- [ ] Confirm app icon and splash assets are present and render correctly.
- [ ] Confirm the release signing config is in place for Android and iOS.
- [ ] Confirm debug banners, fake repository files, and temporary console logs are removed.
- [ ] Confirm store listing metadata, screenshots, and privacy policy are ready.
