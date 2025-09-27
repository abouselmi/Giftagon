// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wish_model_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WishHAdapter extends TypeAdapter<WishH> {
  @override
  final int typeId = 0;

  @override
  WishH read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WishH(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      imageUrl: fields[3] as String?,
      targetAmount: fields[4] as double,
      currentAmount: fields[5] as double,
      currency: fields[6] as String,
      ownerId: fields[7] as String,
      ownerName: fields[8] as String,
      circle: fields[9] as String,
      isHidden: fields[10] as bool,
      eventId: fields[11] as String?,
      isFulfilled: fields[12] as bool,
      createdAt: fields[13] as DateTime,
      deadline: fields[14] as DateTime?,
      contributors: (fields[15] as List).cast<Contribution>(),
      comments: (fields[16] as List).cast<Comment>(),
    );
  }

  @override
  void write(BinaryWriter writer, WishH obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.targetAmount)
      ..writeByte(5)
      ..write(obj.currentAmount)
      ..writeByte(6)
      ..write(obj.currency)
      ..writeByte(7)
      ..write(obj.ownerId)
      ..writeByte(8)
      ..write(obj.ownerName)
      ..writeByte(9)
      ..write(obj.circle)
      ..writeByte(10)
      ..write(obj.isHidden)
      ..writeByte(11)
      ..write(obj.eventId)
      ..writeByte(12)
      ..write(obj.isFulfilled)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.deadline)
      ..writeByte(15)
      ..write(obj.contributors)
      ..writeByte(16)
      ..write(obj.comments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishHAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
