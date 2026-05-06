import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/local_storage_service.dart';
import 'providers/inventory_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and Local Storage
  final storageService = LocalStorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryProvider(storageService)),
      ],
      child: const SmartInventoryApp(),
    ),
  );
}
