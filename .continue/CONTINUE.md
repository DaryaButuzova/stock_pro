# KZ Flutter Monorepo - Development Guide

## Project Overview

This is a **Flutter monorepository** for building cross-platform mobile applications across multiple countries (Kazakhstan, Mexico, Russia). The project follows Clean Architecture principles and uses a modular structure to share common functionality while maintaining country-specific implementations.

### Key Technologies

- **Flutter SDK**: ^3.9.2 | Dart SDK: ^3.9.2
- **State Management**: Bloc/BLoC pattern with `flutter_bloc`
- **Navigation**: Auto-route for type-safe routing
- **Dependency Injection**: GetIt + Injectable
- **Code Generation**: Freezed, JsonSerializable, Injectable, AutoRoute
- **HTTP Client**: Dio with custom token management and automatic refresh
- **Security**: FlutterSecureStorage, PIN-lock, biometric authentication
- **Monitoring**: Firebase Analytics/Crashlytics, AppMetrica, AppsFlyer
- **Build Management**: Melos for monorepo orchestration, FVM for Flutter version control

### High-Level Architecture

```
kz_flutter/ (Monorepo Root)
├── apps/                          # Country-specific applications
│   ├── kzp/                       # Kazakhstan application
│   ├── mxp/                       # Mexico application (Vivus)
│   └── rfp/                       # Russia application
│
└── packages/                      # Shared libraries
    ├── shared/                    # Cross-app shared code
    │   ├── http_client/
    │   ├── logger/
    │   ├── webview/
    │   └── retry_helper/
    ├── kz_api/                    # Kazakhstan API models and clients
    ├── mx_api/                    # Mexico API models and clients
    ├── qa_api/                    # QA-specific API endpoints
    └── [feature-packages]/        # Reusable feature packages
```

## Getting Started

### Prerequisites

1. **Flutter SDK**: Version 3.9.2+ (managed via FVM)
2. **Dart SDK**: Version 3.9.2+
3. **Melos**: `dart pub global activate melos`
4. **FVM** (Recommended): Flutter Version Management
5. **IDE**: VS Code with Dart/Flutter extensions or Android Studio

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd kz_flutter
   ```

2. **Install FVM and set up Flutter version**

   ```bash
   # Install FVM if not already installed
   dart pub global activate fvm
   
   # Set Flutter version from .fvmrc
   fvm install
   fvm use
   ```

3. **Bootstrap the monorepo**

   ```bash
   melos bootstrap
   ```

4. **Generate code** (if needed)

   ```bash
   melos generate
   ```

### Basic Commands

```bash
# Install dependencies for all packages
melos bootstrap

# Run the Kazakhstan app (default)
melos run

# Generate code for all packages
melos generate

# Run tests across all packages
melos test

# Analyze code quality
melos analyze

# Format all Dart files
melos format
```

## Project Structure

### Applications (`apps/`)

Each application follows the standard Flutter structure with Clean Architecture layers:

```
apps/kzp/
├── lib/
│   ├── main.dart                  # Application entry point
│   ├── di/                        # Dependency injection modules
│   │   └── modules/               # Feature-specific DI modules
│   ├── features/                  # Feature modules (UI layer)
│   │   ├── auth/
│   │   ├── profile/
│   │   ├── splash/
│   │   └── ...
│   ├── router/                    # Navigation configuration
│   ├── push/                      # Push notification handling
│   └── core/                      # Core utilities and extensions
├── app_packages/                  # Domain + Data layers (Clean Architecture)
│   ├── domain/                    # Business logic, models, repositories
│   └── data/                      # Repository implementations, datasources
└── assets/                        # Static resources
```

### Shared Packages (`packages/`)

#### Core Packages

- **`kz_api`**: API models and clients for Kazakhstan backend services
- **`mx_api`**: API models and clients for Mexico backend services
- **`qa_api`**: QA-specific API endpoints for testing

#### Shared Components

- **`shared/http_client`**: HTTP client with automatic token management
- **`shared/logger`**: Logging utilities using Talker
- **`shared/webview`**: Reusable WebView component
- **`shared/recaptcha_flutter`**: reCAPTCHA integration

#### Feature Packages

- **`pin_lock`**: PIN code protection with biometric support
- **`force_update`**: Force update functionality
- **`device_ids`**: Device identifier management
- **`singular_metrics`**: Analytics integration

### Code Generation Structure

The project uses `build_runner` for code generation. Generated files are stored alongside source files:

```
lib/features/auth/
├── cubit/                         # BLoC/Cubit implementations
├── pages/                         # Screen widgets
└── models/
    ├── login_request.g.dart       # Generated Freezed/JSON code
    └── ...
