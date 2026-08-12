-- Supabase Auth now owns passwords; the legacy SHA-256 hash is unused.
-- Run the pre-flight dependency check before applying this migration.

ALTER TABLE public.users
  DROP COLUMN IF EXISTS password_hash;
