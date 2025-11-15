import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/nutrition_utils.dart';
import '../../../data/local/hive_streams.dart';
import '../../../data/models/consumed_entry.dart';
import '../../../data/models/product.dart';
import '../../../data/models/user_settings.dart';
import '../../settings/controllers/user_settings_controller.dart';

class HomeStats {
  const HomeStats({
    required this.todayEntries,
    required this.totalCalories,
    required this.totalSugar,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.calorieTarget,
    required this.sugarTarget,
    required this.estimatedBurn,
    required this.netCalories,
    required this.expiringSoon,
  });

  final List<ConsumedEntry> todayEntries;
  final double totalCalories;
  final double totalSugar;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double calorieTarget;
  final double sugarTarget;
  final double estimatedBurn;
  final double netCalories;
  final List<Product> expiringSoon;
}

class HomeStatsController extends AutoDisposeAsyncNotifier<HomeStats> {
  @override
  Future<HomeStats> build() async {
    final settings = await ref.watch(userSettingsControllerProvider.future);
    final consumedAsync = ref.watch(consumedStreamProvider);
    final productsAsync = ref.watch(productsStreamProvider);

    final consumedEntries = consumedAsync.value ?? const <ConsumedEntry>[];
    final products = productsAsync.value ?? const <Product>[];

    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    final todaysEntries =
        consumedEntries
            .where(
              (entry) =>
                  entry.dateTime.isAfter(
                    start.subtract(const Duration(milliseconds: 1)),
                  ) &&
                  entry.dateTime.isBefore(end),
            )
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final totalCalories = todaysEntries.fold<double>(
      0,
      (sum, e) => sum + e.calories,
    );
    final totalSugar = todaysEntries.fold<double>(0, (sum, e) => sum + e.sugar);
    final totalProtein = todaysEntries.fold<double>(
      0,
      (sum, e) => sum + e.protein,
    );
    final totalCarbs = todaysEntries.fold<double>(0, (sum, e) => sum + e.carbs);
    final totalFat = todaysEntries.fold<double>(0, (sum, e) => sum + e.fat);

    final estimatedBurn = settings != null
        ? NutritionUtils.estimateDailyEnergyBurn(
            settings,
            loggedSessions: todaysEntries.length,
          )
        : 1900.0 + (todaysEntries.length * 20);
    final netCalories = totalCalories - estimatedBurn;

    final expiringSoon = products.where((p) => p.expiryDate != null).toList()
      ..sort(
        (a, b) => (a.expiryDate ?? DateTime.now()).compareTo(
          b.expiryDate ?? DateTime.now(),
        ),
      );

    return HomeStats(
      todayEntries: todaysEntries,
      totalCalories: totalCalories,
      totalSugar: totalSugar,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      calorieTarget: _resolveCalorieTarget(settings),
      sugarTarget: settings?.dailySugarLimit ?? 90,
      estimatedBurn: estimatedBurn,
      netCalories: netCalories,
      expiringSoon: expiringSoon.take(3).toList(),
    );
  }
}

double _resolveCalorieTarget(UserSettings? settings) {
  if (settings == null) return 2000;
  if (settings.dailyCalorieTarget > 0) return settings.dailyCalorieTarget;
  return NutritionUtils.recommendedTarget(settings);
}

final homeStatsControllerProvider =
    AutoDisposeAsyncNotifierProvider<HomeStatsController, HomeStats>(
      HomeStatsController.new,
    );
