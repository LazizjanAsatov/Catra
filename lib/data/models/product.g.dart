// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 4;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      brand: fields[2] as String?,
      barcode: fields[3] as String?,
      imageFrontPath: fields[4] as String?,
      imageBackPath: fields[5] as String?,
      calories: fields[6] as double,
      protein: fields[7] as double,
      carbs: fields[8] as double,
      fat: fields[9] as double,
      sugar: fields[10] as double,
      salt: fields[11] as double,
      expiryDate: fields[12] as DateTime?,
      quantity: fields[13] as double,
      unit: fields[14] as UnitType,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
      isInStock: fields[17] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.brand)
      ..writeByte(3)
      ..write(obj.barcode)
      ..writeByte(4)
      ..write(obj.imageFrontPath)
      ..writeByte(5)
      ..write(obj.imageBackPath)
      ..writeByte(6)
      ..write(obj.calories)
      ..writeByte(7)
      ..write(obj.protein)
      ..writeByte(8)
      ..write(obj.carbs)
      ..writeByte(9)
      ..write(obj.fat)
      ..writeByte(10)
      ..write(obj.sugar)
      ..writeByte(11)
      ..write(obj.salt)
      ..writeByte(12)
      ..write(obj.expiryDate)
      ..writeByte(13)
      ..write(obj.quantity)
      ..writeByte(14)
      ..write(obj.unit)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.isInStock);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
