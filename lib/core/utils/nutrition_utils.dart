import '../../data/models/enums.dart';
import '../../data/models/product.dart';
import '../../data/models/user_settings.dart';

class NutritionUtils {
  static double calculateAmountValue(
    double per100g,
    double amount,
    UnitType unit,
  ) {
    if (unit == UnitType.piece) {
      return per100g * amount;
    }
    return per100g * (amount / 100);
  }

  static Map<String, double> macrosForAmount(Product product, double amount) {
    return {
      'calories': calculateAmountValue(product.calories, amount, product.unit),
      'protein': calculateAmountValue(product.protein, amount, product.unit),
      'carbs': calculateAmountValue(product.carbs, amount, product.unit),
      'fat': calculateAmountValue(product.fat, amount, product.unit),
      'sugar': calculateAmountValue(product.sugar, amount, product.unit),
    };
  }

  static double estimateDailyEnergyBurn(
    UserSettings settings, {
    int loggedSessions = 0,
  }) {
    final maintenance = _maintenanceCalories(settings);
    final activeBonus = _activeBonus(settings.activityLevel, loggedSessions);
    return maintenance + activeBonus;
  }

  static double recommendedTarget(UserSettings settings) {
    final maintenance = _maintenanceCalories(settings);
    return maintenance + _goalAdjustment(settings.goal);
  }

  static double _maintenanceCalories(UserSettings settings) {
    return _basalMetabolicRate(settings) *
        _activityMultiplier(settings.activityLevel);
  }

  static double _basalMetabolicRate(UserSettings settings) {
    final base = 10 * settings.weight + 6.25 * settings.height;
    final ageComponent = 5 * settings.age;
    final genderOffset = switch (settings.gender) {
      Gender.male => 5.0,
      Gender.female => -161.0,
      Gender.other => -78.0,
    };
    return base - ageComponent + genderOffset;
  }

  static double _activityMultiplier(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.35;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.75;
    }
  }

  static double _goalAdjustment(Goal goal) {
    switch (goal) {
      case Goal.lose:
        return -250.0;
      case Goal.maintain:
        return 0.0;
      case Goal.gain:
        return 250.0;
    }
  }

  static double _activeBonus(ActivityLevel level, int loggedSessions) {
    final base = switch (level) {
      ActivityLevel.sedentary => 120.0,
      ActivityLevel.lightlyActive => 180.0,
      ActivityLevel.moderatelyActive => 260.0,
      ActivityLevel.veryActive => 340.0,
    };
    final sessionBoost = (loggedSessions.clamp(0, 6)) * 25.0;
    return base + sessionBoost;
  }
}
