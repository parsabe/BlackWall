# BlackWall App: Cross-Platform Flutter Client


<img src="https://github.com/parsabe/BlackWall/blob/app/phone.png" align="center">


[![Branch: App](https://img.shields.io/badge/branch-app-teal.svg)](https://github.com/parsabe/BlackWall/tree/app)
[![Master Branch](https://img.shields.io/badge/branch-master-blue.svg)](https://github.com/parsabe/BlackWall/tree/master)
[![Kernel Branch](https://img.shields.io/badge/branch-kernel-crimson.svg)](https://github.com/parsabe/BlackWall/tree/kernel)
[![Flutter SDK](](https://flutter.dev)[https://img.shields.io/badge/flutter-](https://img.shields.io/badge/flutter-)=3.0.0-blue.svg>)

The **App branch** contains the cross-platform Flutter/Dart client application for the BlackWall AI Guardrail and Autonomous Execution Sandbox.

---

## Ecosystem Navigation

- 🌐 [Master Branch (Architecture &amp; Global Entry Point)](https://github.com/parsabe/BlackWall/tree/master)
- ⚙️ [Kernel Branch (Backend, Classifier &amp; Gemma Brain)](https://github.com/parsabe/BlackWall/tree/kernel)

---

## Features & Architecture

### 1. Authentication & Account Management

- **Login, Signup & Forgot Password**: Full local credential flow with email/password validation, duplicate-account checks, and 6-digit code password reset (`ForgotPasswordScreen`).
- **Default Demo Account**: Seeded on first run (`operator@blackwall.sec` / `BlackWall2026!`) for quick testing.
- **Account Settings**: Edit profile (name & email), change password, sign out, and delete account directly from **Settings & Account**.
- **Session Persistence & Route Guard**: Encrypted token & account storage via `flutter_secure_storage` (with `shared_preferences` fallback), automatically guarded by `RouteGuard`.

### 2. Minimal UI, Light/Dark Themes & Typography

- **White & Blue Light Mode + Dark Mode**: Clean Apple/macOS-inspired aesthetic with a **Light / Dark / System** theme switcher persisted in **Settings & Account**.
- **macOS-Style Typography**: Configured with `.SF Pro Text` / `.SF Pro Display` (with `Inter` / `Roboto` / `sans-serif` fallbacks) for UI and prose, and `SF Mono` / `Menlo` for code.

### 3. BlackWall Chat & Sandbox Interface

- **Bottom-Anchored Chat**: Messages are anchored from the bottom (`reverse: true`) so the latest replies and updates are always visible above the input bar.
- **Enter to Send**: Pressing **Enter** sends the prompt immediately (`Shift+Enter` inserts a newline).
- **Rich Code & Text Formatting**: Fenced code blocks (` ```lang ... ``` `) render as dedicated code cards with a language label, horizontal scrolling, and a **Copy** button, alongside inline `` `code` `` and `**bold**` formatting.
- **Endpoint Connectivity**:
  - Dynamically configurable via Settings:
    - Remote Production Gateway: `https://parsabe.com/projects/blackwall/sandbox`
    - Local Host Gateway: `http://127.0.0.1:8080/sandbox` (communicating with Port 8000 & 11434)
    - Custom Dedicated Endpoint
  - Standardized JSON Payload: `{"prompt": "<user text>"}`
- **Trace Telemetry & Status Alerts**:
  - Per-message telemetry card (`Ingress Latency`, `Gemma 3 1B Inference`, `Egress Latency`, `Barrier Overhead`, `Total Latency`).
  - Status badges: `released`, `blocked_ingress`, `blocked_egress`, and `offline` (Fail-Closed).

### 4. Hardware & Performance Awareness

- **Configurable Timeout Handling**: Dual-barrier classification plus Gemma 3 1B inference can reach **60s to 100s on CPU hosts**. Timeouts are configurable from **15s to 180s** (default: **90s**).

---

## Installing on Android

Install the release APK (`build/app/outputs/flutter-apk/app-release.apk`):

- **Via ADB (phone or emulator connected over USB / ADB):**
  ```bash
  adb install -r build/app/outputs/flutter-apk/app-release.apk
  ```
- **Directly on an Android device:**
  1. Copy `build/app/outputs/flutter-apk/app-release.apk` to your phone.
  2. Tap the `.apk` file in your device's Files app.
  3. If prompted, allow **Install unknown apps** for your file manager/browser, then tap **Install**.

---

## Contributing

Contributions are welcome! To contribute to the BlackWall App:

1. Fork the repository and create a new branch from `app`:
   ```bash
   git checkout -b feat/your-feature
   ```
2. Make your changes and verify formatting, static analysis, and tests:
   ```bash
   flutter analyze
   flutter test
   ```
3. Commit your changes with a clear message and open a Pull Request against the `app` branch.

---

## License

This project is part of the **BlackWall** ecosystem. See the repository license terms or contact the maintainers for usage and distribution details.
