import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../models/product.dart';

class NutritionApiService {
  Future<Product?> fetchByBarcode(String barcode) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (barcode.isEmpty) return null;
    if (barcode.endsWith('0')) return null;
    final now = DateTime.now();
    final randomCalories = 50 + Random().nextInt(300);
    return Product(
      id: barcode,
      name: 'Sample Item $barcode',
      brand: 'Mock Foods',
      barcode: barcode,
      imageFrontPath: null,
      imageBackPath: null,
      calories: randomCalories.toDouble(),
      protein: 5,
      carbs: 20,
      fat: 4,
      sugar: 10,
      salt: 0.4,
      expiryDate: now.add(const Duration(days: 7)),
      quantity: 1,
      unit: UnitType.piece,
      createdAt: now,
      updatedAt: now,
      isInStock: false,
    );
  }
}

final nutritionApiServiceProvider = Provider<NutritionApiService>(
  (ref) => NutritionApiService(),
);
