import 'package:hive/hive.dart';

part 'stock_log.g.dart';

@HiveType(typeId: 1)
class StockLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final String type; // "IN" or "OUT"

  @HiveField(4)
  final int quantityChanged;

  @HiveField(5)
  final int oldQuantity;

  @HiveField(6)
  final int newQuantity;

  @HiveField(7)
  final String note;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  bool isSynced;

  StockLog({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantityChanged,
    required this.oldQuantity,
    required this.newQuantity,
    this.note = '',
    required this.createdAt,
    this.isSynced = false,
  });
}
