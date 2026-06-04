# 🧠 Project Memory: KZ Flutter Monorepo

## 1. Overview & Stack

- **Architecture Type:** Monorepo with Melos + Clean Architecture (Domain/Data/Presentation layers)
- **SDK Version:** Dart SDK ^3.9.2, Flutter SDK ^3.9.2
- **State Management:** `bloc` / `flutter_bloc` v9.x — feature-scoped cubits per module
- **Routing:** `auto_route` v9.x — type-safe navigation with guards and nested routers
- **DI:** `get_it` + `injectable` v2.4.x — generated inversion of control container
- **Networking:** 
  - `dio` v5.9.x — base HTTP client
  - `http_client` (custom wrapper) — automatic token refresh + request queue
- **Code Generation:**
  - `freezed` v2.5.x — immutable models and union types
  - `json_serializable` v6.8.x — JSON serialization
  - `injectable_generator`, `auto_route_generator`, `build_runner`
- **Local Storage:**
  - `hive` + `hive_flutter` — key-value storage for lightweight data
  - `flutter_secure_storage` — secure token storage (access/refresh tokens)
- **Security:** PIN-lock (`pin_lock`), biometric auth via `local_auth`, JWT tokens with auto-refresh
- **Analytics & Logging:**
  - Talker (`talker`, `talker_flutter`, `talker_bloc_logger`, `talker_dio_logger`) — dev logging and BLoC events
  - Firebase (Crashlytics, Remote Config) + AppMetrica + AppsFlyer
- **Localization:** `easy_localization` v3.0.x (RU/KK locales)

## 2. Project Structure & Entry Points

**Root:** `./` — Melos workspace with `melos_kz_flutter.iml`

### Core Directories

```
./
├── apps/                       # Applications
│   ├── kzp/                    # Kazakhstan app (main entry point)
│   │   ├── lib/
│   │   │   ├── main.dart       # App entry: Firebase, DI, Localization, BlocObserver setup
│   │   │   ├── router/         # AutoRoute config + guards + navigator key
│   │   │   ├── di/             # Injection modules (core, api, domain, features)
│   │   │   └── features/       # Feature modules: auth, profile, pin_lock, support, etc.
│   │   ├── app_packages/
│   │   │   ├── domain/         # Domain layer (interfaces + models + use cases)
│   │   │   └── data/           # Data layer (repositories + datasources + mappers)
│   │   ├── assets/             # Translations, SVGs, chatra.html
│   │   └── pubspec.yaml        # Dependencies and dart-define flags
│   ├── mxp/                    # Mexico app (Vivus MX)
│   └── rfp/                    # Russia app
├── packages/                   # Shared packages
│   ├── auth_package/
│   ├── core/
│   ├── device_ids/
│   ├── force_update/
│   ├── kz_api/                 # API client (LkApi, RegistrationApi, ConfigApi)
│   ├── kz_qa_api/
│   ├── kz_uikit/
│   ├── mx_api/
│   ├── password_recovery_webview/
│   ├── pin_lock/
│   ├── qa_api/
│   ├── shared/
│   │   ├── http_client/        # HTTP wrapper with automatic token refresh
│   │   ├── logger/             # Logger wrapper
│   │   └── retry_helper/
│   ├── singular_metrics/
│   └── juicyscorekitflutter-master/
└── pubspec.yaml                # Workspace definition + Melos scripts
```

### Key Entry Points

| File | Purpose |
|------|---------|
| `apps/kzp/lib/main.dart` | App bootstrap: Firebase, Talker, DI, Router, ATT (iOS IDFA) |
| `apps/kzp/router/app_router.dart` | AutoRoute config with guards (auth, pin, force_update) |
| `apps/kzp/di/injection.dart` | `@injectable_init()` setup for GetIt container |

## 3. Architectural Pillars

### State Management
- **Pattern:** BLoC/Cubit per feature screen/module.
- **Global Observer:** `TalkerBlocObserver` — logs all BLoC events/states/errors to Talker UI.
- **Location:** Features are in `apps/kzp/lib/features/`, each with `cubit/`, `screen.dart`, `widgets/`.

### Routing
- **Package:** `auto_route` v9.x — `@AutoRouterConfig(replaceInRouteName: 'Screen,Route')`.
- **Pattern:** Nested routers (`RootStackRouter`) + route guards.
- **Guards:** 
  - `AuthTokenGuard` — blocks routes when no valid access token
  - `PinRouteGuard` — enforces PIN unlock before sensitive screens
  - `ForceUpdateGuard` — redirects if app version outdated
- **Navigation Helpers:** Static methods in `AppRouter` (e.g., `openLoginScreen()`, `resetToRegistration()`).
- **Key Feature:** Deep linking support with type-safe route parameters.

### Network & Data Layer

#### Shared HTTP Client (`packages/shared/http_client/`)
- **Wrapper over Dio** with automatic:
  - Access token injection into headers
  - Token refresh on 401 errors (with request queue)
  - Retry logic via `shared_retry_helper`
- **Token Storage:** SecureStorage implementation of `TokenStorage` interface.

#### API Client (`packages/kz_api/`)
- **Endpoints:**
  - `LkApi` — personal account (login, client info, payments, products)
  - `RegistrationApi` — registration flow stages + Verigram/KYC
  - `ConfigApi` — Django config retrieval
