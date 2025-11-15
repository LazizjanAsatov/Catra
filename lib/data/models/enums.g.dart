// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnitTypeAdapter extends TypeAdapter<UnitType> {
  @override
  final int typeId = 0;

  @override
  UnitType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UnitType.piece;
      case 1:
        return UnitType.gram;
      case 2:
        return UnitType.milliliter;
      default:
        return UnitType.piece;
    }
  }

  @override
  void write(BinaryWriter writer, UnitType obj) {
    switch (obj) {
      case UnitType.piece:
        writer.writeByte(0);
        break;
      case UnitType.gram:
        writer.writeByte(1);
        break;
      case UnitType.milliliter:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GenderAdapter extends TypeAdapter<Gender> {
  @override
  final int typeId = 1;

  @override
  Gender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Gender.male;
      case 1:
        return Gender.female;
      case 2:
        return Gender.other;
      default:
        return Gender.male;
    }
  }

  @override
  void write(BinaryWriter writer, Gender obj) {
    switch (obj) {
      case Gender.male:
        writer.writeByte(0);
        break;
      case Gender.female:
        writer.writeByte(1);
        break;
      case Gender.other:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityLevelAdapter extends TypeAdapter<ActivityLevel> {
  @override
  final int typeId = 2;

  @override
  ActivityLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityLevel.sedentary;
      case 1:
        return ActivityLevel.lightlyActive;
      case 2:
        return ActivityLevel.moderatelyActive;
      case 3:
        return ActivityLevel.veryActive;
      default:
        return ActivityLevel.sedentary;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityLevel obj) {
    switch (obj) {
      case ActivityLevel.sedentary:
        writer.writeByte(0);
        break;
      case ActivityLevel.lightlyActive:
        writer.writeByte(1);
        break;
      case ActivityLevel.moderatelyActive:
        writer.writeByte(2);
        break;
      case ActivityLevel.veryActive:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 3;

  @override
  Goal read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Goal.lose;
      case 1:
        return Goal.maintain;
      case 2:
        return Goal.gain;
      default:
        return Goal.lose;
    }
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    switch (obj) {
      case Goal.lose:
        writer.writeByte(0);
        break;
      case Goal.maintain:
        writer.writeByte(1);
        break;
      case Goal.gain:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
