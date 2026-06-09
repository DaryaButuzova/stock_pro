# Stock Pro

Flutter-приложение для учёта продаж и складских остатков. Проект организован как **монорепозиторий** (Dart Workspaces + Melos): основное приложение живёт в `apps/`, переиспользуемые фичи — в `packages/`.

Документ предназначен для разработчиков и coding agents: описывает архитектуру, соглашения и практические шаги при доработке проекта.

---

## Содержание

- [Технологии](#технологии)
- [Структура репозитория](#структура-репозитория)
- [Архитектура](#архитектура)
- [Пакеты](#пакеты)
- [Приложение stock_pro](#приложение-stock_pro)
- [Навигация и зоны](#навигация-и-зоны)
- [Dependency Injection](#dependency-injection)
- [Supabase](#supabase)
- [UI Kit](#ui-kit)
- [Генерация кода](#генерация-кода)
- [Запуск и разработка](#запуск-и-разработка)
- [Добавление новой фичи](#добавление-новой-фичи)
- [Соглашения и ограничения](#соглашения-и-ограничения)
- [Планируемые модули](#планируемые-модули)

---

## Технологии

| Область | Пакет / инструмент |
|---------|-------------------|
| SDK | Dart ^3.11.5, Flutter (FVM: `stable`) |
| Монорепо | Dart Workspaces, Melos ^7.7 |
| State management | `flutter_bloc` + `equatable` |
| DI | `get_it` + `injectable` (MicroPackage) |
| Навигация | `auto_route` |
| Backend | Supabase (`supabase_flutter`) |
| Сеть (зарезервировано) | `dio` + `retrofit` |
| Локальная БД (зарезервировано) | `drift` |
| Линтинг | `very_good_analysis` |

---

## Структура репозитория

```
stock_pro/
├── pubspec.yaml                 # workspace root + melos scripts
├── apps/
│   └── stock_pro/               # основное Flutter-приложение
│       ├── lib/
│       │   ├── main.dart
│       │   ├── di/              # корневой DI (@InjectableInit)
│       │   ├── navigation/      # AppRouter (auto_route)
│       │   ├── navigation/      # роутер + page-обёртки + пути
│       │   │   ├── app_router.dart
│       │   │   ├── pages/       # связывают пакеты с навигацией
│       │   │   └── routes/      # AppRoutes (константы путей)
│       │   ├── features/        # app-специфичная композиция (inventory, sales…)
│       │   └── ui/              # ui_kit_showcase (dev)
│       └── pubspec.yaml
└── packages/
    ├── ui_kit/                  # дизайн-система
    ├── supabase/                # клиент Supabase + SQL-миграции
    ├── authorization/           # вход
    ├── registration/            # регистрация
    └── profile/                 # профиль (авторизованная зона)
```

**Принцип:** бизнес-логика и UI фичи — в `packages/<feature>/`. Приложение только собирает фичи: DI, роутинг, callbacks навигации.

---

## Архитектура

### Слои внутри feature-пакета

Каждая фича следует одному шаблону:

```
packages/<feature>/
├── lib/
│   ├── <feature>_feature.dart       # публичный API (exports)
│   └── src/
│       ├── di/
│       │   ├── injection.dart       # @InjectableInit.microPackage()
│       │   └── injection.module.dart  # сгенерировано
│       ├── domain/
│       │   ├── models/              # сущности, DTO
│       │   ├── repositories/        # абстрактные контракты
│       │   ├── <feature>_cubit.dart
│       │   └── <feature>_state.dart
│       ├── data/
│       │   └── repositories/        # Supabase*Repository (реализации)
│       └── presentation/
│           └── <feature>_screen.dart
```

| Слой | Ответственность |
|------|-----------------|
| **presentation** | UI, формы, `BlocProvider`, **callbacks** для навигации |
| **domain** | Cubit, state, модели, **абстрактные** репозитории |
| **data** | Конкретные реализации репозиториев (Supabase, в будущем — API, local) |
| **di** | Регистрация зависимостей через injectable micropackage |

### Ключевые правила

1. **Cubit не зависит от Supabase напрямую** — только от `*Repository` (абстракция).
2. **Пакеты фич не знают маршруты приложения** — навигация через callbacks (`onAuthSuccess`, `onNavigateToLogin`, …).
3. **Пакет `supabase`** — только инфраструктура: `SupabaseService`, конфиг, SQL-миграции. Бизнес-логика пользователя — в `profile`.
4. **Смена data source** (локальное хранилище, REST API): меняется только `data/repositories/`, domain и presentation остаются без изменений.
5. **Роуты auto_route** объявляются в `apps/stock_pro/lib/navigation/` (генератор не сканирует пакеты). Page-обёртки живут в `navigation/pages/`, пути — в `navigation/routes/app_routes.dart`.

### Зависимости между пакетами

```
apps/stock_pro
    ├── ui_kit
    ├── supabase_feature
    ├── authorization_feature
    ├── registration_feature  → profile_feature, supabase_feature
    └── profile_feature         → supabase_feature

supabase_feature                # без зависимостей на другие фичи
authorization_feature           → supabase_feature, ui_kit
```

`registration` зависит от `profile` на уровне **cubit**: после `signUp` cubit вызывает `ProfileRepository.createProfile()`. Data-слой registration знает только про auth.

---

## Пакеты

### `packages/ui_kit`

Общая дизайн-система:

- `AppColors` — палитра (primary: лавандовый `#7E57C2`)
- `AppTextStyles` / `appTextTheme` — типографика Material 3
- `AppButton` — кнопка с вариантами (`primary`, `secondary`, `outlined`) и состоянием loading

Импорт: `package:ui_kit/ui_kit.dart`

### `packages/supabase`

Инфраструктурный слой Supabase:

- `SupabaseConfig` — url + publishable key (через named DI: `supabaseUrl`, `supabaseKey`)
- `SupabaseService` — инициализация клиента (`@PostConstruct(preResolve: true)`)
- `migrations/` — SQL-скрипты (триггер `handle_new_user` для создания строки в `users` при signUp без сессии)

**Не содержит** бизнес-логику пользователя.

### `packages/authorization`

Вход в систему.

| Компонент | Описание |
|-----------|----------|
| `AuthRepository` | Контракт: `signIn`, `signOut` |
| `SupabaseAuthRepository` | Реализация через `SupabaseService.client.auth` |
| `AuthorizationCubit` | State machine: Initial → Loading → Success / Failure |
| `AuthorizationScreen` | Форма email/пароль; callbacks: `onAuthSuccess`, `onNavigateToRegistration` |

### `packages/registration`

Регистрация нового пользователя.

| Компонент | Описание |
|-----------|----------|
| `RegistrationData` | DTO формы: ФИО, email, password, `UserRole` |
| `UserRole` | `staff` / `admin` |
| `RegistrationRepository` | Контракт: `register(RegistrationData)` → `RegistrationResult` (только auth sign-up) |
| `SupabaseRegistrationRepository` | `auth.signUp` + metadata (`creds`, `role`) |
| `RegistrationCubit` | Оркестрация: sign-up → при `hasSession` вызывает `ProfileRepository.createProfile()` |
| `RegistrationScreen` | Форма; callbacks: `onRegistrationSuccess({hasSession})`, `onNavigateToLogin` |

Поле `creds` в БД формируется как `"Фамилия Имя Отчество"`.

### `packages/profile`

Профиль авторизованного пользователя.

| Компонент | Описание |
|-----------|----------|
| `UserProfile` | Модель: id, creds, email, role, createdAt |
| `ProfileRepository` | Контракт: `getCurrentUserId`, `getProfile`, `createProfile`, `signOut` |
| `SupabaseProfileRepository` | Чтение/запись таблицы `users`, signOut через auth |
| `ProfileCubit` | Загрузка профиля, logout |
| `ProfileScreen` | Отображение ФИО, email, роли; callback: `onUnauthenticated` |

---

## Приложение stock_pro

Точка входа: `apps/stock_pro/lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const StockProApp());
}
```

`StockProApp` — `MaterialApp.router` с темой из `ui_kit` и `AppRouter`.

### Navigation pages (`lib/navigation/pages/`)

Приложение не дублирует UI — **navigation layer** связывает экраны пакетов с `auto_route`:

```dart
// navigation/pages/authorization_page.dart
AuthorizationScreen(
  onAuthSuccess: context.router.replaceWithProfile,
  onNavigateToRegistration: context.router.pushRegistration,
)
```

Пути — в `navigation/routes/app_routes.dart`. Навигация — через extension `AppRouterNavigation` (`navigation/extensions/app_router_extension.dart`): `replaceWithProfile()`, `pushRegistration()`, `replaceWithAuthorization()` и т.д.

`lib/features/` в app — для app-специфичной композиции (например, shell authorized zone), **не** для пустых route-обёрток.

---

## Навигация и зоны

Роутер: `apps/stock_pro/lib/navigation/app_router.dart`

| Зона | Путь | Route-обёртка | Экран пакета |
|------|------|---------------|--------------|
| Неавторизованная | `/authorization` (initial) | `AuthorizationPage` | `AuthorizationScreen` |
| Неавторизованная | `/registration` | `RegistrationPage` | `RegistrationScreen` |
| Авторизованная | `/profile` | `ProfilePage` | `ProfileScreen` |
| Dev | `/showcase` | `UIKitShowcase` | UI Kit демо |

### Потоки

```
/authorization ──успех──► /profile ──выход──► /authorization
/registration ──сессия есть──► /profile
/registration ──нужно подтвердить email──► /authorization (+ snackbar)
```

Route guards пока **не реализованы** — защита `/profile` опирается на проверку сессии в `ProfileCubit`.

---

## Dependency Injection

### Корневая конфигурация

Файл: `apps/stock_pro/lib/di/injection.dart`

1. **Pre-dependencies** — named `String` для Supabase (из `--dart-define`):
   - `supabaseUrlName` → `SUPABASE_URL`
   - `supabaseKeyName` → `SUPABASE_KEY`

2. **@InjectableInit** с micropackages в порядке инициализации:

```
SupabaseFeaturePackageModule
  → ProfileFeaturePackageModule
  → AuthorizationFeaturePackageModule
  → RegistrationFeaturePackageModule
```

Порядок важен: `profile` нужен `SupabaseService`; `registration` нужен `ProfileRepository`.

### Micropackage в фиче

```dart
// packages/<feature>/lib/src/di/injection.dart
@InjectableInit.microPackage()
void init<Feature>MicroPackage() {}
```

После изменений `@injectable` / `@Injectable(as: ...)` — запустить `build_runner` в пакете.

### Регистрация реализации репозитория

```dart
@Injectable(as: ProfileRepository)
class SupabaseProfileRepository implements ProfileRepository { ... }
```

Для смены data source — заменить реализацию или зарегистрировать другую через `@Injectable(as: ...)`.

---

## Supabase

### Конфигурация

Передаётся при запуске:

```bash
flutter run \
  --dart-define=SUPABASE_URL=<url> \
  --dart-define=SUPABASE_KEY=<publishable_key>
```

В VS Code/Cursor: конфигурация `stock_pro` в `.vscode/launch.json`.

### Таблица `public.users`

| Колонка | Тип | Описание |
|---------|-----|----------|
| `id` | uuid (PK) | Совпадает с `auth.users.id` |
| `created_at` | timestamptz | Автоматически |
| `creds` | varchar | ФИО: `"Фамилия Имя Отчество"` |
| `email` | varchar | Email |
| `password` | varchar | Дублируется из формы (legacy; auth-хеш в `auth.users`) |
| `role` | varchar | `staff` или `admin` |

### Регистрация пользователя

1. `auth.signUp` с metadata: `{ creds, role }`
2. Если есть **сессия** → `RegistrationCubit` вызывает `ProfileRepository.createProfile()` (прямой insert)
3. Если сессии **нет** (email confirmation) → строка создаётся триггером `on_auth_user_created` из metadata

SQL: `packages/supabase/migrations/001_create_users.sql`

### RLS

Для работы клиента нужны политики (пример):

```sql
-- insert своей строки
create policy "Users can insert own profile"
  on public.users for insert to authenticated
  with check (auth.uid() = id);

-- чтение своей строки
create policy "Users can read own profile"
  on public.users for select to authenticated
  using (auth.uid() = id);
```

---

## UI Kit

Primary color: `#7E57C2` (лавандовый). Тема подключается в `main.dart`:

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  scaffoldBackgroundColor: AppColors.background,
  textTheme: appTextTheme,
)
```

Демо всех компонентов: маршрут `/showcase` → `UIKitShowcase`.

---

## Генерация кода

Используется `build_runner` для:

- **injectable** → `*.config.dart`, `injection.module.dart`
- **auto_route** → `app_router.gr.dart` (только в app)

### Порядок после изменений DI / роутов

```bash
# из корня
dart pub get

# supabase (если менялся injectable)
cd packages/supabase && dart run build_runner build

# profile, authorization, registration — по необходимости
cd packages/profile && dart run build_runner build
cd packages/authorization && dart run build_runner build
cd packages/registration && dart run build_runner build

# приложение (роуты + корневой DI)
cd apps/stock_pro && dart run build_runner build
```

Или из корня (все пакеты):

```bash
dart run melos run generate
```

> **Примечание:** часть melos-скриптов в корневом `pubspec.yaml` ещё ссылается на устаревший путь `apps/kzp`. Актуальное приложение: `apps/stock_pro`.

---

## Запуск и разработка

### Требования

- Flutter SDK (рекомендуется FVM: `fvm use stable`)
- Dart ^3.11.5
- Melos (глобально или через `dart pub global activate melos`)

### Первичная настройка

```bash
dart pub get
dart run melos bootstrap   # или: melos bootstrap
cd apps/stock_pro && dart run build_runner build
```

### Запуск

```bash
cd apps/stock_pro
flutter run \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_KEY=...
```

### Анализ и форматирование

```bash
dart run melos run analyze
dart run melos run format
```

---

## Добавление новой фичи

Чеклист для `packages/inventory` (пример):

### 1. Создать пакет

```
packages/inventory/
├── pubspec.yaml          # resolution: workspace
└── lib/
    ├── inventory_feature.dart
    └── src/
        ├── di/injection.dart
        ├── domain/
        │   ├── models/
        │   ├── repositories/inventory_repository.dart
        │   └── inventory_cubit.dart
        ├── data/repositories/supabase_inventory_repository.dart
        └── presentation/inventory_screen.dart
```

### 2. Зависимости в `pubspec.yaml`

- `flutter_bloc`, `injectable`, `get_it`, `equatable`
- `ui_kit` — для UI
- `supabase_feature` — только в **data**-слое (не в cubit)
- при необходимости — другие feature-пакеты

### 3. Domain

```dart
abstract class InventoryRepository {
  Future<List<InventoryItem>> getItems();
}

@injectable
class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit(this._repository);
  final InventoryRepository _repository;
}
```

### 4. Data

```dart
@Injectable(as: InventoryRepository)
class SupabaseInventoryRepository implements InventoryRepository { ... }
```

### 5. Presentation

Экран принимает **callbacks**, не знает про `auto_route`:

```dart
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({required this.onItemSelected, super.key});
  final void Function(String itemId) onItemSelected;
}
```

### 6. DI micropackage

```dart
@InjectableInit.microPackage()
void initInventoryMicroPackage() {}
```

`dart run build_runner build` в пакете.

### 7. Подключить в приложение

1. Добавить пакет в workspace (`pubspec.yaml` root) и `apps/stock_pro/pubspec.yaml`
2. `ExternalModule(InventoryFeaturePackageModule)` в `apps/stock_pro/lib/di/injection.dart`
3. Navigation page в `apps/stock_pro/lib/navigation/pages/inventory_page.dart`
4. Маршрут в `app_router.dart` → `build_runner build` в app
5. `dart pub get`

### 8. Порядок micropackages в app DI

Зависимые модули — **после** тех, от кого они зависят. `supabase` всегда первый.

---

## Соглашения и ограничения

### Делать

- Следовать структуре `domain` / `data` / `presentation` в каждой фиче
- Навигацию выносить в app через callbacks
- Экспортировать публичный API через `<feature>_feature.dart`
- Использовать `very_good_analysis`; запускать `flutter analyze` перед коммитом
- Генерировать DI после изменения `@injectable` аннотаций

### Не делать

- Не импортировать `SupabaseService` в cubit или presentation
- Не хардкодить пути (`/profile`, `/authorization`) внутри feature-пакетов
- Не добавлять бизнес-логику пользователя в `packages/supabase`
- Не коммитить секреты (ключи Supabase — только через `--dart-define` или CI secrets)
- Не ставить `@RoutePage()` на экраны внутри packages (только в app-обёртках)

### Именование

| Сущность | Паттерн |
|----------|---------|
| Пакет | `<name>_feature` (pubspec `name`) |
| Репозиторий (контракт) | `<Feature>Repository` |
| Реализация Supabase | `Supabase<Feature>Repository` |
| Micropackage module | `<Feature>FeaturePackageModule` |
| Navigation page в app | `<Name>Page` в `navigation/pages/` с `@RoutePage()` |

---

## Планируемые модули

В `apps/stock_pro/lib/features/` есть заготовки (пока пустые):

- `inventory/` — учёт складских остатков
- `sales/` — продажи

В `pubspec.yaml` приложения уже подключены `drift`, `dio`, `retrofit` — для будущих data-слоёв.

---

## Быстрая справка для coding agent

**Задача: изменить экран входа**  
→ `packages/authorization/lib/src/presentation/authorization_screen.dart`  
→ навигация: `apps/stock_pro/lib/navigation/pages/authorization_page.dart`

**Задача: изменить логику регистрации**  
→ cubit: `packages/registration/lib/src/domain/registration_cubit.dart`  
→ data: `packages/registration/lib/src/data/repositories/supabase_registration_repository.dart`

**Задача: изменить отображение профиля**  
→ `packages/profile/lib/src/presentation/profile_screen.dart`  
→ данные: `packages/profile/lib/src/data/repositories/supabase_profile_repository.dart`

**Задача: добавить маршрут**  
→ `app_router.dart` + page в `lib/navigation/pages/`  
→ `dart run build_runner build` в `apps/stock_pro`

**Задача: добавить DI**  
→ `@injectable` в пакете → `build_runner` в пакете  
→ при новом micropackage: `ExternalModule` в `apps/stock_pro/lib/di/injection.dart` → `build_runner` в app

**Задача: SQL / миграции**  
→ `packages/supabase/migrations/`

---

## Ссылки

- [Melos](https://melos.invertase.dev/)
- [injectable](https://pub.dev/packages/injectable)
- [auto_route](https://auto-route.dev/)
- [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- [Supabase Flutter](https://supabase.com/docs/reference/dart/introduction)
