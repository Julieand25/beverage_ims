# Beverage IMS (Sip-Sync) — Architecture Overview

> Inventory Management System for beverage shops  
> **Version:** 1.0.0+1  
> **Copyright:** Cuyaa Matcha Latte © 2026

---

## Tech Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter (SDK ≥3.12.0), Dart |
| **Backend / DB** | Supabase (PostgreSQL + REST API + RPC) |
| **State Management** | Provider (ChangeNotifier) |
| **Routing** | GoRouter (`StatefulShellRoute.indexedStack`) |
| **Local Storage** | SharedPreferences |
| **Auth / Hashing** | crypto (SHA‑256) |
| **UI** | Material Design 3, custom `ThemeExtension<AppColors>` |
| **i18n** | Custom hand‑rolled bilingual (MS / EN) |
| **Target Platforms** | Android, iOS, Windows, macOS, Linux, Web |

---

## Architecture Layers

```
┌──────────────────────────────────────────────────────────┐
│  UI Layer (Screens)                                       │
│  - Widgets watch providers via context.watch<T>()        │
│  - Actions dispatched via context.read<T>()              │
│  - Navigation via context.go() / context.push()           │
├──────────────────────────────────────────────────────────┤
│  State Layer (8 ChangeNotifier Providers)                 │
│  - Hold application state, call repository methods       │
│  - notifyListeners() triggers UI rebuilds                 │
├──────────────────────────────────────────────────────────┤
│  Repository Layer (Abstract interface + Supabase impl)   │
│  - 5 repository pairs (auth, audit, inventory, recipe,   │
│    sales)                                                │
│  - JSON serialization / deserialization                   │
├──────────────────────────────────────────────────────────┤
│  Data Layer (Supabase PostgreSQL)                         │
│  - 7 tables, 2 RPC stored procedures                     │
└──────────────────────────────────────────────────────────┘
```

### Design Patterns

- **Repository Pattern** — abstract interfaces decouple providers from Supabase
- **Provider (ChangeNotifier)** — reactive state management
- **StatefulShellRoute** — persistent bottom‑nav tabs with independent navigation stacks
- **Custom ThemeExtension** — semantic colour tokens for light/dark cards, borders, surfaces
- **RBAC** — `admin` vs `staff` roles; staff cannot access Settings tab, add/edit/delete actions

---

## Directory Structure

```
lib/
├── main.dart                         # Supabase init + runs App()
├── app/
│   ├── app.dart                      # MultiProvider + MaterialApp.router
│   ├── app_colors.dart               # ThemeExtension<AppColors>
│   ├── auth_provider.dart            # AuthProvider
│   ├── audit_provider.dart           # AuditProvider
│   ├── inventory_provider.dart       # InventoryProvider
│   ├── locale_provider.dart          # LocaleProvider (MS/EN)
│   ├── recipe_provider.dart          # RecipeProvider
│   ├── sales_provider.dart           # SalesProvider
│   ├── theme_provider.dart           # ThemeProvider (light/dark)
│   ├── translations.dart             # Bilingual string maps
│   ├── user_provider.dart            # UserProvider
│   ├── models/
│   │   ├── audit_log.dart
│   │   ├── inventory_item.dart
│   │   ├── recipe.dart
│   │   └── user.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── audit_repository.dart
│   │   ├── inventory_repository.dart
│   │   ├── recipe_repository.dart
│   │   └── sales_repository.dart
│   ├── router/
│   │   └── router.dart               # GoRouter + auth redirect guard
│   └── widgets/
│       └── app_shell.dart            # BottomNavBar shell
├── screens/
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── inventory_screen.dart
│   ├── recipe_screen.dart
│   ├── report_screen.dart
│   ├── settings_screen.dart
│   ├── change_password_screen.dart
│   ├── register_staff_screen.dart
│   ├── user_management_screen.dart
│   ├── audit_log_screen.dart
│   ├── about_screen.dart
│   ├── theme_screen.dart
│   └── language_screen.dart
├── providers/                        # Empty (providers live in app/)
└── widgets/                          # Empty (only AppShell extracted)
```

---

## Providers (State Management)

