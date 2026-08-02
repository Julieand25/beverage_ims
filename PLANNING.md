# Beverage IMS — Project Analysis & Planning Document

## 1. Modules / Features

| # | Module | Description | Current Status |
|---|--------|-------------|----------------|
| 1 | **Dashboard** | Sales overview, stock alerts, best-selling menu, record sale | ✅ Built (hardcoded mock data) |
| 2 | **Inventory** | CRUD items, category filtering, search, restock with weighted-avg costing | ✅ Built (in-memory) |
| 3 | **Recipe** | CRUD recipes, ingredient linking, cost/profit calculation, search | ✅ Built (in-memory) |
| 4 | **Reports** | Daily sales, stock history timeline, monthly summary with bar chart | ✅ Built (hardcoded mock data) |
| 5 | **Settings** | Theme toggle (dark/light), language selector (MS/EN) | ✅ Built (persisted via SharedPreferences) |
| 6 | **Sales Recording** | Record sale with recipe selection, qty, price, auto-stock deduction | ⚠️ UI only — no actual data persistence |
| 7 | **Auth / User Roles** | Admin & staff roles, login/logout, role-based UI, audit logging of all mutations | 🔨 In Progress |

**Key Observations:**
- All data is **in-memory** — no database (SQLite, Hive, etc.)
- Dashboard & Reports use **static hardcoded numbers**, not computed from actual data
- Sales recording modal doesn't save or deduct stock
- No data persists across app restarts (except theme/language)

---

## 2. Database Design

### Current State
No database. All data in memory via `ChangeNotifier` providers.

### Philosophy: Recipe-First Workflow

This app follows a **recipe-first** approach. Staff think in menu items, not inventory management.

When creating a recipe with a new ingredient that doesn't exist in inventory:

1. User types the ingredient name in the recipe form
2. System auto-creates an `inventory_items` row with `stock=0`, `cost_per_unit=0`, `min_stock=0`
3. User only needs to fill 2 extra fields inline: **unit** and **category**
4. Recipe is saved with the new ingredient linked
5. Later, user visits Inventory to set min_stock and restock

This means `cost_per_unit`, `stock`, and `min_stock` can all be **0** at creation time — they get filled when the first restock happens.

### Proposed Supabase PostgreSQL Schema (7 Tables)

`settings` is **not needed** — theme & language are handled by `SharedPreferences`.

