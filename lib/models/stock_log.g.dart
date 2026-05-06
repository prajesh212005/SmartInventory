// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockLogAdapter extends TypeAdapter<StockLog> {
  @override
  final int typeId = 1;

  @override
  StockLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockLog(
      id: fields[0] as String,
      productId: fields[1] as String,
      productName: fields[2] as String,
      type: fields[3] as String,
      quantityChanged: fields[4] as int,
      oldQuantity: fields[5] as int,
      newQuantity: fields[6] as int,
      note: fields[7] as String,
      createdAt: fields[8] as DateTime,
      isSynced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StockLog obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.quantityChanged)
      ..writeByte(5)
      ..write(obj.oldQuantity)
      ..writeByte(6)
      ..write(obj.newQuantity)
      ..writeByte(7)
      ..write(obj.note)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
