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
        title: const Text(
          'Overview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<InventoryProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: provider.isOnline 
                          ? AppColors.statusAvailable.withOpacity(0.2) 
                          : AppColors.statusCritical.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: provider.isOnline ? AppColors.statusAvailable : AppColors.statusCritical,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: provider.isOnline ? AppColors.statusAvailable : AppColors.statusCritical,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (provider.isOnline ? AppColors.statusAvailable : AppColors.statusCritical).withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: provider.isOnline ? AppColors.statusAvailable : AppColors.statusCritical,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // Stats Grid - Responsive
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280, // Dynamic columns
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final stats = [
                      {'title': 'Total Products', 'value': '$totalProducts', 'icon': Icons.inventory_2_rounded, 'color': AppColors.primary},
                      {'title': 'Low Stock', 'value': '$lowStock', 'icon': Icons.info_outline_rounded, 'color': AppColors.statusLow},
                      {'title': 'Critical Stock', 'value': '$criticalStock', 'icon': Icons.warning_amber_rounded, 'color': AppColors.statusCritical},
                      {'title': 'Out of Stock', 'value': '$outOfStock', 'icon': Icons.remove_shopping_cart_rounded, 'color': AppColors.statusOutOfStock},
                    ];
                    final stat = stats[index];
                    return DashboardStatCard(
                      title: stat['title'] as String,
                      value: stat['value'] as String,
                      icon: stat['icon'] as IconData,
                      color: stat['color'] as Color,
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Recently Updated Section
                const Text(
                  'Recently Updated',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (recentlyUpdated.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No recent updates', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else
                  ...recentlyUpdated.map((product) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ProductCard(product: product),
                      )),
                
                const SizedBox(height: 80), // Padding for bottom nav on mobile
              ],
            ),
          );
        },
      ),
    );
  }
}