```sql
-- 1. Users
CREATE TABLE users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL,
  email         TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role          TEXT NOT NULL CHECK(role IN ('admin','staff')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Inventory Items
CREATE TABLE inventory_items (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL,
  category      TEXT NOT NULL CHECK(category IN ('bahan','pembungkusan','lain')),
  unit          TEXT NOT NULL CHECK(unit IN ('g','ml','unit','kg','l')),
  stock         REAL NOT NULL DEFAULT 0,
  min_stock     REAL NOT NULL DEFAULT 0,
  cost_per_unit REAL NOT NULL DEFAULT 0,
  created_by    UUID REFERENCES users(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Recipes
CREATE TABLE recipes (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL,
  selling_price REAL NOT NULL DEFAULT 0,
  created_by    UUID REFERENCES users(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Recipe Ingredients (junction table)
CREATE TABLE recipe_ingredients (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id         UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  inventory_item_id UUID NOT NULL REFERENCES inventory_items(id),
  quantity          REAL NOT NULL DEFAULT 0
);

-- 5. Sales Transactions
CREATE TABLE sales (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id     UUID NOT NULL REFERENCES recipes(id),
  quantity      INTEGER NOT NULL DEFAULT 1,
  unit_price    REAL NOT NULL,
  total_amount  REAL NOT NULL,
  recorded_by   UUID REFERENCES users(id),
  sold_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. Stock Movements (for history/reports)
CREATE TABLE stock_movements (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  inventory_item_id UUID NOT NULL REFERENCES inventory_items(id),
  type              TEXT NOT NULL CHECK(type IN ('restock','sale','adjustment')),
  quantity          REAL NOT NULL,
  cost_per_unit     REAL,
  total_cost        REAL,
  note              TEXT,
  user_id           UUID REFERENCES users(id),
  moved_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7. Audit Logs
CREATE TABLE audit_logs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users(id),
  user_name   TEXT NOT NULL,
  action      TEXT NOT NULL,
  target_type TEXT,
  target_id   TEXT,
  details     JSONB DEFAULT '{}',
  timestamp   TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### ER Diagram

```
┌──────────────┐       ┌──────────────────────┐       ┌──────────────┐
│   users      │       │  recipe_ingredients   │       │   recipes    │
│              │       │                        │       │              │
│  id (PK)     │──┐    │  recipe_id (FK)        │       │  id (PK)     │
│  name        │  │    │  inventory_item_id (FK)│       │  name        │
│  email       │  │    │  quantity              │       │  selling_price│
│  password_hash│ │    └───────────┬────────────┘       │  created_by──┼───┐
│  role        │  │                │                    │  created_at  │   │
│  created_at  │  │                ▼                    │  updated_at  │   │
└──────┬───────┘  │    ┌──────────────────┐             └──────┬───────┘   │
       │          │    │ inventory_items  │                    │           │
       │          └───►│                  │◄──────┐            │           │
       │               │  id (PK)         │       │            │           │
       │               │  name            │       │            │           │
       │               │  category        │       │            │           │
       │               │  unit            │       │            │           │
       │               │  stock           │       │            │           │
       │               │  min_stock       │       │            │           │
       │               │  cost_per_unit   │       │            │           │
       │               │  created_by──────┼───┐   │            │           │
       │               │  created_at      │   │   │            │           │
       │               │  updated_at      │   │   │            │           │
       │               └────────┬─────────┘   │   │            │           │
       │                        │             │   │            │           │
       │          ┌─────────────┼─────────────┼───┼────────────┼───────────┘
       │          │             │             │   │            │
       │          ▼             ▼             │   │            │
       │  ┌──────────────────────────────┐    │   │            │
       │  │      stock_movements         │    │   │            │
       │  │                              │    │   │            │
       ├──│  user_id (FK)                │    │   │            │
       │  │  inventory_item_id (FK)      │    │   │            │
       │  │  type (restock/sale)         │    │   │            │
       │  │  quantity                    │    │   │            │
       │  │  cost_per_unit               │    │   │            │
       │  │  total_cost                  │    │   │            │
       │  │  note                        │    │   │            │  ┌──────────────┐
       │  │  moved_at                    │    │   │            │  │ audit_logs   │
       │  └──────────────────────────────┘    │   │            │  │              │
       │                                      │   │            ├──│ user_id (FK) │
       │  ┌──────────────┐                    │   │            │  │ user_name    │
       │  │    sales     │                    │   │            │  │ action       │
       │  │              │                    │   │            │  │ target_type  │
       │  │  recipe_id (FK)─────────────────┘ │              │  │ target_id    │
       │  │  quantity    │                    │              │  │ details      │
       ├──│ recorded_by  │                    │              │  │ timestamp    │
       │  │  unit_price  │                    │              │  └──────────────┘
       │  │  total_amount│                    │
       │  │  sold_at     │                    │
       │  └──────────────┘                    │
       │                                      │
       └──────────────────────────────────────┘
```


### Key Design Decisions for Recipe-First

| Decision | Why |
|----------|-----|
| `cost_per_unit = 0` for new items | User hasn't purchased yet — can't know cost |
| `stock = 0` for new items | Haven't bought inventory yet |
| `min_stock = 0` for new items | User sets this when they first restock |
| Ingredients dropdown shows ALL items (including stock=0) | Need to reference them in recipes even before buying |
| No `settings` table | SharedPreferences already handles theme/language |
| New items highlighted with "Belum diisi" badge | Reminds user to set min_stock and restock |

---

## 3. Flow

### 3.1 Complete First-Time User Flow

```
┌────────────────────────────────────────────────────────────────────┐
│                    FIRST TIME USER (EMPTY STATE)                    │
└────────────────────────────────────────────────────────────────────┘

        OPEN APP → Dashboard (all zeros)
                       │
                       ▼
        ┌──────────────────────────────┐
        │  STEP 1: SETUP INVENTORY     │ ◄── START HERE if not
        │  (optional — skip if using   │     using recipe-first flow
        │   recipe-first flow below)   │
        └──────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │  STEP 2: SETUP RECIPES       │ ◄── RECOMMENDED START
        │                              │
        │  Create "Matcha Latte"       │
        │   ├── Ingredient: Matcha    │
        │   │   Powder 5g (NEW)       │
        │   │   → auto-create in      │
        │   │     inventory           │
        │   ├── Ingredient: Susu UHT │
        │   │   150ml (NEW)           │
        │   │   → auto-create         │
        │   └── Selling price: RM 8   │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │  STEP 3: RESTOCK             │
        │  Go to Inventory →           │
        │  Items have stock=0          │
        │  Tap "Tambah Stok"           │
        │  ├── Matcha: +1000g @RM65   │
        │  ├── Susu: +5000ml @RM40    │
        │  └── Set min_stock for each │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │  STEP 4: SELL                │
        │  Dashboard → Record Sale     │
        │  ├── Recipe: Matcha Latte    │
        │  ├── Qty: 2                 │
        │  └── Save → stock deducts   │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │  STEP 5: VIEW REPORTS        │
        │  Check daily sales, profit,  │
        │  stock history, trends       │
        └──────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │  ONGOING LOOP                │
        │  Sell → Restock when low →   │
        │  Add recipes as menu grows   │
        └──────────────────────────────┘