```

## Development Workflow

### Coding Standards

1. **Architecture**: Follow Clean Architecture principles (Presentation → Domain → Data)
2. **State Management**: Use Bloc/Cubit pattern with `flutter_bloc`
3. **Dependency Injection**: Use `injectable` and `get_it`
4. **Code Style**: 
   - Run `melos format` before commits
   - Use `melos analyze` to catch issues early
   - Follow Dart best practices (see `analysis_options.yaml`)

### Feature Development

1. **Create feature module** in `apps/kzp/lib/features/`

   ```
   apps/kzp/lib/features/feature_name/
   ├── cubit/
   │   ├── cubit.dart
   │   └── state.dart
   ├── pages/
   │   ├── screen_widget.dart
   │   └── widgets/
   └── models/
       └── model.g.dart
   ```

2. **Update DI modules** in `apps/kzp/lib/di/modules/features/`
3. **Register routes** in the router configuration
4. **Run code generation**: `flutter pub run build_runner build --delete-conflicting-outputs`

### Testing

```bash
# Run all tests
melos test

# Run specific test file
cd apps/kzp && flutter test test/features/auth/login_test.dart

# Generate coverage report
melos test:coverage
```

### Code Generation Commands

```bash
# Full code generation for all packages
melos generate

# Watch mode (auto-generate on changes)
melos generate:watch

# For specific package only
cd apps/kzp && flutter pub run build_runner watch --delete-conflicting-outputs

# Clean generated files
melos clean:build
```

## Common Tasks

### Adding a New API Endpoint

1. Define request/response models in `packages/kz_api/lib/src/models/`
2. Create API service interface in `packages/kz_api/lib/src/services/`
3. Implement the service in `packages/kz_api/lib/src/services/impl/`
4. Add endpoint to repository interface in `apps/kzp/app_packages/domain/`
5. Implement repository method in `apps/kzp/app_packages/data/`

### Adding a New Feature

1. Create feature directory: `apps/kzp/lib/features/new_feature/`
2. Define domain models and use cases in `domain/` layer
3. Implement data sources and repository methods in `data/` layer
4. Build UI components with BLoC/Cubit in presentation layer
5. Register dependencies in DI modules
6. Add routes to router configuration

### Debugging

```bash
# Run app with logging enabled
cd apps/kzp && fvm flutter run --dart-define=USE_LOGGER=true

# View logs (Talker UI appears as floating button in debug mode)
# Tap the bug icon in bottom-right corner during runtime

# Enable skip KYC for testing
fvm flutter run --dart-define=SKIP_KYC=true
```

### Building for Different Environments

```bash
# Debug build with custom API URL
cd apps/kzp && fvm flutter run \
  --dart-define=BASE_URL=http://dev-api.example.com \
  --dart-define=USE_LOGGER=true

# Release APK for Kazakhstan
fvm flutter build apk --release

# Release App Bundle
fvm flutter build appbundle --release

