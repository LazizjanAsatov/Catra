import 'package:hive/hive.dart';

import 'enums.dart';

part 'consumed_entry.g.dart';

@HiveType(typeId: 5)
class ConsumedEntry extends HiveObject {
  ConsumedEntry({
    required this.id,
    required this.productId,
    required this.dateTime,
    required this.amount,
    required this.unit,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.sugar,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String productId;
  @HiveField(2)
  final DateTime dateTime;
  @HiveField(3)
  final double amount;
  @HiveField(4)
  final UnitType unit;
  @HiveField(5)
  final double calories;
  @HiveField(6)
  final double carbs;
  @HiveField(7)
  final double protein;
  @HiveField(8)
  final double fat;
  @HiveField(9)
  final double sugar;
}