```

### 3.2 Navigation Flow (Bottom Tab)

```
App Launch
  └─> /dashboard (DashboardScreen)
        ├─ "Record Sale" → Modal dialog (select recipe → qty → save)
        ├─ "View All" → /inventori
        └─ "View Report" → /laporan

  ─── Bottom Navigation ───

  /dashboard   → Dashboard (default)
  /inventori   → Inventory Management
  /resipi      → Recipe Management
  /laporan     → Reports
  /tetapan     → Settings
```

### 3.3 Data Flow (Proposed)

```
User Action
    ↓
Screen (UI) ──reads/watch──→ Provider (ChangeNotifier)
                                  ↓
                          Database Service (Repository Layer)
                                  ↓
                              SQLite DB
                                  ↓
                          Provider updates state
                                  ↓
                          UI rebuilds via Consumer
```

### 3.4 Key Flows

**Recipe Creation Flow (Recipe-First):**
1. User taps "+" on Recipe screen
2. Fills name + selling price
3. Adds ingredient row → dropdown shows existing inventory items
4. If ingredient not found → user types name → inline form appears: **unit?** + **kategori?**
5. System auto-creates `inventory_items` row (stock=0, cost=0, min_stock=0)
6. Recipe saved → `recipes` + `recipe_ingredients` rows created
7. Inventory tab now shows new item with "Belum diisi" badge

**Record Sale Flow:**
1. User taps "Record Sale" on Dashboard
2. Modal opens: select recipe, enter qty, price auto-fills
3. Tap "Simpan Rekod"
4. System: creates `sales` record, deducts inventory stock for each ingredient, creates `stock_movement` entries, logs to `audit_logs` with `user_id`
5. Dashboard/Reports refresh with real data

**Restock Flow:**
1. User taps "Tambah Stok" on inventory item
2. Dialog: enter qty, purchase price, note
3. System: weighted-average cost recalculated, stock updated, `stock_movement(type='restock')` recorded, logged to `audit_logs`
4. Report stock history updates

**Recipe Cost Calculation Flow:**
1. Recipe screen watches `RecipeProvider` + reads `InventoryProvider`
2. For each recipe, iterate `ingredients` → look up `costPerUnit` from inventory → `costPerServing = Σ(costPerUnit × quantity)`
3. `grossProfit = sellingPrice - costPerServing`

### 3.5 Login & Role Flow

```
App Launch → /login
     │
     ▼
AuthProvider.login(email, password)
     │
     ├── Valid credentials → currentUser set → Router redirect → /dashboard
     │
     ├── Admin user → 5 bottom tabs visible
     │   ├── Dashboard: full access
     │   ├── Inventory: full CRUD (add, restock, view)
     │   ├── Recipes: full CRUD (add, edit, delete, view)
     │   ├── Reports: full access
     │   └── Settings: full access (theme, language, change password, sign out)
     │
     └── Staff user → 4 bottom tabs visible (Settings hidden)
         ├── Dashboard: view + record sale only
         ├── Inventory: view only (add-FAB hidden, restock disabled)
         ├── Recipes: view only (add-FAB hidden, edit/delete disabled)
         └── Reports: view only
```

### 3.6 Audit Trail Flow

```
Every mutation action in the app:
  (addItem, restock, addRecipe, updateRecipe, deleteRecipe, recordSale, changePassword, login, signOut)
     │
     ▼
