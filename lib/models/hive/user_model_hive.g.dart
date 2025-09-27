// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserHAdapter extends TypeAdapter<UserH> {
  @override
  final int typeId = 2;

  @override
  UserH read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserH(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      age: fields[3] as int,
      country: fields[4] as String,
      isPublic: fields[5] as bool,
      receiveNotifications: fields[6] as bool,
      avatarUrl: fields[7] as String?,
      isAdmin: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserH obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.country)
      ..writeByte(5)
      ..write(obj.isPublic)
      ..writeByte(6)
      ..write(obj.receiveNotifications)
      ..writeByte(7)
      ..write(obj.avatarUrl)
      ..writeByte(8)
      ..write(obj.isAdmin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserHAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