- **Models:** Freezed + JSON serializable (`freezed_annotation`, `json_annotation`)
- **Integration:** Injected via `@LazySingleton()` in DI modules.

#### Domain Layer (`apps/kzp/app_packages/domain/`)
- **Entities:** Auth status, token pair, client data, loan info, product calc, payment types, verigram flow
- **Repositories:** Interfaces for auth, config, profile, registration, SMS timeout, documents
- **Use Cases:** Logout use case (and likely more)
- **Dependencies:** Only `domain` + `freezed_annotation`, `injectable`

#### Data Layer (`apps/kzp/app_packages/data/`)
- **Datasources:**
  - `LkDataSource` — remote API calls via `kz_api`
  - `RegistrationDataSource` — registration flow
  - `ConfigDataSource` — config retrieval
- **Mappers:** `AuthMapper`, `ConfigMapper`, `RegistrationMapper`, `VerigramFlowMapper`
- **Repositories:** Implementation of domain interfaces (e.g., `AuthRepositoryImpl`)
- **Storage:** Hive for local data + SecureStorage for tokens

### Dependency Injection

**Pattern:** Service locator with GetIt + auto-generated bindings via `injectable`.

**Modules:**
```
apps/kzp/lib/di/modules/
├── core/            # Dio, HttpClient, Talker
├── kz_api/          # API clients
├── data/            # Repository implementations
├── domain/          # Use cases
└── features/        # Cubits (e.g., splash_module)
```

**Usage:**
```dart
// DI init in main.dart
await configureDependencies(talker: talker);

// Access anywhere via getIt
final httpClient = getIt<HttpClient>();
final authRepository = getIt<AuthRepository>();
```

## 4. API & Integrations

### Registration Flow (KZP)
- **Stages:** 
  - Stage 1: IIN/Phone/Email → Stage 2: SMS code
  - Stage 3: KYC via Verigram or Biometric → Stage 4: Manual data entry (fallback) → Stage 5: Password + Loan data
- **Verigram Integration:**
  - Polling `flowStatus` every 10s until `interrupter.service_status` changes to `pass/fail`
  - Supports resumption via `esign/upload` + `continue` endpoints
- **Biometric:** PKB or F2F provider (configurable)
- **Duplication Handlers:** Mobile/IIN/Email checks with automatic redirect or prompt

### Token Management
- **Storage:** `FlutterSecureStorage` for access/refresh tokens
- **Flow:**
  1. Request fails with 401 → queue request
  2. Refresh token → update storage + retry queued requests
  3. If refresh fails → clear tokens → redirect to login

### Security Features
- PIN-lock on app startup (`pin_lock` package)
- Biometric unlock (`local_auth`)
- Auto logout after inactivity (via `auth_token_guard`)
- Secure token storage (no plaintext)

## 5. Critical Package Versions & Gotchas

| Package | Version | Notes |
|---------|---------|-------|
| `auto_route` | ^9.0.0 | Use `@AutoRouteConfig(replaceInRouteName: 'Screen,Route')` for codegen |
| `bloc`/`flutter_bloc` | ^9.0.0 | BlocObserver is `TalkerBlocObserver` — logs all events/states/errors |
| `injectable` | ^2.4.1 | Add `@LazySingleton()` to DI modules; scan via `@injectable_init()` |
| `freezed` | ^2.5.2 | Use `@freezed` for models + `json_annotation` for JSON |
| `http_client` | local package | Automatic token refresh — never use raw Dio directly |
| `hive` | ^2.2.3 | Local key-value storage (not used for tokens) |
| `flutter_secure_storage` | ^9.2.2 | Only for sensitive data (tokens, PIN) |

### Common Gotchas
1. **Code Generation:** Run `melos generate` (or `melos exec -- dart run build_runner build`) after adding Freezed/Injectable models.
2. **DI Modules:** Must be explicitly exported in `apps/kzp/lib/di/injection.dart` for generator to pick them up.
3. **Guards:** AutoRoute guards must return `Future<bool>` — use `await guard.canNavigate(...)` pattern.
4. **Talker UI:** Only available in debug (`useLogger=true`) via floating bug button or `/talker` route.

## 6. Build & CI/CD

**Commands (from root):**
- `melos bootstrap` — install all workspace dependencies
- `melos generate` — run build_runner for all packages
- `melos analyze` / `melos test` — static analysis and tests
- `cd apps/kzp && fvm flutter build appbundle --release` — release AAB

**Dart Defines (Debug/Dev Builds):**
- `BASE_URL`, `USE_LOGGER`, `SKIP_KYC`, `ENABLE_QA_SMS`

**Artifacts:**
- AAB: `apps/kzp/build/app/outputs/bundle/release/app-release.aab`
- APK: `apps/kzp/build/app/outputs/flutter-apk/app-release.apk`

## 7. Testing Strategy

- **Unit Tests:** `package:test` for domain/data logic
- **Widget Tests:** `flutter_test` + `WidgetTester`
- **Integration Tests:** Flutter Driver via MCP tools (not yet configured in CI)

---

**Last Updated:** Generated during last session analysis 04.06.2026
**Author:** Senior Dart/Flutter Architect Agent.