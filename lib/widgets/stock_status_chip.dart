import 'package:flutter/material.dart';
import '../utils/stock_status.dart';

class StockStatusChip extends StatelessWidget {
  final StockStatus status;

  const StockStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = StockStatusHelper.getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        StockStatusHelper.getStatusString(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
