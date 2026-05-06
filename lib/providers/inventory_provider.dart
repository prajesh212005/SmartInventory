import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

import '../models/product.dart';
import '../models/stock_log.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../utils/stock_status.dart';

class InventoryProvider with ChangeNotifier {
  final LocalStorageService _storageService;
  late final SyncService _syncService;

  List<Product> _products = [];
  List<StockLog> _logs = [];
  bool _isOnline = true;
  final Uuid _uuid = const Uuid();

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  InventoryProvider(this._storageService) {
    _syncService = SyncService(_storageService);
    _init();
  }

  List<Product> get products => _products;
  List<StockLog> get logs => _logs;
  bool get isOnline => _isOnline;

  Future<void> _init() async {
    await loadData();
    
    // Check initial connectivity
    final connectivityResult = await (Connectivity().checkConnectivity());
    _updateConnectionStatus(connectivityResult);

    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool previousStatus = _isOnline;
    _isOnline = results.any((result) => result != ConnectivityResult.none);
    
    if (_isOnline && !previousStatus) {
      syncData();
    }
    notifyListeners();
  }

  Future<void> loadData() async {
    _products = _storageService.getProducts();
    _logs = _storageService.getStockLogs();

    if (_products.isEmpty) {
      _addDemoData();
    }
    notifyListeners();
  }

  void _addDemoData() {
    final demoProducts = [
      Product(
        id: _uuid.v4(),
        name: 'Notebook',
        category: 'Stationery',
        quantity: 40,
        minimumThreshold: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Printer Paper',
        category: 'Office Supplies',
        quantity: 5,
        minimumThreshold: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Lab Gloves',
        category: 'Lab Equipment',
        quantity: 2,
        minimumThreshold: 8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(),
        name: 'Markers',
        category: 'Classroom',
        quantity: 0,
        minimumThreshold: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var product in demoProducts) {
      _storageService.addProduct(product);
    }
    _products = _storageService.getProducts();
  }

  // --- Product Operations ---
  Future<void> addProduct(String name, String category, int quantity, int threshold) async {
    final newProduct = Product(
      id: _uuid.v4(),
      name: name,
      category: category,
      quantity: quantity,
      minimumThreshold: threshold,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: _isOnline,
    );

    await _storageService.addProduct(newProduct);
    await loadData();
    if (_isOnline) syncData();
  }

  Future<void> updateProduct(Product product) async {
    final updatedProduct = product.copyWith(
      updatedAt: DateTime.now(),
      isSynced: _isOnline,
    );
    await _storageService.updateProduct(updatedProduct);
    await loadData();
    if (_isOnline) syncData();
  }

  Future<void> deleteProduct(String id) async {
    await _storageService.deleteProduct(id);
    await loadData();
  }

  // --- Stock Operations ---
  Future<void> addStockIn(Product product, int quantityToAdd, String note) async {
    final oldQuantity = product.quantity;
    final newQuantity = oldQuantity + quantityToAdd;

    final log = StockLog(
      id: _uuid.v4(),
      productId: product.id,
      productName: product.name,
      type: 'IN',
      quantityChanged: quantityToAdd,
      oldQuantity: oldQuantity,
      newQuantity: newQuantity,
      note: note,
      createdAt: DateTime.now(),
      isSynced: _isOnline,
    );

    await _storageService.addStockLog(log);
    
    final updatedProduct = product.copyWith(
      quantity: newQuantity,
      updatedAt: DateTime.now(),
      isSynced: _isOnline,
    );
    await _storageService.updateProduct(updatedProduct);

    await loadData();
    if (_isOnline) syncData();
  }

  Future<void> addStockOut(Product product, int quantityToRemove, String note) async {
    if (product.quantity < quantityToRemove) {
      throw Exception('Not enough stock available');
    }

    final oldQuantity = product.quantity;
    final newQuantity = oldQuantity - quantityToRemove;

    final log = StockLog(
      id: _uuid.v4(),
      productId: product.id,
      productName: product.name,
      type: 'OUT',
      quantityChanged: quantityToRemove,
      oldQuantity: oldQuantity,
      newQuantity: newQuantity,
      note: note,
      createdAt: DateTime.now(),
      isSynced: _isOnline,
    );

    await _storageService.addStockLog(log);
    
    final updatedProduct = product.copyWith(
      quantity: newQuantity,
      updatedAt: DateTime.now(),
      isSynced: _isOnline,
    );
    await _storageService.updateProduct(updatedProduct);

    await loadData();
    if (_isOnline) syncData();
  }

  // --- Dashboard Data Getters ---
  List<Product> getLowStockProducts() {
    return _products.where((p) => StockStatusHelper.getStatus(p) == StockStatus.low).toList();
  }

  List<Product> getCriticalStockProducts() {
    return _products.where((p) => StockStatusHelper.getStatus(p) == StockStatus.critical).toList();
  }

  List<Product> getOutOfStockProducts() {
    return _products.where((p) => StockStatusHelper.getStatus(p) == StockStatus.outOfStock).toList();
  }

  List<Product> getRecentlyUpdatedProducts() {
    final sorted = List<Product>.from(_products)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(5).toList();
  }

  // --- Search & Filter ---
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    return _products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  List<Product> filterProducts({String? category, StockStatus? status}) {
    return _products.where((p) {
      bool matchesCategory = category == null || category == 'All' || p.category == category;
      bool matchesStatus = status == null || StockStatusHelper.getStatus(p) == status;
      return matchesCategory && matchesStatus;
    }).toList();
  }

  List<String> getCategories() {
    final categories = _products.map((p) => p.category).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }

  // --- Sync ---
  Future<void> syncData() async {
    await _syncService.syncPendingChanges();
    await loadData();
  }

  Future<void> clearLogs() async {
    await _storageService.clearStockLogs();
    await loadData();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
