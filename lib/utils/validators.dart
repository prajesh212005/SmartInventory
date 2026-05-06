class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity cannot be empty';
    }
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Please enter a valid number';
    }
    if (intValue < 0) {
      return 'Quantity cannot be negative';
    }
    return null;
  }

  static String? validateThreshold(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Minimum threshold cannot be empty';
    }
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Please enter a valid number';
    }
    if (intValue < 0) {
      return 'Threshold cannot be negative';
    }
    return null;
  }
}
