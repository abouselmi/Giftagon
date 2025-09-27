// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventHAdapter extends TypeAdapter<EventH> {
  @override
  final int typeId = 1;

  @override
  EventH read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventH(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      organizerId: fields[3] as String,
      organizerName: fields[4] as String,
      targetAmount: fields[5] as double,
      currentAmount: fields[6] as double,
      currency: fields[7] as String,
      wishId: fields[8] as String?,
      contributors: (fields[9] as List).cast<Contribution>(),
      isHidden: fields[10] as bool,
      createdAt: fields[11] as DateTime,
      deadline: fields[12] as DateTime?,
      imageUrl: fields[13] as String?,
      comments: (fields[14] as List).cast<Comment>(),
    );
  }

  @override
  void write(BinaryWriter writer, EventH obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.organizerId)
      ..writeByte(4)
      ..write(obj.organizerName)
      ..writeByte(5)
      ..write(obj.targetAmount)
      ..writeByte(6)
      ..write(obj.currentAmount)
      ..writeByte(7)
      ..write(obj.currency)
      ..writeByte(8)
      ..write(obj.wishId)
      ..writeByte(9)
      ..write(obj.contributors)
      ..writeByte(10)
      ..write(obj.isHidden)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.deadline)
      ..writeByte(13)
      ..write(obj.imageUrl)
      ..writeByte(14)
      ..write(obj.comments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventHAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
