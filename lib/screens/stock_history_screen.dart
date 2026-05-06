import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/mesh_background.dart';
import '../utils/app_colors.dart';

class StockHistoryScreen extends StatelessWidget {
  const StockHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('Stock History'),
        ),
        body: Consumer<InventoryProvider>(
          builder: (context, provider, child) {
            final logs = provider.logs;

            if (logs.isEmpty) {
              return const EmptyStateWidget(
                title: 'No History',
                message: 'Stock movement history will appear here.',
                icon: Icons.history,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final isStockIn = log.type == 'IN';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isStockIn
                                    ? AppColors.statusAvailable.withOpacity(0.1)
                                    : AppColors.statusCritical.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isStockIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                color: isStockIn ? AppColors.statusAvailable : AppColors.statusCritical,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.productName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${log.oldQuantity} → ${log.newQuantity}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (log.note.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      log.note,
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('MMM dd, yyyy - hh:mm a').format(log.createdAt),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isStockIn ? '+' : '-'}${log.quantityChanged}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isStockIn ? AppColors.statusAvailable : AppColors.statusCritical,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
