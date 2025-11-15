import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/user_settings.dart';
import '../../../data/repositories/user_settings_repository.dart';

class UserSettingsController extends AsyncNotifier<UserSettings?> {
  @override
  Future<UserSettings?> build() async {
    final repo = ref.read(userSettingsRepositoryProvider);
    return repo.settings;
  }

  Future<void> save(UserSettings settings) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(userSettingsRepositoryProvider).save(settings);
      return settings;
    });
  }

  Future<void> clear() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(userSettingsRepositoryProvider).clear();
      return null;
    });
  }
}

final userSettingsControllerProvider =
    AsyncNotifierProvider<UserSettingsController, UserSettings?>(
      UserSettingsController.new,
    );
