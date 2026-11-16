# BlackWall App: Cross-Platform Flutter Client

[![Branch: App](https://img.shields.io/badge/branch-app-teal.svg)](https://github.com/parsabe/BlackWall/tree/app)
[![Master Branch](https://img.shields.io/badge/branch-master-blue.svg)](https://github.com/parsabe/BlackWall/tree/master)
[![Kernel Branch](https://img.shields.io/badge/branch-kernel-crimson.svg)](https://github.com/parsabe/BlackWall/tree/kernel)
[![Flutter SDK](https://img.shields.io/badge/flutter->=3.0.0-blue.svg)](https://flutter.dev)

The **App branch** contains the complete cross-platform Flutter/Dart client application for the BlackWall AI Guardrail and Autonomous Execution Sandbox.

---

## Ecosystem Navigation

- 🌐 [Master Branch (Architecture & Global Entry Point)](https://github.com/parsabe/BlackWall/tree/master)
- ⚙️ [Kernel Branch (Backend, Classifier & Gemma Brain)](https://github.com/parsabe/BlackWall/tree/kernel)

---

## Features & Architecture

### 1. Authentication Flow & Security Clearance
- **Login & Registration Screens**: Modern cybersecurity-themed UI with email validation, passkey validation, and loading indicators.
- **Session/Auth Service**: Secure local persistence using `flutter_secure_storage` with seamless `shared_preferences` fallback for encrypted session tokens.
- **Route Guard**: The `RouteGuard` widget automatically shields all sandbox and chat routes, redirecting unauthenticated sessions to the login gateway.

### 2. BlackWall Chat & Sandbox Interface
- **Endpoint Connectivity**:
  - Dynamically configurable via Settings:
    - Remote Production Gateway: `https://parsabe.com/projects/blackwall/sandbox`
    - Local Host Gateway: `http://127.0.0.1:8080/sandbox` (communicating with Port 8000 & 11434)
    - Custom Enterprise Gateway
  - Standardized JSON Payload: `{"prompt": "<user text>"}`
- **Fail-Closed & Pipeline Visualizer**:
  - Displays real-time flow through the **Dual-Barrier Sandwich** (`Ingress Check -> Gemma 3 1B Brain -> Egress Check`).
  - Full trace telemetry extracted from every response:
    - Ingress check latency & safety status (Class 0, 1, 2)
    - Gemma 3 1B inference time
    - Egress check latency & safety status (Class 0, 1, 2)
    - Total barrier overhead time (ms)
    - Total end-to-end request duration
  - Visual status alerts:
    - `released`: Shows vetted model response with emerald clearance badge.
    - `blocked_ingress`: Prompts marked unsafe are blocked before reaching Gemma.
    - `blocked_egress`: Gemma responses marked unsafe are withheld from output.
    - `offline` / Fail-Closed: System warning if the guardrail or LLM is unreachable.

### 3. Hardware & Performance Awareness
- **Configurable Timeout Handling**: The dual-barrier pipeline combined with Gemma 3 1B inference can reach **60s to 100s on CPU hosts**.
- Client allows configuring timeouts between **15s and 180s** (default: 90s) to prevent premature disconnection during deep reasoning tasks.

---

## Project Structure

```
lib/
├── core/
│   ├── constants/app_constants.dart      # Endpoints, default timeouts, keys
│   └── theme/app_theme.dart              # Dark cybersecurity styling
├── models/
│   ├── chat_message.dart                 # Message model & status enums
│   ├── server_config.dart                # Gateway endpoint & timeout state
│   ├── telemetry_model.dart              # Barrier latency & safety class model
│   └── user_model.dart                   # Operator identity & auth token
├── providers/
│   ├── auth_provider.dart                # Auth state notifier
│   ├── chat_provider.dart                # Chat stream & history notifier
│   └── settings_provider.dart            # Server & timeout preferences
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart             # Operator login UI
│   │   └── signup_screen.dart            # Operator registration UI
│   ├── chat/
│   │   ├── chat_screen.dart              # Sandbox interface & preset chips
│   │   └── widgets/
│   │       ├── message_bubble.dart       # Message bubble with status alerts
│   │       ├── pipeline_visualizer.dart  # Dual-barrier flow diagram
│   │       └── telemetry_card.dart       # Latency & safety metrics card
│   └── settings/
│       └── settings_screen.dart          # Endpoint switcher & timeout slider
├── services/
│   ├── auth_service.dart                 # Session management
│   ├── blackwall_service.dart            # HTTP client & fail-closed engine
│   └── storage_service.dart              # Secure storage wrapper
└── widgets/
    ├── route_guard.dart                  # Auth route protector
    └── status_badge.dart                 # Color-coded barrier alert chip
```

---

## Running the Application

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`

### Run Locally
```bash
# Fetch dependencies
flutter pub get

# Run on Web (Chrome)
flutter run -d chrome

# Run on Linux Desktop
flutter run -d linux

# Run Unit & Widget Tests
flutter test
```
