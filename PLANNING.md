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
| 7 | **Auth / User** | Single user (Farisha), no login system | ❌ Not implemented |

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

### Proposed SQLite Schema (5 Tables)

`settings` table is **not needed** — theme & language are already handled by `SharedPreferences`.

```sql
-- 1. Inventory Items
CREATE TABLE inventory_items (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  category      TEXT NOT NULL CHECK(category IN ('bahan','pembungkusan','lain')),
  unit          TEXT NOT NULL CHECK(unit IN ('g','ml','unit','kg','l')),
  stock         REAL NOT NULL DEFAULT 0,
  min_stock     REAL NOT NULL DEFAULT 0,
  cost_per_unit REAL NOT NULL DEFAULT 0,
  created_at    TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at    TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 2. Recipes
CREATE TABLE recipes (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  selling_price REAL NOT NULL DEFAULT 0,
  created_at    TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at    TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 3. Recipe Ingredients (junction table)
CREATE TABLE recipe_ingredients (
  id                TEXT PRIMARY KEY,
  recipe_id         TEXT NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  inventory_item_id TEXT NOT NULL REFERENCES inventory_items(id),
  quantity          REAL NOT NULL DEFAULT 0
);

-- 4. Sales Transactions
CREATE TABLE sales (
  id            TEXT PRIMARY KEY,
  recipe_id     TEXT NOT NULL REFERENCES recipes(id),
  quantity      INTEGER NOT NULL DEFAULT 1,
  unit_price    REAL NOT NULL,
  total_amount  REAL NOT NULL,
  sold_at       TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 5. Stock Movements (for history/reports)
CREATE TABLE stock_movements (
  id                TEXT PRIMARY KEY,
  inventory_item_id TEXT NOT NULL REFERENCES inventory_items(id),
  type              TEXT NOT NULL CHECK(type IN ('restock','sale','adjustment')),
  quantity          REAL NOT NULL,
  cost_per_unit     REAL,
  total_cost        REAL,
  note              TEXT,
  moved_at          TEXT NOT NULL DEFAULT (datetime('now'))
);
```

### ER Diagram

```
┌─────────────────┐       ┌──────────────────────┐       ┌──────────────┐
│ inventory_items  │◄──────│  recipe_ingredients   │──────►│   recipes    │
│                  │       │                        │       │              │
│  id (PK)         │       │  recipe_id (FK)        │       │  id (PK)     │
│  name            │       │  inventory_item_id (FK)│       │  name        │
│  category        │       │  quantity              │       │  selling_price│
│  unit            │       └────────────────────────┘       └──────┬───────┘
│  stock           │                                                      │
│  min_stock       │       ┌──────────────────────┐                     │
│  cost_per_unit   │       │   stock_movements    │                    │
│  created_at      │◄──────│                       │                    │
│  updated_at      │       │  inventory_item_id(FK)│                    │
└─────────────────┘       │  type (restock/sale)  │                    │
                           │  quantity             │                    │
                           │  cost_per_unit        │       ┌───────────┴──┐
                           │  total_cost           │       │    sales     │
                           │  note                 │       │              │
                           │  moved_at             │       │  recipe_id   │
                           └──────────────────────┘       │  quantity    │
                                                           │  unit_price  │
                                                           │  total_amount│
                                                           │  sold_at     │
                                                           └──────────────┘
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
4. System: creates `sales` record, deducts inventory stock for each ingredient, creates `stock_movement` entries
5. Dashboard/Reports refresh with real data

**Restock Flow:**
1. User taps "Tambah Stok" on inventory item
2. Dialog: enter qty, purchase price, note
3. System: weighted-average cost recalculated, stock updated, `stock_movement(type='restock')` recorded
4. Report stock history updates

**Recipe Cost Calculation Flow:**
1. Recipe screen watches `RecipeProvider` + reads `InventoryProvider`
2. For each recipe, iterate `ingredients` → look up `costPerUnit` from inventory → `costPerServing = Σ(costPerUnit × quantity)`
3. `grossProfit = sellingPrice - costPerServing`

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
|-------|-------|
| **P1: Database Layer** | Add `sqflite` (or `drift`) dependency. Create `DatabaseService` singleton. Implement schema creation & migrations. Create repository pattern (`InventoryRepository`, `RecipeRepository`, `SalesRepository`, `StockMovementRepository`). |
| **P2: Provider Refactor** | Replace hardcoded data with DB calls. Refactor `InventoryProvider` to load from DB, write through repository. Refactor `RecipeProvider` similarly. Add `SalesProvider` and `StockMovementProvider`. |
| **P3: Sales Module** | Implement actual sales recording in dashboard modal. Auto-deduct inventory on sale. Create `stock_movements` on sale. Connect to real data. |
| **P4: Reports** | Replace hardcoded numbers with real queries from `sales` + `stock_movements` tables. Implement daily report aggregation. Stock history timeline from `stock_movements`. Monthly summary with real weekly aggregation. |
| **P5: Polish** | Empty `providers/` and `widgets/` directories cleanup. Add loading/empty states. Error handling for DB operations. |

### 4.3 Technology Choices (Recommended)

| Concern | Current | Recommended |
|---------|---------|-------------|
| State Management | Provider | Provider (keep — sufficient for this scale) |
| Database | None | `sqflite` (local SQLite) or `drift` (type-safe ORM) |
| Routing | go_router | Keep |
| Persistence | SharedPreferences | Keep for theme/locale; DB for business data |
| Architecture | Flat (app/ + screens/) | Add repository layer + services/ |
| Testing | None | Add unit tests for providers + integration tests |

### 4.4 Target Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── theme_provider.dart
│   ├── locale_provider.dart
│   ├── inventory_provider.dart
│   ├── recipe_provider.dart
│   ├── sales_provider.dart              # NEW
│   ├── translations.dart
│   ├── models/                          (keep)
│   ├── router/                          (keep)
│   ├── widgets/                         (keep)
│   └── database/
│       ├── database_service.dart        # NEW - DB connection + schema
│       ├── inventory_repository.dart    # NEW
│       ├── recipe_repository.dart       # NEW
│       ├── sales_repository.dart        # NEW
│       └── stock_movement_repository.dart # NEW
├── screens/
│   ├── dashboard_screen.dart
│   ├── inventory_screen.dart
│   ├── recipe_screen.dart
│   ├── report_screen.dart
│   └── settings_screen.dart
└── assets/
    └── character.png
```
