import 'package:flutter/material.dart';
import '../models/product.dart';
import 'app_colors.dart';

enum StockStatus {
  available,
  low,
  critical,
  outOfStock,
}

class StockStatusHelper {
  static StockStatus getStatus(Product product) {
    if (product.quantity == 0) {
      return StockStatus.outOfStock;
    } else if (product.quantity <= product.minimumThreshold / 2) {
      return StockStatus.critical;
    } else if (product.quantity <= product.minimumThreshold) {
      return StockStatus.low;
    } else {
      return StockStatus.available;
    }
  }

  static Color getStatusColor(StockStatus status) {
    switch (status) {
      case StockStatus.available:
        return AppColors.statusAvailable;
      case StockStatus.low:
        return AppColors.statusLow;
      case StockStatus.critical:
        return AppColors.statusCritical;
      case StockStatus.outOfStock:
        return AppColors.statusOutOfStock;
    }
  }

  static String getStatusString(StockStatus status) {
    switch (status) {
      case StockStatus.available:
        return 'Available';
      case StockStatus.low:
        return 'Low Stock';
      case StockStatus.critical:
        return 'Critical Stock';
      case StockStatus.outOfStock:
        return 'Out of Stock';
    }
  }
}
