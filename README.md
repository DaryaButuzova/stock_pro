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
- [Роли staff / admin](#роли-staff--admin)
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
| Backend | Supabase (`supabase_flutter`) + Realtime |
| Локальная БД | `drift` + `sqlite3_flutter_libs` (пакет `local_reference`) |
| Сеть (зарезервировано) | `dio` + `retrofit` |
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
│       │   ├── navigation/      # роутер + page-обёртки + пути
│       │   │   ├── app_router.dart
│       │   │   ├── pages/       # связывают пакеты с навигацией
│       │   │   ├── routes/      # AppRoutes (константы путей)
│       │   │   └── extensions/  # AppRouterNavigation
│       │   └── ui/              # ui_kit_showcase (dev)
│       └── pubspec.yaml
└── packages/
    ├── ui_kit/                  # дизайн-система
    ├── supabase/                # клиент Supabase + SQL-миграции
    ├── local_reference/         # локальные справочники (Drift) + Realtime sync
    ├── authorization/           # вход
    ├── registration/            # регистрация
    ├── profile/                 # профиль, роли, UserSession
    ├── sales/                   # продажи (касса staff / история admin)
    └── stock/                   # склад (просмотр staff / управление admin)
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
| **data** | Конкретные реализации репозиториев (Supabase, Drift, в будущем — API) |
| **di** | Регистрация зависимостей через injectable micropackage |

### Ключевые правила

1. **Cubit не зависит от Supabase напрямую** — только от `*Repository` (абстракция).
2. **Пакеты фич не знают маршруты приложения** — навигация через callbacks (`onAuthSuccess`, `onNavigateToLogin`, …).
3. **Пакет `supabase`** — только инфраструктура: `SupabaseService`, конфиг, SQL-миграции. Бизнес-логика пользователя — в feature-пакетах.
4. **Пакет `local_reference`** — локальные справочники (Drift): чтение из SQLite, синк и Realtime из Supabase. Не смешивать с бизнес-фичами вроде `stock`.
5. **Смена data source** (локальное хранилище, REST API): меняется только `data/repositories/`, domain и presentation остаются без изменений.
6. **Роуты auto_route** объявляются в `apps/stock_pro/lib/navigation/` (генератор не сканирует пакеты). Page-обёртки живут в `navigation/pages/`, пути — в `navigation/routes/app_routes.dart`.

### Зависимости между пакетами

```
apps/stock_pro
    ├── ui_kit
    ├── supabase_feature
    ├── local_reference_feature
    ├── authorization_feature
    ├── registration_feature  → profile_feature, supabase_feature
    ├── profile_feature         → supabase_feature, ui_kit
    ├── sales_feature           → local_reference_feature, stock_feature, supabase_feature, ui_kit
    └── stock_feature           → local_reference_feature, supabase_feature, ui_kit

local_reference_feature         → supabase_feature
sales_feature                   → local_reference_feature, stock_feature, supabase_feature, ui_kit
stock_feature                   → local_reference_feature, supabase_feature, ui_kit
supabase_feature                # без зависимостей на другие фичи
authorization_feature           → supabase_feature, ui_kit
```

`registration` зависит от `profile` на уровне **cubit**: после `signUp` cubit вызывает `ProfileRepository.createProfile()`. Data-слой registration знает только про auth.

`stock` зависит от `local_reference` для чтения названий товаров из локального кэша `goods`.

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
| `UserRole` | `staff` / `admin` (определён в `profile`, реэкспортируется из `registration`) |
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
| `UserRole` | `staff` / `admin`; парсинг из `users.role` |
| `UserSessionCubit` | Загрузка профиля для авторизованной зоны (роль для `RoleGate`) |
| `RoleGate` | Виджет: разный UI для `staff` и `admin` на одной вкладке |
| `ProfileCubit` | Загрузка профиля на вкладке «Профиль», logout |
| `ProfileScreen` | Отображение ФИО, email, роли; callback: `onUnauthenticated` |

### `packages/sales`

Продажи и корзина.

| Компонент | Описание |
|-----------|----------|
| `Sale`, `SaleStatus` | Документ `public.sales` (`draft` / `completed` / `cancelled`) |
| `GoodsInSale` | Строка корзины `public.goods_in_sales` |
| `SalesRepository` | Draft-корзина, `completeSale`, история для admin |
| `SalesCubit` | Касса: корзина, оформление, ленивое создание draft |
| `SalesScreen` | UI кассы для **staff** |
| `AdminSalesHistoryCubit` | Список завершённых продаж для **admin** |
| `AdminSalesHistoryScreen` | История продаж: список + детали по тапу |

Импорт: `package:sales_feature/sales_feature.dart`

**Корзина (staff):** draft создаётся только при добавлении первого товара; пустые draft удаляются. После `complete_sale` новый пустой draft не создаётся.

### `packages/local_reference`

Локальное хранилище справочников (Drift/SQLite) с синхронизацией из Supabase.

| Компонент | Описание |
|-----------|----------|
| `AppDatabase` | Drift-база `reference_cache.sqlite` |
| `GoodsTable` | Локальная копия `public.goods` |
| `GoodsRepository` | Чтение из локальной БД (`getById`, `getAll`) |
| `GoodsSyncRepository` | Полный синк и инкрементальные изменения из Realtime |
| `ReferenceSyncService` | Оркестратор синка; параллельные вызовы объединяются в один |
| `GoodsRealtimeService` | Подписка на `public.goods` → обновление Drift |

Импорт: `package:local_reference_feature/local_reference_feature.dart`

### `packages/stock`

Складской учёт (вкладка «Склад»).

| Компонент | Описание |
|-----------|----------|
| `StockItem` | Модель строки `public.stock` (PK: `goods_id`) |
| `StockRepository` | `getStockItems`, `replenishStock`, `writeOffStock` (RPC, admin) |
| `SupabaseStockRepository` | Чтение и RPC `replenish_stock` / `write_off_stock` |
| `StockCubit` | Загрузка склада + Realtime; методы пополнения/списания |
| `StockScreen` | Список позиций (только чтение) — **staff** |
| `AdminStockScreen` | То же + кнопки «Пополнить» / «Списать» — **admin** |

Импорт: `package:stock_feature/stock_feature.dart`

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
  onAuthSuccess: context.router.replaceWithAuthorized,
  onNavigateToRegistration: context.router.pushRegistration,
)
```

Пути — в `navigation/routes/app_routes.dart`. Навигация — через extension `AppRouterNavigation` (`navigation/extensions/app_router_extension.dart`): `replaceWithAuthorized()`, `replaceWithStock()`, `replaceWithProfile()`, `pushRegistration()`, `replaceWithAuthorization()` и т.д.

`SalesPage` и `StockPage` используют `RoleGate` из `profile` для выбора экрана по роли.

---

## Навигация и зоны

Роутер: `apps/stock_pro/lib/navigation/app_router.dart`

| Зона | Путь | Route-обёртка | Экран |
|------|------|---------------|-------|
| Неавторизованная | `/authorization` (initial) | `AuthorizationPage` | `AuthorizationScreen` |
| Неавторизованная | `/registration` | `RegistrationPage` | `RegistrationScreen` |
| Авторизованная | `/authorized` | `AuthorizedShellPage` | shell с `AutoTabsScaffold` |
| Авторизованная | `/authorized/sales` | `SalesPage` | `SalesScreen` (staff) / `AdminSalesHistoryScreen` (admin) |
| Авторизованная | `/authorized/stock` | `StockPage` | `StockScreen` (staff) / `AdminStockScreen` (admin) |
| Авторизованная | `/authorized/profile` | `ProfilePage` | `ProfileScreen` (initial tab) |
| Dev | `/showcase` | `UIKitShowcase` | UI Kit демо |

### Вкладки авторизованной зоны

`AuthorizedShellPage` — `AutoTabsScaffold` с нижней навигацией (`NavigationBar`):

1. **Продажи** — касса (staff) или история продаж (admin)
2. **Склад** — просмотр (staff) или пополнение/списание (admin)
3. **Профиль** — `ProfileScreen` (**стартовая вкладка** после входа)

`AuthorizedShellPage` предоставляет `UserSessionCubit` всем вкладкам и запускает `GoodsRealtimeService` (подписка на `goods`).

---

## Роли staff / admin

Роль хранится в `public.users.role` (`staff` | `admin`), задаётся при регистрации.

| Вкладка | staff | admin |
|---------|-------|-------|
| Продажи | Касса: корзина, оформление | История завершённых продаж (read-only) |
| Склад | Только просмотр остатков | Пополнение и списание через RPC |
| Профиль | Свой профиль, выход | Свой профиль, выход |

**В приложении:** `UserSessionCubit` (в shell) + `RoleGate` в `SalesPage` / `StockPage`.

**В Supabase:** helper-функции `is_admin()`, `is_staff()`; RLS и RPC ограничивают мутации. Прямой `UPDATE stock` отозван — только `replenish_stock` / `write_off_stock`. Черновики корзины (`draft`) создаёт только `staff`. `complete_sale` не ограничен для admin (нет UI корзины; RPC требует свой draft с товарами).

### Потоки

```
/authorization ──успех──► /authorized (вкладка «Профиль»)
/registration ──сессия есть──► /authorized
/registration ──нужно подтвердить email──► /authorization (+ snackbar)
/authorized/profile ──выход──► /authorization
```

Route guards пока **не реализованы** — защита авторизованной зоны опирается на проверку сессии в `ProfileCubit`.

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
  → LocalReferenceFeaturePackageModule
  → ProfileFeaturePackageModule
  → AuthorizationFeaturePackageModule
  → RegistrationFeaturePackageModule
  → SalesFeaturePackageModule
  → StockFeaturePackageModule
```

