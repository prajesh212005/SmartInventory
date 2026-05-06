import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/product_card.dart';
import '../widgets/empty_state_widget.dart';
import '../utils/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Smart Inventory'),
        actions: [
          Consumer<InventoryProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: provider.isOnline ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      provider.isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          final totalProducts = provider.products.length;
          final lowStock = provider.getLowStockProducts().length;
          final criticalStock = provider.getCriticalStockProducts().length;
          final outOfStock = provider.getOutOfStockProducts().length;
          final recentlyUpdated = provider.getRecentlyUpdatedProducts();

          if (totalProducts == 0) {
            return const EmptyStateWidget(
              title: 'Welcome to Smart Inventory',
              message: 'Get started by adding your first product.',
              icon: Icons.inventory_2_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Stats Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    DashboardStatCard(
                      title: 'Total Products',
                      value: '$totalProducts',
                      icon: Icons.inventory,
                      color: AppColors.primary,
                    ),
                    DashboardStatCard(
                      title: 'Out of Stock',
                      value: '$outOfStock',
                      icon: Icons.error_outline,
                      color: AppColors.statusOutOfStock,
                    ),
                    DashboardStatCard(
                      title: 'Critical Stock',
                      value: '$criticalStock',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.statusCritical,
                    ),
                    DashboardStatCard(
                      title: 'Low Stock',
                      value: '$lowStock',
                      icon: Icons.info_outline,
                      color: AppColors.statusLow,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Recently Updated Section
                const Text(
                  'Recently Updated',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                ...recentlyUpdated.map((product) => ProductCard(product: product)),
                
                const SizedBox(height: 80), // Padding for bottom nav
              ],
            ),
          );
        },
      ),
    );
  }
}
