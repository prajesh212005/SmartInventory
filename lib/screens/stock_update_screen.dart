import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/inventory_provider.dart';
import '../utils/validators.dart';
import '../utils/app_colors.dart';

class StockUpdateScreen extends StatefulWidget {
  const StockUpdateScreen({super.key});

  @override
  State<StockUpdateScreen> createState() => _StockUpdateScreenState();
}

class _StockUpdateScreenState extends State<StockUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedProductId;
  String _updateType = 'IN'; // 'IN' or 'OUT'
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProductId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product')),
        );
        return;
      }

      final quantity = int.parse(_quantityController.text.trim());
      final note = _noteController.text.trim();
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      
      final product = provider.products.firstWhere((p) => p.id == _selectedProductId);

      try {
        if (_updateType == 'IN') {
          await provider.addStockIn(product, quantity, note);
        } else {
          await provider.addStockOut(product, quantity, note);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock updated successfully!')),
          );
          
          if (_updateType == 'OUT') {
            final newQuantity = product.quantity - quantity;
            final productName = product.name;
            final threshold = product.minimumThreshold;

            if (newQuantity <= threshold) {
               showDialog(
                 context: context,
                 builder: (context) => AlertDialog(
                   backgroundColor: AppColors.surface,
                   title: Row(
                     children: const [
                       Icon(Icons.warning_amber_rounded, color: AppColors.statusLow),
                       SizedBox(width: 8),
                       Text('Low Stock Warning', style: TextStyle(color: AppColors.textPrimary)),
                     ],
                   ),
                   content: Text(
                     'The stock for $productName is now $newQuantity, which is at or below the minimum threshold of $threshold. Please consider restocking soon.',
                     style: const TextStyle(color: AppColors.textSecondary),
                   ),
                   actions: [
                     TextButton(
                       onPressed: () => Navigator.pop(context),
                       child: const Text('OK', style: TextStyle(color: AppColors.primary)),
                     ),
                   ],
                 ),
               );
            }
          }

          // Reset form
          setState(() {
            _selectedProductId = null;
            _quantityController.clear();
            _noteController.clear();
            _updateType = 'IN';
          });
        }
      } catch (e) {
        if (mounted) {
          final errorMsg = e.toString().replaceAll('Exception: ', '');
          if (errorMsg.contains('Not enough stock available')) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: Row(
                  children: const [
                    Icon(Icons.error_outline, color: AppColors.statusCritical),
                    SizedBox(width: 8),
                    Text('Stock Out Failed', style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
                content: const Text(
                  'There is not enough stock available to perform this operation. The resulting stock cannot be negative.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMsg)),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Stock'),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          final products = provider.products;

          if (products.isEmpty) {
            return const Center(
              child: Text('Add products before updating stock.'),
            );
          }

          // Ensure selected ID still exists in products, otherwise reset it
          if (_selectedProductId != null && !products.any((p) => p.id == _selectedProductId)) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               if (mounted) setState(() => _selectedProductId = null);
             });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedProductId,
                    decoration: const InputDecoration(
                      labelText: 'Select Product',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory_2),
                    ),
                    items: products.map((product) {
                      return DropdownMenuItem<String>(
                        value: product.id,
                        child: Text('${product.name} (Available: ${product.quantity})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProductId = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a product' : null,
                  ),
                  const SizedBox(height: 24),
                  
                  // Update Type Selector
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _updateType = 'IN'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _updateType == 'IN' ? AppColors.statusAvailable.withOpacity(0.2) : Colors.transparent,
                              border: Border.all(
                                color: _updateType == 'IN' ? AppColors.statusAvailable : Colors.grey,
                                width: _updateType == 'IN' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.arrow_downward, color: _updateType == 'IN' ? AppColors.statusAvailable : Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  'Stock In',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _updateType == 'IN' ? AppColors.statusAvailable : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _updateType = 'OUT'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _updateType == 'OUT' ? AppColors.statusCritical.withOpacity(0.2) : Colors.transparent,
                              border: Border.all(
                                color: _updateType == 'OUT' ? AppColors.statusCritical : Colors.grey,
                                width: _updateType == 'OUT' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.arrow_upward, color: _updateType == 'OUT' ? AppColors.statusCritical : Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  'Stock Out',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _updateType == 'OUT' ? AppColors.statusCritical : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.validateQuantity,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _updateType == 'IN' ? AppColors.statusAvailable : AppColors.statusCritical,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm Stock Update',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
