import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/user_settings.dart';
import '../../settings/controllers/user_settings_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _step = 0;

  Gender _gender = Gender.male;
  ActivityLevel _activityLevel = ActivityLevel.sedentary;
  Goal _goal = Goal.maintain;
  int _age = 25;
  double _weight = 70;
  double _height = 175;
  double _calorieTarget = 2200;
  double _sugarLimit = 90;

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      if (_step == 2) {
        _calculateTargets();
      }
    } else {
      _save();
    }
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _calculateTargets() {
    final bmr = _gender == Gender.male
        ? 10 * _weight + 6.25 * _height - 5 * _age + 5
        : 10 * _weight + 6.25 * _height - 5 * _age - 161;
    final activityMultiplier = switch (_activityLevel) {
      ActivityLevel.sedentary => 1.2,
      ActivityLevel.lightlyActive => 1.375,
      ActivityLevel.moderatelyActive => 1.55,
      ActivityLevel.veryActive => 1.725,
    };
    var calories = bmr * activityMultiplier;
    calories += switch (_goal) {
      Goal.lose => -300,
      Goal.maintain => 0,
      Goal.gain => 300,
    };
    setState(() {
      _calorieTarget = calories.clamp(1500, 3500);
      _sugarLimit = (_calorieTarget * 0.1 / 4).clamp(50, 120);
    });
  }

  Future<void> _save() async {
    final notifier = ref.read(userSettingsControllerProvider.notifier);
    final settings = UserSettings(
      dailyCalorieTarget: _calorieTarget,
      dailySugarLimit: _sugarLimit,
      useNotifications: true,
      notificationHour: 9,
      notificationMinute: 0,
      age: _age,
      weight: _weight,
      height: _height,
      gender: _gender,
      activityLevel: _activityLevel,
      goal: _goal,
    );
    await notifier.save(settings);
    if (mounted) {
      context.goNamed(AppRoutes.home.name);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to CATRA'),
        leading: _step == 0
            ? null
            : IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_step + 1) / 3),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildProfileStep(),
                _buildLifestyleStep(),
                _buildTargetsStep(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _next,
              child: Text(_step == 2 ? 'Finish' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(title: 'Profile'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: Gender.values
                .map(
                  (g) => ChoiceChip(
                    label: Text(g.name),
                    selected: _gender == g,
                    onSelected: (_) => setState(() => _gender = g),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          _NumberField(
            label: 'Age',
            value: _age.toDouble(),
            min: 10,
            max: 90,
            onChanged: (value) => setState(() => _age = value.toInt()),
          ),
          _NumberField(
            label: 'Weight (kg)',
            value: _weight,
            min: 30,
            max: 200,
            onChanged: (value) => setState(() => _weight = value),
          ),
          _NumberField(
            label: 'Height (cm)',
            value: _height,
            min: 120,
            max: 220,
            onChanged: (value) => setState(() => _height = value),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(title: 'Lifestyle'),
          const SizedBox(height: 16),
          Text(
            'Activity level',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButton<ActivityLevel>(
            value: _activityLevel,
            isExpanded: true,
            items: ActivityLevel.values
                .map(
                  (level) =>
                      DropdownMenuItem(value: level, child: Text(level.name)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _activityLevel = value);
              }
            },
          ),
          const SizedBox(height: 16),
          Text('Goal', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButton<Goal>(
            value: _goal,
            isExpanded: true,
            items: Goal.values
                .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _goal = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTargetsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(title: 'Daily targets'),
          const SizedBox(height: 16),
          Text('Calories (${_calorieTarget.toStringAsFixed(0)})'),
          Slider(
            value: _calorieTarget,
            min: 1200,
            max: 4000,
            divisions: 28,
            onChanged: (value) => setState(() => _calorieTarget = value),
          ),
          Text('Sugar (${_sugarLimit.toStringAsFixed(0)} g)'),
          Slider(
            value: _sugarLimit,
            min: 30,
            max: 150,
            divisions: 24,
            onChanged: (value) => setState(() => _sugarLimit = value),
          ),
          const SizedBox(height: 24),
          Text(
            'You can adjust these targets anytime in Settings.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(0)}'),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: (max - min).round(),
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
