import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/stock_log.dart';

class LocalStorageService {
  static const String _productsBoxName = 'productsBox';
  static const String _logsBoxName = 'logsBox';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(StockLogAdapter());

    await Hive.openBox<Product>(_productsBoxName);
    await Hive.openBox<StockLog>(_logsBoxName);
  }

  Box<Product> get productsBox => Hive.box<Product>(_productsBoxName);
  Box<StockLog> get logsBox => Hive.box<StockLog>(_logsBoxName);

  // Products CRUD
  List<Product> getProducts() {
    return productsBox.values.toList();
  }

  Future<void> addProduct(Product product) async {
    await productsBox.put(product.id, product);
  }

  Future<void> updateProduct(Product product) async {
    await productsBox.put(product.id, product);
  }

  Future<void> deleteProduct(String id) async {
    await productsBox.delete(id);
  }

  // Stock Logs
  List<StockLog> getStockLogs() {
    return logsBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addStockLog(StockLog log) async {
    await logsBox.put(log.id, log);
  }

  Future<void> clearAllData() async {
    await productsBox.clear();
    await logsBox.clear();
  }
}
