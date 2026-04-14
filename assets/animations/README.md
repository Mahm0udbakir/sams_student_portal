# SAMS Lottie Assets (Lightweight)

Place lightweight Lottie JSON files here using these exact names:

- `splash_academic_light.json`
- `success_check_light.json`
- `empty_state_light.json`

Used in code:

- Splash animation: `assets/animations/splash_academic_light.json`
- Scan success dialog: `assets/animations/success_check_light.json`
- Shared empty states: `assets/animations/empty_state_light.json`

Performance guidance:

- Keep each file ideally **under 100 KB** (hard max ~200 KB)
- Keep loops short and simple (2–3 seconds)
- Prefer vector-only animation (no embedded image layers)
- Moderate layer count and avoid heavy blur/masks

All three animation usages include graceful icon fallbacks if a file is missing.
