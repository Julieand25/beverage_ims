-- Link existing public.users profiles to their Supabase Auth accounts.
--
-- IMPORTANT: this only links profiles whose Auth account already exists
-- (created via Dashboard -> Authentication -> Users -> Add user, or via the
-- admin API / create_staff_user Edge Function). Legacy password hashes cannot
-- be imported into Supabase Auth (GoTrue hashes passwords differently), so
-- migrated users must set a new password (e.g. via "Forgot Password").
--
-- Idempotent: only fills profiles that are not linked yet.

UPDATE public.users u
SET auth_user_id = au.id
FROM auth.users au
WHERE u.auth_user_id IS NULL
  AND lower(u.email) = lower(au.email);
