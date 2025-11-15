import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../local/hive_boxes.dart';
import '../models/user_settings.dart';

class UserSettingsRepository {
  const UserSettingsRepository();

  Box<UserSettings> get _box => Hive.box<UserSettings>(HiveBoxes.settings);

  UserSettings? get settings => _box.get('settings');

  Future<void> save(UserSettings settings) async {
    await _box.put('settings', settings);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}

final userSettingsRepositoryProvider = Provider<UserSettingsRepository>(
  (ref) => const UserSettingsRepository(),
);
