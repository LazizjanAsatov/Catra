import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/product.dart';

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _tzInitialized = false;

  Future<void> init() async {
    if (kIsWeb) return;
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    final settings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );
    await _plugin.initialize(settings);
    if (!_tzInitialized) {
      tz.initializeTimeZones();
      _tzInitialized = true;
    }
    _initialized = true;
  }

  bool get isAvailable => !kIsWeb && _initialized;

  Future<void> scheduleExpiryNotifications(Product product) async {
    if (!isAvailable || product.expiryDate == null) return;
    await cancelProductNotifications(product.id);
    final expiry = product.expiryDate!;
    final reminderDate = expiry.subtract(const Duration(days: 2));
    DateTime reminderDateTime = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
    );
    DateTime expiryMorning = DateTime(expiry.year, expiry.month, expiry.day, 9);
    await _scheduleNotification(
      id: _notificationId(product.id, 0),
      scheduledAt: reminderDateTime,
      title: 'Expiring soon',
      body:
          '${product.name} expires on ${expiry.toLocal().toShortDateString()}',
    );

    await _scheduleNotification(
      id: _notificationId(product.id, 1),
      scheduledAt: expiryMorning,
      title: 'Expiry day',
      body: '${product.name} expires today. Use it soon!',
    );
  }

  Future<void> cancelProductNotifications(String productId) async {
    if (!isAvailable) return;
    await _plugin.cancel(_notificationId(productId, 0));
    await _plugin.cancel(_notificationId(productId, 1));
  }

  Future<void> _scheduleNotification({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    final difference = scheduledAt.difference(now);
    if (difference.isNegative) return;
    final target = tz.TZDateTime.now(tz.local).add(difference);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      target,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'catra_expiry',
          'Product expiry',
          channelDescription: 'Notifications for expiring products',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  int _notificationId(String productId, int offset) =>
      productId.hashCode + offset;
}

extension on DateTime {
  String toShortDateString() =>
      '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}';
}

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);