# iOS build
fvm flutter build ios --release
```

## Key Concepts

### Clean Architecture Layers

1. **Presentation Layer** (`apps/kzp/lib/`)
   - UI components, screens, widgets
   - BLoC/Cubit for state management
   - Navigation logic

2. **Domain Layer** (`apps/kzp/app_packages/domain/`)
   - Business entities/models
   - Repository interfaces
   - Use cases (business operations)

3. **Data Layer** (`apps/kzp/app_packages/data/`)
   - Repository implementations
   - API datasources
   - Local storage (Hive, SecureStorage)
   - Mappers between API and domain models

### Dependency Injection Hierarchy

```
DI Modules (apps/kzp/lib/di/modules/)
├── core/              # Core services (Dio, Logger, Storage)
├── kz_api/            # API clients
├── data/              # Repository implementations
├── domain/            # Use cases
└── features/          # Feature-specific dependencies
```

### Navigation Pattern

- Uses `auto_route` for type-safe navigation
- All routes defined in `lib/router/app_router.dart`
- Guards protect sensitive screens (auth, PIN)

## Detailed KZP Architecture

### HTTP Client Implementation

The project uses a custom `HttpClient` wrapper with:

- **Automatic Authorization**: Adds `Authorization: Bearer $token` to all requests
- **Token Refresh Queue**: Uses `QueuedInterceptorsWrapper` to queue requests during token refresh
- **Error Handling**: Custom interceptors for detailed logging and error reporting

Key features:
```dart
// Interceptors chain
Dio _createDio(String baseUrl, Talker talker) {
  final dio = Dio(...);
  
  // CookieManager must be first to save cookies
  dio.interceptors.insert(0, CookieManager(cookieJar));
  
  // TalkerDioLogger for HTTP logging
  dio.interceptors.add(TalkerDioLogger(...));
  
  // Detailed error logger
  dio.interceptors.add(DetailedErrorLoggerInterceptor());
}
```

### Configuration

Configuration is managed through environment variables (`--dart-define`):

| Variable | Default | Description |
|----------|---------|-------------|
| `BASE_URL` | `https://www.vivus.kz` | Main API endpoint |
| `QA_BASE_URL` | `http://10.77.56.10:5000` | QA environment |
| `USE_LOGGER` | `false` | Enable Talker logging |
| `SKIP_KYC` | `false` | Skip KYC for testing |
| `ENABLE_QA_SMS` | `false` | Enable QA SMS simulation |
| `APPMETRICA_API_KEY` | (see consts.dart) | AppMetrica key |
| `APPSFLYER_API_KEY` | (see consts.dart) | AppsFlyer dev key |
| `JUICYSCORE_ANDROID_API_KEY` | (see consts.dart) | Android JuicyScore key |
| `JUICYSCORE_IOS_API_KEY` | (see consts.dart) | iOS JuicyScore key |

### DI Module Structure

```
lib/di/modules/
├── core/              # Core services (Dio, HttpClient, Analytics, Logger)
│   ├── core_module.dart
│   └── juicyscore_module.dart
├── kz_api/            # API clients (LkApi, RegistrationApi)
│   └── kz_api_module.dart
├── data/              # Repository implementations
│   └── data_module.dart
├── domain/            # Use cases
│   └── domain_module.dart
└── features/          # Feature-specific Cubits
    ├── auth_module.dart
    ├── profile_module.dart
    ├── registration_module.dart
    └── splash_module.dart
```

### Registration Flow: 5 Stages

The registration process is split into 5 sequential steps:

| Stage | Cubit | Description |
|-------|-------|-------------|
| **1-3** | `RegistrationCubit` | Phone, IIN (tax ID), email, terms acceptance |
| **4** | `Stage4RegistrationCubit` | Verigram biometric verification + autocompletion |
| **5** | `Stage5RegistrationCubit` | Loan amount selection, repayment method choice |

**Special Features:**
- **Autoregistration**: Data from Verigram can auto-fill registration steps
- **Verigram with Interruption**: Handles cases where user leaves and returns to app during verification

### Key Use Cases

- **`LogoutUsecase`**: Clears all credentials (tokens + PIN) on logout
- **`DeviceInfoService`**: Gets device information for analytics
- **`RemoteConfigService`**: Manages Firebase Remote Config

### Document Handling

PDF documents are downloaded and opened externally:

```dart
// Supported document types:
// - 'loanRules' → Main loan rules PDF
// - 'specialLiteratureImplementationRules' → Consultation services rules
// - Custom contract IDs (e.g., 'contract_123')
```

Process:
1. Download PDF to `applicationDocumentsDirectory`
2. Open with default system viewer using `open_filex`

### Localization

Two languages supported:
- **Russian** (`ru-RU.json`) - fallback locale
- **Kazakh** (`kk-KZ.json`)

Translations are loaded from:
- Main app: `assets/translations/`
- Packages: `pin_lock`, `password_recovery_webview`, `force_update`

### Reference Data

