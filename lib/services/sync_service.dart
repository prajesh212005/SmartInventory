import '../models/product.dart';
import '../models/stock_log.dart';
import 'local_storage_service.dart';

class SyncService {
  final LocalStorageService _storageService;

  SyncService(this._storageService);

  // Mocks backend synchronization
  Future<void> syncPendingChanges() async {
    // 1. Get all unsynced products
    final products = _storageService.getProducts();
    final unsyncedProducts = products.where((p) => !p.isSynced).toList();

    // 2. Get all unsynced logs
    final logs = _storageService.getStockLogs();
    final unsyncedLogs = logs.where((l) => !l.isSynced).toList();

    if (unsyncedProducts.isEmpty && unsyncedLogs.isEmpty) {
      return; // Nothing to sync
    }

    // 3. Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // 4. Mark as synced and save locally
    for (var product in unsyncedProducts) {
      product.isSynced = true;
      await _storageService.updateProduct(product);
    }

    for (var log in unsyncedLogs) {
      log.isSynced = true;
      await _storageService.addStockLog(log); // Since Hive puts by ID, this acts as update
    }

    print('Synced ${unsyncedProducts.length} products and ${unsyncedLogs.length} logs to cloud.');
  }
}
