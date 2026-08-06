# Sipsync User Manual

## 1. Introduction

Sipsync is an inventory management system designed for beverage shops. It helps you track stock levels, manage recipes, record sales, and view reports — all from your mobile device.

### Key Features

- **Sales Recording** — Record sales and automatically deduct ingredients from inventory.
- **Inventory Management** — Track stock levels, set minimum stock alerts, and restock items.
- **Recipe Management** — Create and manage beverage recipes with per-cup ingredient requirements.
- **Reports** — View daily sales, stock history, and monthly summaries with charts.
- **Multi-language** — Supports English and Bahasa Melayu.
- **Dark Mode** — Light and dark theme support.

### User Roles

| Feature | Admin | Staff |
|---|---|---|
| View Dashboard | Yes | Yes |
| Record Sale | Yes | Yes |
| View Inventory | Yes | Yes |
| Add / Restock Items | Yes | No |
| View Recipes | Yes | Yes |
| Add / Edit / Delete Recipes | Yes | No |
| View Reports | Yes | Yes |
| Change Theme & Language | Yes | Yes |
| Change Own Password | Yes | Yes |
| Edit Own Name | Yes | Yes |
| Register New Staff | Yes | No |
| Manage Users | Yes | No |
| View Audit Logs | Yes | No |

---

## 2. Getting Started

### Logging In

1. Open the Sipsync app on your device.
2. Enter your registered **email address**.
3. Enter your **password**.
4. Tap the **Login** button.

If your credentials are correct, you will be taken to the Dashboard. If not, you will see an error message. If the app cannot reach the server, check your internet connection and try again.

> **Note:** Your login session is saved. You will not need to log in again each time you open the app unless you explicitly sign out.

### About Your Account

Your account is created by an administrator. If you forget your password, contact your administrator to have it reset. There is currently no self-service password recovery.

---

## 3. Dashboard

The Dashboard is your home screen after logging in. It gives you a quick overview of your shop's performance today.

### Stats at a Glance

Four summary cards show today's key numbers:

| Card | Description |
|---|---|
| **Today's Sales** | Total revenue from sales recorded today (RM). |
| **Gross Profit** | Today's revenue minus ingredient costs. |
| **Cups Sold** | Total number of cups sold today. |
| **Inventory Value** | Total value of all current stock (stock quantity × cost per unit). |

### Stock Status

The Stock Status section shows items that are running low:

- **Nearly Out** (red) — Stock has reached zero.
- **Low** (orange) — Stock is at or below the minimum threshold.

Tap **View All** to go to the full Inventory screen.

If all stock levels are sufficient, you will see a "All stock sufficient" message.

### Best Selling Menu Today

A horizontal list shows today's best-selling beverages, ranked by the number of cups sold. Tap **View Report** to see detailed reports.

---

## 4. Recording a Sale

Recording a sale deducts ingredients from your inventory automatically based on the recipe.

### Steps

1. From the Dashboard, tap the green **Record Sale** button.
2. **Select Menu** — Choose the beverage sold from the dropdown list of recipes.
3. **Quantity Sold** — Enter the number of cups sold (default is 1).
4. **Unit** — Select the unit type (Cup, Botol, Peket).
5. **Unit Price** — Enter the selling price per cup in RM.
6. **Total Sales** — This is calculated automatically (quantity × unit price).
7. Tap **Save Record**.

After saving, the ingredient stock levels are automatically reduced according to the recipe, and the sale appears in today's reports.

> **Important:** Make sure your recipes are set up correctly before recording sales, as the automatic stock deduction depends on recipe ingredients.

---

## 5. Inventory

The Inventory screen lets you view and manage all your stock items. Navigate to it by tapping the **Inventory** tab (box icon) in the bottom navigation bar.

### Browsing Inventory

- **Search** — Use the search bar at the top to find items by name.
- **Filter by Category** — Tap the filter icon to show only items from a specific category:
  - **Ingredients** (Bahan)
  - **Packaging** (Pembungkusan)
  - **Others** (Lain-lain)
  - **All** (Semua) — Show all items.
- Each item card shows:
  - Item name
  - Current stock with unit (e.g., "500 g")
  - Minimum stock level (e.g., "Min: 100 g")
  - Cost per unit (e.g., "RM7.80 / g")
  - Status badge: **Sufficient** (green) or **Low Stock** (orange)

