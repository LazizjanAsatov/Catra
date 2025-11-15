import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'data/local/hive_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveManager.init();

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const CatraApp(),
    ),
  );
}
