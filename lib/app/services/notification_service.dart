import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../router/router.dart';

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  String? _coldStartItemId;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    const androidChannel = AndroidNotificationChannel(
      'stock_alerts',
      'Stock Alerts',
      description: 'Alerts when inventory stock is low',
      importance: Importance.high,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _requestPermission();

    final launchDetails =
        await _localNotifications.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails!.notificationResponse?.payload;
      if (payload != null) {
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          if (data['type'] == 'low_stock' && data['item_id'] != null) {
            _coldStartItemId = data['item_id'] as String;
          }
        } catch (_) {}
      }
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);
  }

  String? consumeColdStartItemId() {
    final id = _coldStartItemId;
    _coldStartItemId = null;
    return id;
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      return;
    }
  }

  Future<void> registerToken(
    String userId,
    SupabaseClient client,
  ) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      await client.from('fcm_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': Platform.operatingSystem,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<void> removeToken(
    String userId,
    SupabaseClient client,
  ) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      await client
          .from('fcm_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('token', token);
    } catch (_) {}
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    if (notification != null &&
        data['type'] == 'low_stock' &&
        data['item_id'] != null) {
      _showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: notification.title ?? 'Low Stock!',
        body: notification.body ?? '',
        payloadId: data['item_id'] as String,
      );
    }
  }

  void _handleNotificationOpened(RemoteMessage message) {
    final data = message.data;
    if (data['type'] == 'low_stock' && data['item_id'] != null) {
      _navigateToItem(data['item_id'] as String);
    }
  }

  void _navigateToItem(String itemId) {
    AppRouter.goRouter?.goNamed(
      'inventori',
      queryParameters: {'itemId': itemId},
    );
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payloadId,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'stock_alerts',
          'Stock Alerts',
          channelDescription: 'Low stock inventory alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode({'type': 'low_stock', 'item_id': payloadId}),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (data['type'] == 'low_stock' && data['item_id'] != null) {
        _navigateToItem(data['item_id'] as String);
      }
    } catch (_) {}
  }
}
