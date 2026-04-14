# SAMS Student Portal — Final Testing Checklist

Use this checklist when sharing the app with testers.

---

## 📦 Before You Start

- You are testing a **demo/fake-data** build of SAMS Student Portal.
- Internet is not required for core demo flows.
- If you find a bug, capture:
  - Device model + OS version
  - Screenshot/video
  - Steps to reproduce

---

## 1) Android Installation Checklist

### A. Download
- [ ] Open the shared APK link from Google Drive/Dropbox/etc.
- [ ] Download `app-release.apk` to the phone.

### B. Enable install from unknown sources
- [ ] On Android 8+:
  - `Settings` → `Apps` / `Security` → `Special app access` → `Install unknown apps`
  - Allow permission for the app used to open the APK (Chrome / Files / Drive).
- [ ] On older Android:
  - `Settings` → `Security` → enable `Unknown sources`.

### C. Install
- [ ] Open `app-release.apk`.
- [ ] Tap **Install**.
- [ ] Open the app successfully.

Expected result:
- [ ] App launches to SAMS splash/login without crash.

---

## 2) iOS Installation Checklist (Physical iPhone)

> iOS requires a **Mac** with Flutter and Xcode. Direct APK-style install is not possible on iPhone.

### A. Prerequisites
- [ ] Mac with **Flutter** installed
- [ ] **Xcode** installed
- [ ] Apple ID signed into Xcode
- [ ] Physical iPhone connected

### B. Build on Mac
```bash
flutter doctor
flutter pub get
cd ios
pod install
cd ..
flutter build ios --no-codesign
```

### C. Install from Xcode
- [ ] Open `ios/Runner.xcworkspace` in Xcode.
- [ ] Select **Runner** target → **Signing & Capabilities**.
- [ ] Enable **Automatically manage signing**.
- [ ] Choose your **Team**.
- [ ] Set a unique bundle ID (example: `com.yourname.samsstudentportal`).
- [ ] Select connected iPhone as run destination.
- [ ] Press **Run (▶)**.
- [ ] On iPhone, trust developer profile if prompted.

Expected result:
- [ ] App installs and opens on iPhone.

### Optional wider testing
- [ ] Use **TestFlight** (requires Apple Developer account + App Store Connect upload).

---

## 3) Login Flow Checklist

- [ ] Open app and reach Login screen.
- [ ] Test **Sign-in with QR code** button.
- [ ] Test **Login manually** path.
- [ ] Enter any fake credentials (demo app accepts any values).
- [ ] Confirm navigation to Home screen.

Expected result:
- [ ] Login always succeeds for demo/testing.

---

## 4) Student Identity Verification

After login, confirm these values appear in Home/Profile/Hostel areas:

- **Student Name:** `Mahmoud Bakir`
- **Student ID:** `11360`

- [ ] Name matches exactly.
- [ ] ID matches exactly.

---

## 5) Main Feature Testing Checklist

### A. Attendance (Color Coding + Actions)
- [ ] Open **Attendance** screen from Home.
- [ ] Verify **Overall Attendance** shows around `75%`.
- [ ] Verify color legend is visible:
  - Green: `≥ 80%`
  - Amber: `60%–79%`
  - Red: `< 60%`
- [ ] Confirm class list includes mixed percentages (high/medium/low).
- [ ] Tap **Mark Attendance** and verify success feedback/snackbar.

Expected result:
- [ ] Color coding and zone labels behave correctly.

### B. Scan Simulation
- [ ] Open **Scan** tab.
- [ ] Tap **Scan SAMS ID from gallery**.
- [ ] Tap **Scan SAMS ID with camera**.
- [ ] Confirm loading overlay appears (`Scanning...`).
- [ ] Confirm success dialog appears (`Scan successful`) with animation.
- [ ] Test **Scan again** and **Done** actions.

Expected result:
- [ ] Both scan actions complete with success feedback.

### C. Help Desk Submission
- [ ] Open **Help Desk** tab.
- [ ] Verify existing complaint cards load.
- [ ] Tap **Raise a complaint**.
- [ ] Select department and enter concern text.
- [ ] Tap **Submit**.
- [ ] Verify success feedback and returned complaint appears in list.

Expected result:
- [ ] New complaint is added immediately in UI.

### D. Bus Tracking
- [ ] Open **Bus Tracking** (via Menu/Profile route).
- [ ] Confirm live route map placeholder renders.
- [ ] Confirm route chips/stops are visible.
- [ ] Verify status text appears (example: `In Campus`).
- [ ] Verify stop timeline and ETA/next stop info render.

Expected result:
- [ ] Bus UI loads with realistic Cairo/SAMS route content.

### E. Additional sanity checks
- [ ] **Messages** list loads with sample threads.
- [ ] **Profile** page shows user card + quick options.
- [ ] **Hostel** cards load and are tappable.
- [ ] Pull-to-refresh works on list pages.

---

## 6) UX & Stability Checklist

- [ ] No crashes during 5–10 minutes of navigation.
- [ ] Buttons are responsive (no stuck loading states).
- [ ] Snackbars/dialogs appear clearly and dismiss correctly.
- [ ] Text remains readable on small screens.
- [ ] Back navigation works as expected.

---

## 7) Final Sign-off

- [ ] Android install verified
- [ ] iOS install verified (or TestFlight path prepared)
- [ ] Login flow verified
- [ ] Student identity verified (`Mahmoud Bakir` / `11360`)
- [ ] Core features verified (Attendance, Scan, Help Desk, Bus)
- [ ] App approved for demo distribution


---

### Report Template (for testers)

- Device:  
- OS version:  
- App version: `1.0.0+1`  
- Issue summary:  
- Steps to reproduce:  
- Expected result:  
- Actual result:  
- Attachment: screenshot/video