8 `ChangeNotifier` providers wired via `MultiProvider` in `app.dart`:

| Provider | Responsibility |
|---|---|
| **AuthProvider** | Login/logout, session restore, password change, register staff, update name. Holds `currentUser`. Acts as `refreshListenable` for GoRouter auth guard. |
| **AuditProvider** | Loads all audit logs; provides `getByUser(userId)` filter; updates locally on new log insert. |
| **InventoryProvider** | CRUD for inventory items; client‑side filtering by `searchQuery` and `selectedCategory`; restock via PostgreSQL RPC. |
| **RecipeProvider** | CRUD for recipes & ingredients; client‑side search; add/edit with ingredient linking to inventory. |
| **SalesProvider** | Today's stats (sales, cups, COGS, profit), best sellers (top 3), monthly stats, stock movement timeline. |
| **UserProvider** | Admin‑only user management: list all users, change role, toggle activate/deactivate. |
| **ThemeProvider** | Light/dark mode toggle, persisted to SharedPreferences. |
| **LocaleProvider** | MS/EN language switch, persisted to SharedPreferences, defaults to `ms`. |

---

## Routing

GoRouter with `StatefulShellRoute.indexedStack` for persistent bottom tabs.

### Routes

| Path | Screen | Tab |
|---|---|---|
| `/login` | LoginScreen | — |
| `/change-password` | ChangePasswordScreen | — |
| `/register-staff` | RegisterStaffScreen | — |
| `/manage-users` | UserManagementScreen | — |
| `/audit-logs` | AuditLogScreen | — |
| `/about` | AboutScreen | — |
| `/theme` | ThemeScreen | — |
| `/language` | LanguageScreen | — |
| `/dashboard` | DashboardScreen | Tab 1 |
| `/inventori` | InventoryScreen | Tab 2 |
| `/resipi` | RecipeScreen | Tab 3 |
| `/laporan` | ReportScreen | Tab 4 |
| `/tetapan` | SettingsScreen | Tab 5 |

### Auth Guard

- Unauthenticated → always redirect to `/login`
- Authenticated on `/login` → redirect to `/dashboard`

---

## Models (Data Classes)

### User
`id`, `name`, `email`, `role` (`UserRole.admin` | `UserRole.staff`), `isActive`, `lastOpen`

### InventoryItem
`id`, `name`, `category` (`bahan` | `pembungkusan` | `lain`), `unit` (`g` | `ml` | `unit` | `kg` | `l`), `stock`, `minStock`, `costPerUnit`
- Computed: `isLowStock` (stock ≤ minStock), `stockValue` (stock × costPerUnit)

### Recipe + RecipeIngredient
- **Recipe:** `id`, `name`, `sellingPrice`, `ingredients` (List\<RecipeIngredient\>)
- **RecipeIngredient:** `inventoryItemId`, `quantity`
- Methods: `costPerServing()`, `grossProfit()`

### AuditLog
`id`, `userId`, `userName`, `action`, `targetType`, `targetId`, `details` (JSON), `timestamp`

---

## Repositories

Each repository follows an **abstract interface + Supabase implementation** pattern.

| Repository | Key Methods |
|---|---|
| **AuthRepository** | `login()`, `logout()`, `changePassword()`, `getStoredSession()`, `registerUser()`, `fetchAllUsers()`, `updateUserRole()`, `toggleUserActive()`, `updateUserName()` |
| **AuditRepository** | `addLog()`, `getAll()`, `getByUser()` |
| **InventoryRepository** | `getAll()`, `addItem()`, `restockItem()` (via RPC) |
| **RecipeRepository** | `getAll()`, `addRecipe()`, `updateRecipe()`, `deleteRecipe()` |
| **SalesRepository** | `recordSale()` (via RPC), `getDailyStats()`, `getBestSellers()`, `getMonthlyStats()`, `getStockMovements()` |

---

## Database (Supabase PostgreSQL)

### Tables

