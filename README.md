# SAMS Student Portal

Student app for Sadat Academy for Management Sciences (SAMS), built with Flutter using Clean Architecture + BLoC.

## Highlights

- Feature modules: Home, Attendance, Messages, Scan, Help Desk, Bus, Hostel, Profile.
- Architecture: layered feature-first structure with domain/data/presentation separation.
- UI: modern SAMS-styled AppBar, Bottom Navigation, Snackbar feedback, and Lottie splash.
- Platforms: Android (APK) + Web.

## Tester Guide

- Use `TESTING_CHECKLIST.md` for final QA scenarios.

## Run locally (Web)

- Development run:
	- `flutter run -d chrome`
- Optional local release preview:
	- Build with `flutter build web --release`
	- Serve the `build/web` folder using any static server.

## Build (Web Release)

- `flutter build web --release --source-maps`

Build output will be generated under `build/web/`.
