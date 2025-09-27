// lib/Services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gift/Services/hive_service.dart';
import 'package:gift/models/hive/notification_model_hive.dart';
import 'package:gift/main.dart' as main; // ✅ للوصول إلى navigatorKey
import 'package:collection/collection.dart';

import '../screens/event_detail_screen.dart';
import '../screens/wish_detail_screen.dart'; // ✅ 👈 أضف هذا السطر

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _localNotifications;

  Future<void> init() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    // 👇 إعدادات Android
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // 👇 إعدادات iOS
    final DarwinInitializationSettings iOSSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 👇 إعدادات الويندوز — حسب الإصدار 19.0.0
    final WindowsInitializationSettings windowsSettings =
    WindowsInitializationSettings(
      appName: 'Giftagon',
      appUserModelId: 'com.example.gift',
      guid: '{d49b0314-ee7a-4626-bf79-97cdb8a991bb}',
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
      windows: windowsSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) async {
        final hiveService = HiveService();
        final notifications = hiveService.getNotifications();

        // ✅ 👇 هنا تم التصحيح: استخدمنا firstWhereOrNull بدلاً من firstWhere مع orElse
        final notification = notifications.firstWhereOrNull(
              (n) => n.id.hashCode == details.id,
        );

        if (notification != null && notification.relatedId != null) {
          await Future.delayed(const Duration(milliseconds: 500));

          if (main.navigatorKey.currentContext != null) {
            switch (notification.type) {
              case "contribution":
              case "like":
              case "comment":
                if (notification.relatedId!.contains("w")) {
                  Navigator.push(
                    main.navigatorKey.currentContext!,
                    MaterialPageRoute(
                      builder: (context) => WishDetailScreen(wishId: notification.relatedId!),
                    ),
                  );
                } else if (notification.relatedId!.contains("e")) {
                  Navigator.push(
                    main.navigatorKey.currentContext!,
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(eventId: notification.relatedId!),
                    ),
                  );
                }
                break;
              case "event":
                Navigator.push(
                  main.navigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(eventId: notification.relatedId!),
                  ),
                );
                break;
            }
          }
        }
      },
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required String type,
    String? targetId,
  }) async {
    final hiveService = HiveService();
    final user = hiveService.getUser();
    if (user?.receiveNotifications != true) return;

    final notification = NotificationH(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user!.id,
      fromUserId: "system",
      fromUserName: "Giftagon",
      type: type,
      title: title,
      message: body,
      relatedId: targetId,
      createdAt: DateTime.now(),
      isRead: false,
    );

    await hiveService.addNotification(notification);

    await _localNotifications.show(
      notification.id.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'giftagon_channel',
          'Giftagon Notifications',
          channelDescription: 'Notifications for gifts and events',
          importance: Importance.max,
          priority: Priority.high,
        ),
        windows: const WindowsNotificationDetails(),
      ),
    );
  }
}