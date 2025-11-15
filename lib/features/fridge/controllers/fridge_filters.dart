import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FridgeSort { expiry, name, calories }

final fridgeSortProvider = StateProvider<FridgeSort>(
  (ref) => FridgeSort.expiry,
);
