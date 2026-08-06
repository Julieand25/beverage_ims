import { createClient } from "jsr:@supabase/supabase-js@2";
import { initializeApp, cert, getApps } from "npm:firebase-admin@^12.0.0";
import { getMessaging } from "npm:firebase-admin@^12.0.0/messaging";

// Firebase Admin SDK service account key
// Set via: npx supabase secrets set FIREBASE_SERVICE_ACCOUNT='{...}'
const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
if (!serviceAccountJson) {
  throw new Error(
    "FIREBASE_SERVICE_ACCOUNT environment variable is not set. " +
    "Set it via: supabase secrets set FIREBASE_SERVICE_ACCOUNT='...'"
  );
}
const serviceAccount = JSON.parse(serviceAccountJson);

// Initialize Firebase Admin
if (getApps().length === 0) {
  initializeApp({
    credential: cert(serviceAccount),
  });
}

// Supabase client
const supabaseUrl = Deno.env.get("SUPABASE_URL") ??
  "https://fpupfdeucmaiyqczopyt.supabase.co";
const supabaseKey = Deno.env.get("SERVICE_ROLE_KEY") ?? "";
const supabase = createClient(supabaseUrl, supabaseKey);

interface StockAlertPayload {
  item_id: string;
  item_name: string;
  stock: number;
  min_stock: number;
  unit: string;
}

function buildNotificationBody(item: StockAlertPayload): string {
  const unitStr = item.unit;
  return `${item.item_name} - ${item.stock}${unitStr} left (min: ${item.min_stock}${unitStr})`;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const payload: StockAlertPayload = await req.json();

    // Fetch all FCM tokens from Supabase
    const { data: tokens, error } = await supabase
      .from("fcm_tokens")
      .select("token");

    if (error) {
      console.error("Failed to fetch tokens:", error);
      return new Response("Failed to fetch tokens", { status: 500 });
    }

    if (!tokens || tokens.length === 0) {
      console.log("No FCM tokens registered");
      return new Response("No tokens", { status: 200 });
    }

    const notificationBody = buildNotificationBody(payload);

    // Send FCM multicast message
    const message = {
      notification: {
        title: "Low Stock! \u{1F534}",
        body: notificationBody,
      },
      data: {
        type: "low_stock",
        item_id: payload.item_id,
      },
      android: {
        priority: "high" as const,
        notification: {
          channelId: "stock_alerts",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      tokens: tokens.map((t) => t.token),
    };

    const response = await getMessaging().sendEachForMulticast(message);
    console.log(
      `Sent ${response.successCount} / ${tokens.length} notifications`
    );

    if (response.failureCount > 0) {
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.error(`Token ${idx} failed:`, resp.error);
        }
      });
    }

    return new Response(
      JSON.stringify({
        success: true,
        sent: response.successCount,
        failed: response.failureCount,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (err) {
    console.error("Error sending notifications:", err);
    return new Response(
      JSON.stringify({ success: false, error: String(err) }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