Порядок важен: `local_reference` нужен `SupabaseService`; `registration` нужен `ProfileRepository`; `sales` нужен `GoodsRepository`, `StockRepository`, `ReferenceSyncService`; `stock` нужен `GoodsRepository` и `ReferenceSyncService`.

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

### Таблица `public.goods` (справочник товаров)

| Колонка | Тип | Описание |
|---------|-----|----------|
| `id` | uuid (PK) | Идентификатор товара |
| `created_at` | timestamptz | Дата создания |
| `name` | varchar | Название |
| `description` | varchar | Описание |
| `cost` | float4 | Себестоимость / цена |
| `category` | varchar | Категория |

Локальная копия — в Drift (`packages/local_reference`). SQL: `003_create_goods.sql`

### Таблица `public.stock` (складские остатки)

| Колонка | Тип | Описание |
|---------|-----|----------|
| `goods_id` | uuid (PK) | Ссылка на товар |
| `created_at` | timestamptz | Дата создания |
| `goods_addr` | varchar | Адрес / ячейка на складе |
| `count` | int4 | Текущее количество |
| `min_count` | int4 | Минимальный порог (алерт «Мало») |

SQL: `002_create_stock.sql`. Прямые `INSERT`/`UPDATE`/`DELETE` на `stock` отозваны в `008` — изменения только через RPC.

