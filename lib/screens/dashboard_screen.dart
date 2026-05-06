import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/product_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/mesh_background.dart';
import '../utils/app_colors.dart';

import '../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Text('Logout', style: TextStyle(color: Colors.white)),
                  content: const Text('Are you sure you want to log out?', style: TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthService>().logout();
                        Navigator.pop(context);
                      },
                      child: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 600;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 4 : 2,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          mainAxisExtent: 136,
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
      ),
    );
  }
}
