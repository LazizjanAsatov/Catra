import 'package:hive/hive.dart';

import 'enums.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 6)
class UserSettings extends HiveObject {
  UserSettings({
    required this.dailyCalorieTarget,
    required this.dailySugarLimit,
    required this.useNotifications,
    required this.notificationHour,
    required this.notificationMinute,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activityLevel,
    required this.goal,
  });

  @HiveField(0)
  final double dailyCalorieTarget;
  @HiveField(1)
  final double dailySugarLimit;
  @HiveField(2)
  final bool useNotifications;
  @HiveField(3)
  final int notificationHour;
  @HiveField(4)
  final int notificationMinute;
  @HiveField(5)
  final int age;
  @HiveField(6)
  final double weight;
  @HiveField(7)
  final double height;
  @HiveField(8)
  final Gender gender;
  @HiveField(9)
  final ActivityLevel activityLevel;
  @HiveField(10)
  final Goal goal;

  UserSettings copyWith({
    double? dailyCalorieTarget,
    double? dailySugarLimit,
    bool? useNotifications,
    int? notificationHour,
    int? notificationMinute,
    int? age,
    double? weight,
    double? height,
    Gender? gender,
    ActivityLevel? activityLevel,
    Goal? goal,
  }) {
    return UserSettings(
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      dailySugarLimit: dailySugarLimit ?? this.dailySugarLimit,
      useNotifications: useNotifications ?? this.useNotifications,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
    );
  }
}
