-- Add emoji/icon support for inventory items and recipes.

ALTER TABLE inventory_items ADD COLUMN IF NOT EXISTS emoji text;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS emoji text;

-- Backfill defaults for existing rows.
UPDATE inventory_items
SET emoji = CASE category
  WHEN 'bahan' THEN '🍚'
  WHEN 'pembungkusan' THEN '🥡'
  ELSE '📦'
END
WHERE emoji IS NULL;

UPDATE recipes SET emoji = '☕' WHERE emoji IS NULL;