### Таблицы продаж

**`public.sales`**

| Колонка | Описание |
|---------|----------|
| `id` | uuid (PK) |
| `user_id` | Продавец (FK → `users`) |
| `status` | `draft` \| `completed` \| `cancelled` |
| `sum`, `payment_method` | Заполняются при `complete_sale` |
| `completed_at` | Время оформления |

Один активный `draft` на пользователя (unique index). SQL: `005_create_sales.sql`

**`public.goods_in_sales`** — позиции корзины/продажи. SQL: `006_create_goods_in_sales.sql`

**`public.stock_movement`** — журнал движений (`sale_out`, `replenishment_in`, `write_off`). SQL: `007_create_stock_movement.sql`

### RPC (PostgreSQL)

| Функция | Кто | Назначение |
|---------|-----|------------|
| `complete_sale(sale_id, payment_method)` | staff (свой draft) | Оформление продажи, списание со склада |
| `replenish_stock(goods_id, count, comment?)` | admin | Пополнение склада |
| `write_off_stock(goods_id, count, comment?)` | admin | Списание со склада |
| `create_goods(name, description?, cost?, category?)` | admin | Создание товара + пустая позиция на складе |
| `update_stock_meta(goods_id, goods_addr, min_count)` | admin | Адрес ячейки и минимальный остаток |
| `create_stock_position(goods_id, goods_addr, min_count)` | admin | Позиция склада для существующего товара |
| `delete_stock_position(goods_id)` | admin | Удаление позиции при нулевом остатке |
| `is_admin()` / `is_staff()` | — | Проверка роли в RLS и RPC |

### Миграции (порядок применения)

| Файл | Содержание |
|------|------------|
| `001_create_users.sql` | Триггер `handle_new_user` |
| `002_create_stock.sql` | RLS на `stock` (чтение) |
| `003_create_goods.sql` | RLS на `goods` |
| `004_enable_realtime.sql` | Realtime: `goods`, `stock`, `sales`, … |
| `005_create_sales.sql` | Таблица `sales`, RLS |
| `006_create_goods_in_sales.sql` | Таблица `goods_in_sales`, RLS |
| `007_create_stock_movement.sql` | `stock_movement`, `complete_sale` |
| `008_admin_stock_rpcs.sql` | `is_admin`, пополнение/списание, отзыв прямых мутаций `stock` |
| `009_admin_sales_history_rls.sql` | Admin: чтение completed sales + `users.creds` |
| `010_staff_sales_rls.sql` | `is_staff`, draft-корзина только для staff |
| `011_admin_goods_rls.sql` | Admin: CRUD `goods`; RPC `create_goods` (+ строка `stock`) |
| `012_admin_stock_meta_rpcs.sql` | Admin: метаданные позиции склада, удаление позиции |

