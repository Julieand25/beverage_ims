-- ============================================================
-- STOCK ALERT NOTIFICATION SYSTEM
-- Run these SQL statements in your Supabase SQL Editor
-- ============================================================

-- 1. Create fcm_tokens table to store device notification tokens
CREATE TABLE IF NOT EXISTS fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform TEXT NOT NULL DEFAULT 'android',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, token)
);

-- Disable RLS (app uses custom auth, not Supabase Auth)
-- Tokens are managed by the Flutter app with user_id from session
-- Edge Function uses service_role key which bypasses RLS
ALTER TABLE fcm_tokens DISABLE ROW LEVEL SECURITY;

-- 2. Enable the pg_net extension (required for HTTP requests from triggers)
CREATE EXTENSION IF NOT EXISTS pg_net;

-- 3. Create trigger function that calls the edge function
CREATE OR REPLACE FUNCTION notify_low_stock()
RETURNS TRIGGER AS $$
BEGIN
  -- Only fire when stock drops TO or BELOW min_stock from ABOVE
  -- This prevents repeated alerts on every update once already low
  IF NEW.stock <= NEW.min_stock AND (OLD IS NULL OR OLD.stock > OLD.min_stock) THEN
    PERFORM net.http_post(
      url := 'https://fpupfdeucmaiyqczopyt.supabase.co/functions/v1/send_stock_alert',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer YOUR_SERVICE_ROLE_KEY_HERE'
      ),
      body := jsonb_build_object(
        'item_id', NEW.id,
        'item_name', NEW.name,
        'stock', NEW.stock,
        'min_stock', NEW.min_stock,
        'unit', NEW.unit
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Create the trigger on inventory_items table
DROP TRIGGER IF EXISTS stock_alert_trigger ON inventory_items;
CREATE TRIGGER stock_alert_trigger
  AFTER INSERT OR UPDATE OF stock, min_stock ON inventory_items
  FOR EACH ROW
  EXECUTE FUNCTION notify_low_stock();

-- ============================================================
-- NOTE: Replace YOUR_SERVICE_ROLE_KEY_HERE with your Supabase
-- service_role key from Project Settings > API > service_role
-- ============================================================
