// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumed_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConsumedEntryAdapter extends TypeAdapter<ConsumedEntry> {
  @override
  final int typeId = 5;

  @override
  ConsumedEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConsumedEntry(
      id: fields[0] as String,
      productId: fields[1] as String,
      dateTime: fields[2] as DateTime,
      amount: fields[3] as double,
      unit: fields[4] as UnitType,
      calories: fields[5] as double,
      carbs: fields[6] as double,
      protein: fields[7] as double,
      fat: fields[8] as double,
      sugar: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ConsumedEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.calories)
      ..writeByte(6)
      ..write(obj.carbs)
      ..writeByte(7)
      ..write(obj.protein)
      ..writeByte(8)
      ..write(obj.fat)
      ..writeByte(9)
      ..write(obj.sugar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsumedEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
