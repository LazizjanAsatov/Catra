import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_controller.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/consumption_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../settings/controllers/user_settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _calorieController = TextEditingController();
  final _sugarController = TextEditingController();

  @override
  void dispose() {
    _calorieController.dispose();
    _sugarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(userSettingsControllerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return settingsAsync.when(
      data: (settings) {
        if (settings == null) {
          return const Center(child: Text('Please complete onboarding first.'));
        }
        final calorieText = settings.dailyCalorieTarget.toStringAsFixed(0);
        final sugarText = settings.dailySugarLimit.toStringAsFixed(0);
        if (_calorieController.text != calorieText) {
          _calorieController.text = calorieText;
        }
        if (_sugarController.text != sugarText) {
          _sugarController.text = sugarText;
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Daily targets',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _calorieController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Calories'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sugarController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Sugar (g)'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  final calories = double.tryParse(_calorieController.text);
                  final sugar = double.tryParse(_sugarController.text);
                  if (calories == null || sugar == null) return;
                  ref
                      .read(userSettingsControllerProvider.notifier)
                      .save(
                        settings.copyWith(
                          dailyCalorieTarget: calories,
                          dailySugarLimit: sugar,
                        ),
                      );
                },
                child: const Text('Save targets'),
              ),
              const Divider(height: 32),
              SwitchListTile(
                value: settings.useNotifications,
                title: const Text('Notifications'),
                subtitle: const Text('Receive expiry reminders'),
                onChanged: (value) {
                  ref
                      .read(userSettingsControllerProvider.notifier)
                      .save(settings.copyWith(useNotifications: value));
                },
              ),
              ListTile(
                title: const Text('Notification time'),
                subtitle: Text(
                  '${settings.notificationHour.toString().padLeft(2, '0')}:${settings.notificationMinute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.schedule),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: settings.notificationHour,
                      minute: settings.notificationMinute,
                    ),
                  );
                  if (picked != null) {
                    ref
                        .read(userSettingsControllerProvider.notifier)
                        .save(
                          settings.copyWith(
                            notificationHour: picked.hour,
                            notificationMinute: picked.minute,
                          ),
                        );
                  }
                },
              ),
              const Divider(height: 32),
              Text('Profile', style: Theme.of(context).textTheme.titleLarge),
              Wrap(
                spacing: 8,
                children: Gender.values
                    .map(
                      (g) => ChoiceChip(
                        label: Text(g.name),
                        selected: settings.gender == g,
                        onSelected: (_) => ref
                            .read(userSettingsControllerProvider.notifier)
                            .save(settings.copyWith(gender: g)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              DropdownButton<ActivityLevel>(
                value: settings.activityLevel,
                items: ActivityLevel.values
                    .map(
                      (level) => DropdownMenuItem(
                        value: level,
                        child: Text(level.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(userSettingsControllerProvider.notifier)
                        .save(settings.copyWith(activityLevel: value));
                  }
                },
              ),
              DropdownButton<Goal>(
                value: settings.goal,
                items: Goal.values
                    .map(
                      (goal) =>
                          DropdownMenuItem(value: goal, child: Text(goal.name)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(userSettingsControllerProvider.notifier)
                        .save(settings.copyWith(goal: value));
                  }
                },
              ),
              const Divider(height: 32),
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(themeMode.name),
                trailing: DropdownButton<ThemeMode>(
                  value: themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeModeProvider.notifier).state = value;
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear all data'),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear data'),
                      content: const Text(
                        'This will remove all products and history.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(productRepositoryProvider).clear();
                    await ref.read(consumptionRepositoryProvider).clear();
                    await ref
                        .read(userSettingsControllerProvider.notifier)
                        .clear();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data cleared')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}
