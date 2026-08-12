-- Link application profiles to Supabase Auth users without changing
-- existing public.users IDs or any business-table foreign keys.

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS auth_user_id UUID;

-- Supabase Auth now owns passwords. Keep existing hashes during migration,
-- but allow new profiles to omit the legacy column.
ALTER TABLE public.users
  ALTER COLUMN password_hash DROP NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'users_auth_user_id_fkey'
      AND conrelid = 'public.users'::regclass
  ) THEN
    ALTER TABLE public.users
      ADD CONSTRAINT users_auth_user_id_fkey
      FOREIGN KEY (auth_user_id)
      REFERENCES auth.users(id)
      ON DELETE RESTRICT;
  END IF;
END
$$;

CREATE UNIQUE INDEX IF NOT EXISTS users_auth_user_id_unique
  ON public.users(auth_user_id)
  WHERE auth_user_id IS NOT NULL;
