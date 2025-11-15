import 'package:hive/hive.dart';

import 'enums.dart';

part 'product.g.dart';

@HiveType(typeId: 4)
class Product extends HiveObject {
  Product({
    required this.id,
    required this.name,
    this.brand,
    this.barcode,
    this.imageFrontPath,
    this.imageBackPath,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
    required this.salt,
    this.expiryDate,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
    required this.isInStock,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? brand;
  @HiveField(3)
  final String? barcode;
  @HiveField(4)
  final String? imageFrontPath;
  @HiveField(5)
  final String? imageBackPath;
  @HiveField(6)
  final double calories;
  @HiveField(7)
  final double protein;
  @HiveField(8)
  final double carbs;
  @HiveField(9)
  final double fat;
  @HiveField(10)
  final double sugar;
  @HiveField(11)
  final double salt;
  @HiveField(12)
  final DateTime? expiryDate;
  @HiveField(13)
  final double quantity;
  @HiveField(14)
  final UnitType unit;
  @HiveField(15)
  final DateTime createdAt;
  @HiveField(16)
  final DateTime updatedAt;
  @HiveField(17)
  final bool isInStock;

  Product copyWith({
    String? id,
    String? name,
    String? brand,
    String? barcode,
    String? imageFrontPath,
    String? imageBackPath,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? sugar,
    double? salt,
    DateTime? expiryDate,
    double? quantity,
    UnitType? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isInStock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      imageFrontPath: imageFrontPath ?? this.imageFrontPath,
      imageBackPath: imageBackPath ?? this.imageBackPath,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      sugar: sugar ?? this.sugar,
      salt: salt ?? this.salt,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isInStock: isInStock ?? this.isInStock,
    );
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    return expiryDate!.isBefore(DateTime(now.year, now.month, now.day + 1));
  }

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    return expiryDate!
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }
}
