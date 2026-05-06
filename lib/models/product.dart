import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  int minimumThreshold;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  bool isSynced;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minimumThreshold,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    int? minimumThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      minimumThreshold: minimumThreshold ?? this.minimumThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