AuditRepository.addLog(
  userId,        // who did it
  user_name,     // display name
  action,        // "ADD_ITEM", "RESTOCK", "RECORD_SALE", etc.
  target_type,   // "inventory", "recipe", "sale", "auth"
  target_id,     // which item/recipe was affected
  details: {     // JSONB - rich context
    "item_name": "Matcha Powder",
    "qty_before": 1000,
    "qty_after": 300,
    "qty_change": -700
  }
)
     │
     ▼
AuditProvider.allLogs → viewable in Reports → Stock History tab (future: dedicated Audit tab)
     │
     ▼
Audit logs persist in-memory now, in Supabase `audit_logs` table later.
Each log linked to a `user_id` so you can filter by user, date range, or action type.
```

### 3.7 Role Access Matrix

| Feature | Admin | Staff |
|---|---|---|
| Dashboard (view stats) | Full | Full |
| Dashboard (record sale) | Full | Full |
| Inventory (view) | Full | Full |
| Inventory (add item) | Full | Hidden |
| Inventory (restock) | Full | Hidden |
| Recipes (view) | Full | Full |
| Recipes (add/edit/delete) | Full | Hidden |
| Reports (view) | Full | Full |
| Settings tab (bottom nav) | Visible | Hidden |
| Change password | Full | Hidden |
| Audit log viewing | Full | Future |

---

## 4. Implementation

### 4.1 Current Architecture

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # MultiProvider + MaterialApp.router
│   ├── theme_provider.dart         # Theme state (ChangeNotifier)
│   ├── locale_provider.dart        # Locale state (ChangeNotifier)
│   ├── inventory_provider.dart     # Inventory CRUD + filtering (hardcoded data)
│   ├── recipe_provider.dart        # Recipe CRUD (hardcoded data)
│   ├── translations.dart           # Bilingual strings (MS/EN)
│   ├── models/
│   │   ├── inventory_item.dart     # InventoryItem + enums
│   │   └── recipe.dart             # Recipe + RecipeIngredient
│   ├── router/
│   │   └── router.dart             # GoRouter with StatefulShellRoute
│   └── widgets/
│       └── app_shell.dart          # BottomNavigationBar scaffold
├── screens/
│   ├── login_screen.dart
│   ├── change_password_screen.dart
│   ├── dashboard_screen.dart
│   ├── inventory_screen.dart
│   ├── recipe_screen.dart
│   ├── report_screen.dart
│   └── settings_screen.dart
├── providers/                      # ❌ Empty
└── widgets/                        # ❌ Empty
```

### 4.2 Recommended Implementation Roadmap

| Phase | Tasks |
|---|---|
| **P0: Auth + Roles** | User model (`User` + `UserRole` enum). AuthRepository interface + `InMemoryAuthRepository`. `AuthProvider` (login/logout/session). Router guard (redirect unauthenticated to `/login`). Wire up `LoginScreen`, `SettingsScreen` sign-out, `ChangePasswordScreen`. Role-based bottom navigation (`AppShell` hides Settings tab for staff). `InventoryScreen`/`RecipeScreen` hide add/edit for staff. |
| **P1: Audit Trail** | `AuditLog` model. AuditRepository interface + `InMemoryAuditRepository`. `AuditProvider`. Patch `InventoryProvider` to log `ADD_ITEM`/`RESTOCK`. Patch `RecipeProvider` to log `ADD_RECIPE`/`EDIT_RECIPE`/`DELETE_RECIPE`. Wire record-sale to log `RECORD_SALE`. Wire auth actions to log `LOGIN`/`SIGN_OUT`/`CHANGE_PASSWORD`. |
| **P2: Repository Pattern Refactor** | Extract `InventoryRepository` & `RecipeRepository` as abstract classes. Move seed data to `InMemoryInventoryRepository` & `InMemoryRecipeRepository`. Providers call repo methods. Zero behavior change — purely architectural. |
| **P3: Sales Module** | Implement real sale recording: deduct stock per recipe ingredients, create `stock_movements`, compute totals. Wire dashboard modal "Simpan" button. Dashboard stat cards computed from real data (not hardcoded). |
| **P4: Reports from Real Data** | Replace hardcoded dashboard/report numbers with computed data from providers. Daily report aggregation from sales. Stock history timeline from stock_movements + audit_logs. |
| **P5: Supabase Migration** | Add `supabase_flutter` dependency. Create `SupabaseAuthRepository`, `SupabaseInventoryRepository`, `SupabaseRecipeRepository`, `SupabaseAuditRepository`. Swap 4 lines in `app.dart`. Zero UI/screen changes. Deploy Supabase tables via migration SQL. |

