// @ts-nocheck
import { createClient } from "jsr:@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  Deno.env.get("SERVICE_ROLE_KEY");

if (!serviceRoleKey) {
  throw new Error("SUPABASE_SERVICE_ROLE_KEY is not configured");
}

const adminClient = createClient(supabaseUrl, serviceRoleKey);

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const authorization = request.headers.get("Authorization");
  const accessToken = authorization?.startsWith("Bearer ")
    ? authorization.substring("Bearer ".length)
    : null;

  if (!accessToken) {
    return json({ error: "Missing authorization" }, 401);
  }

  try {
    const { data: authData, error: authError } = await adminClient.auth.getUser(
      accessToken,
    );
    if (authError || !authData.user) {
      return json({ error: "Unauthorized" }, 401);
    }

    const { data: caller, error: callerError } = await adminClient
      .from("users")
      .select("id,role,is_active")
      .eq("auth_user_id", authData.user.id)
      .maybeSingle();

    if (
      callerError ||
      !caller ||
      caller.role !== "admin" ||
      caller.is_active !== true
    ) {
      return json({ error: "Admin access required" }, 403);
    }

    const payload = await request.json();
    const name = typeof payload.name === "string" ? payload.name.trim() : "";
    const email = typeof payload.email === "string"
      ? payload.email.trim().toLowerCase()
      : "";
    const password = typeof payload.password === "string"
      ? payload.password
      : "";

    if (!name || !email || password.length < 6) {
      return json({ error: "Invalid staff details" }, 400);
    }

    const { data: created, error: createError } = await adminClient.auth.admin
      .createUser({
        email,
        password,
        email_confirm: true,
      });

    if (createError || !created.user) {
      return json({ error: createError?.message ?? "Unable to create user" }, 400);
    }

    const { data: profile, error: profileError } = await adminClient
      .from("users")
      .insert({
        name,
        email,
        role: "staff",
        is_active: true,
        auth_user_id: created.user.id,
      })
      .select("id,name,email,role,is_active,last_open,created_at,auth_user_id")
      .single();

    if (profileError || !profile) {
      await adminClient.auth.admin.deleteUser(created.user.id);
      return json({ error: profileError?.message ?? "Unable to create profile" }, 400);
    }

    return json({ user: profile });
  } catch (error) {
    console.error(error);
    return json({ error: "Unable to create staff account" }, 500);
  }
});