#### `users`
| Column | Type | Notes |
|---|---|---|
| `id` | UUID | PK |
| `name` | TEXT | — |
| `email` | TEXT | UNIQUE |
| `password_hash` | TEXT | SHA‑256 |
| `role` | TEXT | `admin` \| `staff` |
| `is_active` | BOOLEAN | Default `true` |
| `last_open` | TIMESTAMPTZ | — |
| `created_at` | TIMESTAMPTZ | Default `now()` |

#### `inventory_items`
| Column | Type | Notes |
|---|---|---|
| `id` | UUID | PK |
| `name` | TEXT | — |
| `category` | TEXT | `bahan` \| `pembungkusan` \| `lain` |
| `unit` | TEXT | `g` \| `ml` \| `unit` \| `kg` \| `l` |
| `stock` | REAL | Default `0` |
| `min_stock` | REAL | Default `0` |
| `cost_per_unit` | REAL | Default `0` |
| `created_by` | UUID | FK → users.id |
| `created_at` | TIMESTAMPTZ | Default `now()` |
| `updated_at` | TIMESTAMPTZ | Default `now()` |

#### `recipes`
| Column | Type | Notes |
|---|---|---|
| `id` | UUID | PK |
| `name` | TEXT | — |
| `selling_price` | REAL | Default `0` |
| `created_by` | UUID | FK → users.id |
| `created_at` | TIMESTAMPTZ | Default `now()` |
| `updated_at` | TIMESTAMPTZ | Default `now()` |

#### `recipe_ingredients`
| Column | Type | Notes |
|---|---|---|
| `id` | UUID | PK |
| `recipe_id` | UUID | FK → recipes.id, CASCADE |
| `inventory_item_id` | UUID | FK → inventory_items.id |
| `quantity` | REAL | Default `0` |

#### `sales`
| Column | Type | Notes |
|---|---|---|
| `id` | UUID | PK |
| `recipe_id` | UUID | FK → recipes.id |
| `quantity` | INTEGER | Default `1` |
| `unit_price` | REAL | — |
| `total_amount` | REAL | — |
| `recorded_by` | UUID | FK → users.id |
| `sold_at` | TIMESTAMPTZ | Default `now()` |

#### `stock_movements`
| Column | Type | Notes |
|---|---|---|
| `id` | UUID | PK |
| `inventory_item_id` | UUID | FK → inventory_items.id |
| `type` | TEXT | `restock` \| `sale` \| `adjustment` |
| `quantity` | REAL | — |
| `cost_per_unit` | REAL | — |
| `total_cost` | REAL | — |
| `note` | TEXT | — |
| `user_id` | UUID | FK → users.id |
| `moved_at` | TIMESTAMPTZ | Default `now()` |

#### `audit_logs`
| Column | Type | Notes |
|---|---|---|
| `id` | UUID | PK |
| `user_id` | UUID | FK → users.id |
| `user_name` | TEXT | — |
| `action` | TEXT | — |
| `target_type` | TEXT | — |
| `target_id` | TEXT | — |
| `details` | JSONB | Default `'{}'` |
| `timestamp` | TIMESTAMPTZ | Default `now()` |

### Entity Relationship

```
users ──1:N── inventory_items (created_by)
users ──1:N── recipes (created_by)
users ──1:N── sales (recorded_by)
users ──1:N── stock_movements (user_id)
users ──1:N── audit_logs (user_id)

recipes ──1:N── recipe_ingredients (recipe_id)
inventory_items ──1:N── recipe_ingredients (inventory_item_id)
recipes ──1:N── sales (recipe_id)
inventory_items ──1:N── stock_movements (inventory_item_id)
```

### Stored Procedures (RPC)

**`restock_item_atomic`** — Atomically updates stock, recalculates `cost_per_unit`, inserts `stock_movements` (type=restock), writes `audit_log`.

**`record_sale_atomic`** — Atomically inserts `sales` row, deducts ingredient stock via `stock_movements` (type=sale), writes `audit_log`.

---

## Assets

| File | Usage |
|---|---|
| `assets/sipsync.png` | Login screen app logo |
| `assets/sipsync_app_logo.png` | App store / branding |
| `assets/character.png` | Dashboard profile avatar |
| `web/icons/Icon-*.png` | Web PWA icons |
| `web/favicon.png` | Browser favicon |
