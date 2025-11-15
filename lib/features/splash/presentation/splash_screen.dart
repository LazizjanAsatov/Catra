import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../data/models/user_settings.dart';
import '../../settings/controllers/user_settings_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;
  ProviderSubscription<AsyncValue<UserSettings?>>? _settingsSub;

  @override
  void initState() {
    super.initState();
    _settingsSub = ref.listenManual(userSettingsControllerProvider, (
      previous,
      next,
    ) {
      if (!mounted || _navigated) return;
      next.whenOrNull(
        data: (settings) {
          _navigated = true;
          if (settings == null) {
            context.goNamed(AppRoutes.onboarding.name);
          } else {
            context.goNamed(AppRoutes.home.name);
          }
        },
        error: (_, stackTrace) {
          _navigated = true;
          context.goNamed(AppRoutes.onboarding.name);
        },
      );
    });
  }

  @override
  void dispose() {
    _settingsSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading CATRA...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
