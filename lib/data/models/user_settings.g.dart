// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 6;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      dailyCalorieTarget: fields[0] as double,
      dailySugarLimit: fields[1] as double,
      useNotifications: fields[2] as bool,
      notificationHour: fields[3] as int,
      notificationMinute: fields[4] as int,
      age: fields[5] as int,
      weight: fields[6] as double,
      height: fields[7] as double,
      gender: fields[8] as Gender,
      activityLevel: fields[9] as ActivityLevel,
      goal: fields[10] as Goal,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.dailyCalorieTarget)
      ..writeByte(1)
      ..write(obj.dailySugarLimit)
      ..writeByte(2)
      ..write(obj.useNotifications)
      ..writeByte(3)
      ..write(obj.notificationHour)
      ..writeByte(4)
      ..write(obj.notificationMinute)
      ..writeByte(5)
      ..write(obj.age)
      ..writeByte(6)
      ..write(obj.weight)
      ..writeByte(7)
      ..write(obj.height)
      ..writeByte(8)
      ..write(obj.gender)
      ..writeByte(9)
      ..write(obj.activityLevel)
      ..writeByte(10)
      ..write(obj.goal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
