import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../local/hive_boxes.dart';
import '../models/consumed_entry.dart';

class ConsumptionRepository {
  const ConsumptionRepository();

  Box<ConsumedEntry> get _box => Hive.box<ConsumedEntry>(HiveBoxes.consumed);

  Future<void> add(ConsumedEntry entry) async {
    await _box.put(entry.id, entry);
  }

  List<ConsumedEntry> byDay(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final entries = _box.values.where(
      (entry) =>
          entry.dateTime.isAfter(
            start.subtract(const Duration(milliseconds: 1)),
          ) &&
          entry.dateTime.isBefore(end),
    );
    final list = entries.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<ConsumedEntry> byRange(DateTime start, DateTime end) {
    final entries = _box.values.where(
      (entry) =>
          entry.dateTime.isAfter(
            start.subtract(const Duration(milliseconds: 1)),
          ) &&
          entry.dateTime.isBefore(end),
    );
    final list = entries.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<ConsumedEntry> all() {
    final list = _box.values.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  Future<void> clear() async {
    await _box.clear();
  }
}

final consumptionRepositoryProvider = Provider<ConsumptionRepository>(
  (ref) => const ConsumptionRepository(),
);
