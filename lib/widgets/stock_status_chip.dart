import 'package:flutter/material.dart';
import '../utils/stock_status.dart';

class StockStatusChip extends StatelessWidget {
  final StockStatus status;

  const StockStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: StockStatusHelper.getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: StockStatusHelper.getStatusColor(status).withOpacity(0.5),
        ),
      ),
      child: Text(
        StockStatusHelper.getStatusString(status),
        style: TextStyle(
          color: StockStatusHelper.getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
