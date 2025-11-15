import 'package:hive/hive.dart';

part 'enums.g.dart';

@HiveType(typeId: 0)
enum UnitType {
  @HiveField(0)
  piece,
  @HiveField(1)
  gram,
  @HiveField(2)
  milliliter,
}

@HiveType(typeId: 1)
enum Gender {
  @HiveField(0)
  male,
  @HiveField(1)
  female,
  @HiveField(2)
  other,
}

@HiveType(typeId: 2)
enum ActivityLevel {
  @HiveField(0)
  sedentary,
  @HiveField(1)
  lightlyActive,
  @HiveField(2)
  moderatelyActive,
  @HiveField(3)
  veryActive,
}

@HiveType(typeId: 3)
enum Goal {
  @HiveField(0)
  lose,
  @HiveField(1)
  maintain,
  @HiveField(2)
  gain,
}