### 4.3 Technology Choices

| Concern | Current | Recommended |
|---|---|---|
| State Management | Provider | Provider (keep — sufficient for this scale) |
| Database | None (in-memory) | In-memory via repository pattern now; Supabase PostgreSQL later |
| Routing | go_router | Keep — add `redirect` guard for auth |
| Persistence | SharedPreferences | Keep for theme/locale/session; business data via repository |
| Architecture | Flat (app/ + screens/) | Repository pattern (abstraction layer between providers and data) |
| Auth | None | Custom in-memory now; Supabase Auth later |
| Testing | None | Add unit tests for providers + integration tests |

### 4.4 Repository Pattern Architecture (Supabase-Ready)

```
┌──────────────────────────────────────────────────────────┐
│  Screens / UI                                            │
│  (LoginScreen, InventoryScreen, DashboardScreen, etc.)   │
│       ↕ context.watch / context.read                      │
├──────────────────────────────────────────────────────────┤
│  Providers (ChangeNotifier)                              │
│  AuthProvider, InventoryProvider, RecipeProvider, etc.   │
│       ↕ call repository methods                           │
├──────────────────────────────────────────────────────────┤
│  Repository Interface (abstract class)                   │
│  AuthRepository, InventoryRepository, RecipeRepository   │
│       ↕                                                   │
│  ┌──────────────────────┐  ┌─────────────────────────┐   │
│  │ InMemoryRepository    │  │ SupabaseRepository      │   │
│  │ (built NOW)           │  │ (built LATER)           │   │
│  │ List<> + SharedPrefs  │  │ supabase_flutter client │   │
│  └──────────────────────┘  └─────────────────────────┘   │
└──────────────────────────────────────────────────────────┘

Key benefit: When ready for Supabase, swap 4 lines in app.dart.
Zero changes to providers, screens, or router.
```

### 4.5 How Supabase Migration Works (Future)

```
Step 1: Add dependency    →  supabase_flutter
Step 2: Write 4 classes   →  SupabaseAuthRepository implements AuthRepository
                              SupabaseInventoryRepository implements InventoryRepository
                              SupabaseRecipeRepository implements RecipeRepository
                              SupabaseAuditRepository implements AuditRepository
Step 3: Swap in app.dart  →  // Was:
                              AuthProvider(InMemoryAuthRepository())
                              InventoryProvider(InMemoryInventoryRepository())
                              // Becomes:
                              AuthProvider(SupabaseAuthRepository(client))
                              InventoryProvider(SupabaseInventoryRepository(client))
Step 4: Run migration SQL  →  Deploy 7 tables via Supabase dashboard
Step 5: Done                →  Zero UI changes. All data now in PostgreSQL.
```

### 4.6 Target Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── theme_provider.dart
│   ├── locale_provider.dart
│   ├── inventory_provider.dart
│   ├── recipe_provider.dart
│   ├── auth_provider.dart                   # NEW
│   ├── audit_provider.dart                  # NEW
│   ├── translations.dart
│   ├── models/
│   │   ├── inventory_item.dart
│   │   ├── recipe.dart
│   │   ├── user.dart                        # NEW
│   │   └── audit_log.dart                   # NEW
│   ├── router/
│   │   └── router.dart
│   ├── widgets/
│   │   └── app_shell.dart
│   └── repositories/                        # NEW directory
│       ├── auth_repository.dart             # NEW (abstract + InMemory)
│       ├── inventory_repository.dart        # NEW (abstract + InMemory)
│       ├── recipe_repository.dart           # NEW (abstract + InMemory)
│       └── audit_repository.dart            # NEW (abstract + InMemory)
├── screens/
│   ├── login_screen.dart
│   ├── change_password_screen.dart
│   ├── dashboard_screen.dart
│   ├── inventory_screen.dart
│   ├── recipe_screen.dart
│   ├── report_screen.dart
│   └── settings_screen.dart
└── assets/
    └── character.png
```
