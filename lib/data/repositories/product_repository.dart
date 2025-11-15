import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../local/hive_boxes.dart';
import '../models/product.dart';

class ProductRepository {
  const ProductRepository();

  Box<Product> get _box => Hive.box<Product>(HiveBoxes.products);

  List<Product> watchAll() =>
      _box.values.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  Product? getById(String id) => _box.get(id);

  Product? getByBarcode(String barcode) {
    return _box.values.firstWhereOrNull((p) => p.barcode == barcode);
  }

  Future<void> upsert(Product product) async {
    await _box.put(product.id, product);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  List<Product> inStock() {
    final items = _box.values.where((p) => p.isInStock).toList();
    items.sort((a, b) {
      if (a.expiryDate == null) return 1;
      if (b.expiryDate == null) return -1;
      return a.expiryDate!.compareTo(b.expiryDate!);
    });
    return items;
  }

  List<Product> expiringSoon({int thresholdDays = 5}) {
    final now = DateTime.now();
    final items = _box.values.where((p) {
      if (p.expiryDate == null) return false;
      final diff = p.expiryDate!.difference(now).inDays;
      return diff <= thresholdDays;
    }).toList();
    items.sort((a, b) => (a.expiryDate ?? now).compareTo(b.expiryDate ?? now));
    return items;
  }
}

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => const ProductRepository(),
);
