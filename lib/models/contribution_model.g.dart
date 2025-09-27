// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContributionAdapter extends TypeAdapter<Contribution> {
  @override
  final int typeId = 4;

  @override
  Contribution read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contribution(
      contributorId: fields[0] as String,
      contributorName: fields[1] as String,
      amount: fields[2] as double,
      contributedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Contribution obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.contributorId)
      ..writeByte(1)
      ..write(obj.contributorName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.contributedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContributionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