### RLS (кратко)

- **`users`:** свой профиль; admin читает все профили (для ФИО в истории продаж)
- **`goods`:** чтение для authenticated; мутации — только admin (RLS + RPC `create_goods`)
- **`stock`:** чтение для authenticated; изменение количества — RPC admin; метаданные позиции — RPC admin
- **`sales`:** staff — свои записи + draft-мутации; admin — чтение всех `completed`
- **`goods_in_sales`:** staff — своя корзина (draft); admin — позиции completed продаж

### Realtime

Файл: `packages/supabase/migrations/004_enable_realtime.sql`

| Таблица | Поведение в приложении |
|---------|------------------------|
| `goods` | `GoodsRealtimeService` → upsert/delete в Drift |
| `stock` | `StockCubit` → тихое обновление UI (`loadStock(silent: true)`) |
| `sales`, `goods_in_sales`, `stock_movement` | В publication; `stock_movement` читается в `StockMovementHistoryScreen` (admin) |

Подписки активны только в авторизованной зоне (нужна JWT-сессия).

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
- **drift** → `app_database.g.dart` (в `local_reference`)
- **auto_route** → `app_router.gr.dart` (только в app)

### Порядок после изменений DI / роутов

```bash
# из корня
dart pub get

# supabase (если менялся injectable)
cd packages/supabase && dart run build_runner build

# local_reference (drift + injectable), sales, stock, profile, authorization, registration
cd packages/local_reference && dart run build_runner build
cd packages/sales && dart run build_runner build
cd packages/stock && dart run build_runner build
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

| Модуль | Статус |
|--------|--------|
| `packages/sales` | Реализован: касса (staff), история (admin) |
| `packages/stock` | Реализован: просмотр (staff), пополнение/списание/метаданные/журнал (admin) |
| `packages/local_reference` | Реализован (`goods`; расширяемо для других справочников) |
| `packages/profile` | Реализован + `UserSessionCubit`, `RoleGate` |
| CRUD справочника `goods` в UI | Реализован: `AdminGoodsScreen` (вход с экрана «Склад» admin) |
| Фильтры/отчёты в истории продаж | Реализованы: фильтр по дате/сотруднику, сводка, экспорт CSV |
| Route guards | Не реализованы (роль через `RoleGate`, права через RLS/RPC) |

В `pubspec.yaml` приложения подключены `dio`, `retrofit` — для будущих REST-слоёв.

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

**Задача: изменить экран склада (staff)**  
→ `packages/stock/lib/src/presentation/stock_screen.dart`  
→ логика: `packages/stock/lib/src/domain/stock_cubit.dart`

**Задача: изменить склад admin (пополнение/списание)**  
→ `packages/stock/lib/src/presentation/admin_stock_screen.dart`  
→ RPC: `packages/supabase/migrations/008_admin_stock_rpcs.sql`

**Задача: изменить кассу / продажи staff**  
→ UI: `packages/sales/lib/src/presentation/sales_screen.dart`  
→ логика: `packages/sales/lib/src/domain/sales_cubit.dart`  
→ навигация: `apps/stock_pro/lib/navigation/pages/sales_page.dart`

**Задача: изменить историю продаж admin**  
→ `packages/sales/lib/src/presentation/admin_sales_history_screen.dart`  
→ `packages/sales/lib/src/domain/admin_sales_history_cubit.dart`

**Задача: изменить поведение по роли на вкладке**  
→ `packages/profile/lib/src/presentation/role_gate.dart`  
→ обёртка: `apps/stock_pro/lib/navigation/pages/<tab>_page.dart`  
→ сессия: `AuthorizedShellPage` + `UserSessionCubit`

**Задача: добавить справочник в локальную БД**  
→ Drift-таблица: `packages/local_reference/lib/src/data/database/app_database.dart`  
→ синк: `packages/local_reference/lib/src/data/repositories/supabase_*_sync_repository.dart`  
→ Realtime: `packages/local_reference/lib/src/domain/goods_realtime_service.dart` (по аналогии)

**Задача: изменить вкладки авторизованной зоны**  
→ `apps/stock_pro/lib/navigation/pages/authorized_shell_page.dart`  
→ дочерние маршруты: `apps/stock_pro/lib/navigation/app_router.dart`

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
