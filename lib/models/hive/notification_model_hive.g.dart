// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationHAdapter extends TypeAdapter<NotificationH> {
  @override
  final int typeId = 5;

  @override
  NotificationH read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationH(
      id: fields[0] as String,
      userId: fields[1] as String,
      fromUserId: fields[2] as String,
      fromUserName: fields[3] as String,
      type: fields[4] as String,
      title: fields[5] as String,
      message: fields[6] as String,
      relatedId: fields[7] as String?,
      createdAt: fields[8] as DateTime,
      isRead: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationH obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.fromUserId)
      ..writeByte(3)
      ..write(obj.fromUserName)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.message)
      ..writeByte(7)
      ..write(obj.relatedId)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationHAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
