-- Reset application data while preserving users and FCM device tokens.
--
-- This keeps all tables, columns, constraints, functions, and triggers.
-- IDs in this project are UUIDs, so new rows will receive new random UUIDs;
-- RESTART IDENTITY only resets sequence-based columns, if any exist.

BEGIN;

TRUNCATE TABLE
  public.audit_logs,
  public.stock_movements,
  public.sales,
  public.recipe_ingredients,
  public.recipes,
  public.inventory_items
RESTART IDENTITY;

COMMIT;