### Adding a New Item (Admin Only)

1. Tap the **pink + button** in the bottom-right corner.
2. Fill in the form:

   | Field | Description |
   |---|---|
   | **Item Name** | Name of the item (e.g., Matcha Powder). |
   | **Category** | Choose Ingredients, Packaging, or Others. |
   | **Unit** | Choose g, ml, unit, kg, or L. |
   | **Initial Stock** | Starting quantity. |
   | **Min. Stock** | Alert threshold. You will see a warning when stock drops to or below this. |
   | **Cost Per Unit** | Purchase cost per unit in RM. |

3. Tap **Save**.

### Restocking an Item (Admin Only)

1. On the Inventory screen, tap on any item card.
2. The Restock dialog opens with the item pre-selected. Fill in:

   | Field | Description |
   |---|---|
   | **Select Ingredient** | The item to restock (pre-filled from the item you tapped). |
   | **Quantity** | How much to add. |
   | **Unit** | Unit of measurement (auto-converts: 1 kg = 1000 g, 1 L = 1000 ml). |
   | **Total Purchase Amount** | Total cost of this restock batch in RM. |
   | **Min. Stock** | Update the minimum stock alert level if needed. |
   | **Purchase Date** | Date of purchase (defaults to today). |
   | **Note** | Optional note such as supplier name. |

3. Tap **Save**.

The item's stock level is updated immediately.

---

## 6. Recipes

Recipes define how each beverage is made, including which ingredients are used and in what quantity per cup. Navigate to the **Recipe** tab (receipt icon) in the bottom navigation.

### Viewing Recipes

- **Search** — Use the search bar to find recipes by name.
- Each recipe card shows the recipe name.
- Tap a recipe card to view its details:
  - Recipe name and selling price (RM)
  - List of ingredients with quantity per cup (e.g., "Matcha Powder: 10.0 g")
  - Option to edit the recipe (admin only)

### Adding a New Recipe (Admin Only)

1. Tap the **pink + button** in the bottom-right corner.
2. Fill in:

   | Field | Description |
   |---|---|
   | **Beverage Name** | Name of the drink (e.g., Matcha Latte). |
   | **Selling Price** | Price you sell it for in RM. |

3. Add ingredients in one of two ways:
   - **Pick From Inventory** — Select an existing inventory item and enter the quantity used per cup.
   - **Add New Ingredient** — Create a new item by entering its name, unit, and category. It will also be added to your inventory.

4. You can add multiple ingredients. Each row has an **X** button to remove it.
5. Tap **Save**.

### Editing a Recipe (Admin Only)

1. Tap on a recipe to open its detail view.
2. Tap **Edit Recipe**.
3. Modify the name, selling price, or ingredients as needed.
4. Tap **Save**.

### Deleting a Recipe (Admin Only)

1. Tap the red **trash icon** on the recipe card.
2. Confirm deletion in the dialog.
3. The recipe is permanently removed.

> **Note:** Deleting a recipe does not delete the associated inventory ingredients.

---

## 7. Reports

The Reports screen provides insights into your shop's performance. Navigate to it by tapping the **Report** tab (bar chart icon).

The screen has three tabs:

### Daily Report

Shows today's data:

