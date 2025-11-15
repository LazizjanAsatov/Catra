import 'package:hive_flutter/hive_flutter.dart';

import '../models/consumed_entry.dart';
import '../models/enums.dart';
import '../models/product.dart';
import '../models/user_settings.dart';
import 'hive_boxes.dart';

class HiveManager {
  HiveManager._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();

    _registerAdapters();
    await Future.wait([
      Hive.openBox<Product>(HiveBoxes.products),
      Hive.openBox<ConsumedEntry>(HiveBoxes.consumed),
      Hive.openBox<UserSettings>(HiveBoxes.settings),
    ]);
    _initialized = true;
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive
        ..registerAdapter(UnitTypeAdapter())
        ..registerAdapter(GenderAdapter())
        ..registerAdapter(ActivityLevelAdapter())
        ..registerAdapter(GoalAdapter())
        ..registerAdapter(ProductAdapter())
        ..registerAdapter(ConsumedEntryAdapter())
        ..registerAdapter(UserSettingsAdapter());
    }
  }
}
