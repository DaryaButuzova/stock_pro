"# Stock Pro — Project Guide

This guide provides a comprehensive overview of the **Stock Pro** project, including its architecture, technology stack, and development workflows.

## 1. Project Overview

**Stock Pro** is a Flutter mobile application designed for sales and inventory tracking. The project is structured as a **monorepo** using Dart workspaces and Melos to manage shared packages and the main application.

### Key Technologies
- **Framework**: Flutter (Dart ^3.11.5)
- **Monorepo Management**: Dart Workspaces + Melos (^7.7.0)
- **State Management**: flutter_bloc + equatable
- **Dependency Injection**: get_it + injectable
- **Routing**: auto_route
- **Networking**: dio + retrofit
- **Local Storage**: drift (SQLite ORM)

## 2. Getting Started

### Prerequisites
- Flutter SDK (^3.11.5)
- Dart SDK (^3.11.5)
- Melos (^7.7.0) (Global or workspace-local)

### Installation
1.  **Root Setup**: Run `dart pub get` in the root directory to install Melos and workspace dependencies.
2.  **Package Setup**: Run `dart run melos run get` to execute `flutter pub get` across all packages (`apps/`, `packages/`).

### Running the App
```bash
cd apps/stock_pro
flutter run
```

## 3. Project Structure

The project follows a monorepo structure with distinct `apps/` and `packages/` directories.

```text
stock_pro/
├── pubspec.yaml                # Root workspace config + Melos scripts
├── apps/
│   └── stock_pro/              # Main Flutter Application
│       ├── lib/
│       │   ├── main.dart       # Entry point
│       │   ├── di/             # DI configuration (GetIt + Injectible)
│       │   ├── navigation/     # Routing (auto_route)
│       │   ├── features/       # Feature modules (placeholders)
│       │   └── core/           # Core utilities
│       └── pubspec.yaml
└── packages/
    ├── ui_kit/                 # Shared UI components (Colors, Widgets, Styles)
    ├── registration/           # Registration feature package
    └── authorization/          # Authorization feature package
```

### Key Directories
- **`apps/stock_pro/lib/`**: Main application logic.
- **`packages/ui_kit/lib/`**: Shared UI components (e.g., `AppButton`, `AppColors`).
- **`packages/registration/` & `packages/authorization/`**: Feature-specific logic and UI, designed as independent packages.

## 4. Development Workflow

### Coding Standards
- **Linting**: The project uses `very_good_analysis`.
- **Formatting**: `dart format` is enforced.

### Scripts (Melos)
Run these from the **root** directory:
- **Analyze**: `dart run melos run analyze`
- **Format**: `dart run melos run format`
- **Get Deps**: `dart run melos run get`

### Code Generation
Code generation (for DI, Routing, etc.) is handled per-package. Run from the specific package directory (e.g., `apps/stock_pro`):
```bash
cd apps/stock_pro
dart run build_runner build --delete-conflicting-outputs
```

## 5. Key Concepts

### Dependency Injection
- **Tool**: `get_it` + `injectable`
- **Setup**: Configured in `apps/stock_pro/lib/di/injection.dart`.
- **Modules**: Feature packages use `MicroPackageModule` to register their own dependencies.

### Routing
- **Tool**: `auto_route`
- **Setup**: Defined in `apps/stock_pro/lib/navigation/app_router.dart`.
- **Generated**: `app_router.gr.dart` contains the generated route configuration.

### UI Kit
- **Theme**: Lavender primary color (`#7E57C2`) with warm accents.
- **Typography**: Material 3 typography via `appTextTheme`.
- **Components**: Reusable widgets like `AppButton` are exported from `ui_kit`.

## 6. Common Tasks

### Adding a New Feature
1.  **Create Package**: Add a new folder in `packages/` (e.g., `packages/sales/`).
2.  **Define Module**: Create a `SalesModule` extending `MicroPackageModule` in the new package.
3.  **Register DI**: Add the module to `apps/stock_pro/lib/di/injection.dart` using `externalPackageModulesBefore` or similar.
4.  **Add Route**: Define the route in `app_router.dart` and run code generation.

### Adding a New UI Component
1.  Create the widget in `packages/ui_kit/lib/src/widgets/`.
2.  Export it from `packages/ui_kit/lib/ui_kit.dart`.
3.  Use in the app by importing `package:ui_kit/ui_kit.dart`.

## 7. Troubleshooting

### Code Generation Errors
- Ensure all dependencies are up-to-date (`flutter pub get`).
- Check for syntax errors in `@injectable` or `@RoutePage` annotations.
- Run `build_runner` with `--delete-conflicting-outputs` to clear old generated files.

### Dependency Conflicts
- If `pub get` fails, check for version mismatches between packages.
- Use `dart pub deps` to inspect the dependency tree.
- Ensure all packages use `resolution: workspace` (if applicable) or are correctly referenced in the root `pubspec.yaml`.

## 8. References

- [Melos Documentation](https://melos.invertase.dev/)
- [auto_route Documentation](https://auto-route.dev/)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [Injectable Documentation](https://pub.dev/packages/injectable)
- [flutter_bloc Documentation](https://pub.dev/packages/flutter_bloc)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Retrofit Documentation](https://pub.dev/packages/retrofit)
- [very_good_analysis Documentation](https://pub.dev/packages/very_good_analysis)