- **Total Sales** — Total revenue from all sales today (RM).
- **Cost of Goods** — Total ingredient cost of all items sold today (RM).
- **Gross Profit** — Revenue minus cost (RM).
- **Cups Sold** — Total cups sold today.
- **Best Selling Menu** — Ranked list of beverages sold today (#1, #2, #3) with cups sold and revenue.

### Stock History

A chronological timeline of all stock movements:

- **Green +** entries are restocks, showing what was added and when.
- **Red −** entries are deductions from sales, showing what was used and when.
- Each entry includes the item name, quantity, action type, and timestamp.

### Monthly Summary

Shows the current month's performance:

- **Monthly Revenue** — Total revenue for the month.
- **Weekly Bar Chart** — Four weeks of data with two bars per week:
  - Green bar: Gross Revenue
  - Red bar: Ingredient Cost
- A legend at the bottom explains the colour coding.

---

## 8. Settings

The Settings screen lets you manage your account and app preferences. Navigate to it by tapping the **Settings** tab (gear icon).

### Editing Your Name

1. Tap the **pencil icon** next to your name at the top.
2. Enter your new name.
3. Tap the **checkmark** to confirm, or the **X** to cancel.

### Changing Your Password

1. Tap **Change Password**.
2. Enter your **current password**.
3. Enter your **new password**.
4. **Confirm** the new password by typing it again.
5. Tap **Save**.

> Requirements: Password must be at least 6 characters. Both new password fields must match exactly.

### Changing the Theme (Light / Dark Mode)

1. Tap **Theme** under the Appearance section.
2. Toggle the switch to choose **Light** or **Dark** mode.
3. The change takes effect immediately.

### Changing the Language

1. Tap **Language** under the Appearance section (if visible).
2. Select **Melayu** or **English**.
3. The entire app switches to the selected language immediately.

---

## 9. Admin Tools

These features are only available to admin users.

### Registering a New Staff Member

1. From Settings, tap **Register Staff**.
2. Fill in the form:

   | Field | Description |
   |---|---|
   | **Name** | Staff member's full name. |
   | **Email** | Their email address (used for login). |
   | **Password** | Their password (minimum 6 characters). |
   | **Confirm Password** | Re-enter the password to confirm. |

3. Tap **Save**.
4. The new staff member can now log in with the provided email and password.

> **Note:** Email must be in a valid format (e.g., name@example.com) and must not already be in use.

### Managing Users

1. From Settings, tap **Manage Users**.
2. You will see a list of all registered users, each showing:
   - Name, role, and email
   - Active/inactive status (green dot = active, red dot = deactivated)
   - Last opened time
3. Tap on a user to manage them:

   **Change Role:**
   - Tap **Change Role**.
   - Confirm to switch between Admin and Staff.
   - You cannot change your own role.

   **Activate / Deactivate:**
   - Tap **Deactivate** to prevent a user from logging in (they will see an "Invalid credentials" error).
   - Tap **Activate** to re-enable a deactivated account.
   - You cannot deactivate your own account.

4. Pull down on the list to refresh.

### Viewing Audit Logs

Audit logs record every significant action in the system for accountability and traceability.

1. From Settings, tap **View Audit Logs**.
2. Browse through the log entries. Each entry shows:
   - An icon and colour indicating the action type
   - The user who performed the action
   - The action name and target
   - Date and time

3. **Filter by Date** — Tap the calendar icon in the top bar, select a date, and tap **OK**. Only logs from that date will be shown. Tap the **X** to clear the filter.

4. Pull down on the list to refresh.

**Logged Actions:**

| Action | Description |
|---|---|
| LOGIN | User logged in |
| SIGN_OUT | User signed out |
| RECORD_SALE | A sale was recorded |
| ADD_ITEM | A new inventory item was created |
| RESTOCK | An item was restocked |
| ADD_RECIPE | A new recipe was created |
| EDIT_RECIPE | A recipe was modified |
| DELETE_RECIPE | A recipe was deleted |
| CHANGE_PASSWORD | User changed their password |
| REGISTER_STAFF | Admin registered a new staff member |
| UPDATE_NAME | User updated their display name |

---

## 10. Signing Out

1. From any screen, go to the **Settings** tab.
2. Scroll down and tap the red **Sign Out** button.
3. You will be returned to the Login screen.

> Your session is cleared. You will need to enter your credentials again to log back in.

---

## 11. Troubleshooting

### I see "Could not connect to the server"

Your device may not have an active internet connection. Sipsync requires internet access to function. Check that:
- Wi-Fi or mobile data is turned on
- You are not in airplane mode
- The server is reachable

### I see "Invalid email or password"

- Check that you typed your email and password correctly (passwords are case-sensitive).
- If your account has been deactivated by an admin, you will see this message. Contact your administrator.

### A recipe ingredient is missing from the dropdown

If an ingredient does not appear when creating a recipe, it may not exist in your inventory yet. Add it first through the Inventory screen, or use the **Add New Ingredient** option when editing/creating the recipe.

### Stock is not deducted after recording a sale

Check that the recipe for the sold beverage has the correct ingredients listed. Stock deduction depends entirely on the recipe's ingredient list.

### I cannot add items or create recipes

These actions require an **admin** account. Staff members can only view data and record sales. Contact your administrator if you need elevated access.

---

## 12. Support

For technical support or account issues, please contact your system administrator.

---

*Sipsync v1.0.0 — Built with Flutter + Supabase*
*(c) 2026 Cuyaa Matcha Latte — Internal Use Only*
