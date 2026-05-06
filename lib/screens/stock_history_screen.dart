import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../utils/app_colors.dart';

class StockHistoryScreen extends StatelessWidget {
  const StockHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final isStockIn = log.type == 'IN';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                          isStockIn ? Icons.arrow_downward : Icons.arrow_upward,
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
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${log.oldQuantity} → ${log.newQuantity}',
                              style: TextStyle(
                                color: Colors.grey[600],
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
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM dd, yyyy - hh:mm a').format(log.createdAt),
                              style: TextStyle(
                                color: Colors.grey[500],
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
              );
            },
          );
        },
      ),
    );
  }
}
