import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/consumed_entry.dart';
import '../models/product.dart';
import 'hive_boxes.dart';

final productsStreamProvider = StreamProvider<List<Product>>((ref) async* {
  final box = Hive.box<Product>(HiveBoxes.products);
  yield box.values.toList();
  await for (final _ in box.watch()) {
    yield box.values.toList();
  }
});

final consumedStreamProvider = StreamProvider<List<ConsumedEntry>>((
  ref,
) async* {
  final box = Hive.box<ConsumedEntry>(HiveBoxes.consumed);
  yield box.values.toList();
  await for (final _ in box.watch()) {
    yield box.values.toList();
  }
});