- **Bank Directory**: `assets/data/bank.json` - List of Kazakh banks with BIC codes
- **Chatra**: `assets/chatra.html` - Chat support widget

### Special Implementation Details

#### Sanitization in LkApi

```dart
// Removes NUL (\0) characters that break backend lookup
String _sanitizeLkLoginUsername(String value) =>
    value.replaceAll('\x00', '').trim();
```

This is critical for login functionality.

#### Token Refresh Mechanism

When a request returns 401:
1. All subsequent requests are queued
2. Background token refresh occurs
3. Queued requests retry with new token
4. If refresh fails, all queued requests fail and storage is cleared

## Troubleshooting

### Common Issues

**1. Dependency resolution fails**

```bash
melos clean:all
melos bootstrap
```

**2. Code generation issues**

```bash
# Clean generated files
flutter pub run build_runner clean

# Re-generate code
flutter pub run build_runner build --delete-conflicting-outputs
```

**3. Gradle sync failed (Android)**

```bash
cd apps/kzp/android
./gradlew clean
cd ..
flutter pub get
```

**4. Pod install failed (iOS)**

```bash
cd apps/kzp/ios
pod cache clean --all
pod deintegrate
pod install --repo-update
cd ..
```

**5. FVM version mismatch**

```bash
# Check current Flutter version
fvm current

# Reinstall and use the correct version from .fvmrc
fvm install
fvm use
melos bootstrap
```

### Debug Tips

- Use Talker for runtime logging (floating bug icon in debug mode)
- Check `lib/firebase_options.dart` for Firebase configuration
- Verify `BASE_URL` dart-define is set correctly for your environment
- Review CI/CD logs for build failures and error messages

## Continuous Integration & Deployment

### CI Pipeline Stages (`.gitlab-ci.yml`)

1. **Build test Android**: Debug APK/AAB builds for all countries
2. **Build release Android**: Signed AAB/APK with proper keystore
3. **Build test iOS**: TestFlight IPA for all countries
4. **Build release iOS**: App Store IPA with production signing

### CI/CD Variables

Environment-specific variables are configured in GitLab CI:

- `BASE_URL`: API endpoint for each environment
- `APPMETRICA_API_KEY_*`: Analytics keys per country
- `APPSFLYER_KEY`: Marketing attribution key
- Keystore credentials for Android signing
- iOS certificates and provisioning profiles

### Running Pre-commit Checks

```bash
melos precommit
```

This runs: format check, static analysis, and tests.

## References

### Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Bloc Library Docs](https://bloclibrary.dev/)
- [AutoRoute Documentation](https://autoroute.vercel.app/)
- [Injectable Docs](https://jaided.gitbook.io/injectable/)
- [Melos Documentation](https://pub.dev/packages/melos)

### Project-Specific

- Root README: `README.md`
- Kazakhstan App: `apps/kzp/README.md`
- Mexico App: `apps/mxp/README.md`
- Russia App: `apps/rfp/README.md`

### Configuration Files

- `analysis_options.yaml`: Static analysis rules
- `pubspec.yaml`: Workspace configuration and Melos scripts
- `.gitlab-ci.yml`: CI/CD pipeline definition
- `.fvmrc`: Flutter version specification

## Notes for AI Assistant

- Always run `melos bootstrap` after adding/removing packages
- Use FVM for Flutter commands: `fvm flutter [command]`
- Generate code before building: `melos generate`
- Follow Clean Architecture separation strictly
- Test across all platforms before merging
- Update documentation when changing architecture or workflows

### KZP-Specific Notes

1. **HTTP Client**: Never modify the token refresh queue mechanism without understanding the full impact
2. **LkApi Sanitization**: The `_sanitizeLkLoginUsername()` function is critical - don't remove it
3. **Registration Flow**: Always test all 5 stages - each stage has different requirements
4. **Configuration**: Use `--dart-define` for environment-specific values, never hardcode secrets
5. **Code Generation**: Run `melos generate` after any model or DI changes
6. **Testing**: Enable `USE_LOGGER=true` to see detailed logs in Talker UI
7. **QA Environment**: Use `ENABLE_QA_SMS=true` and `SKIP_KYC=true` for faster QA testing
end of file