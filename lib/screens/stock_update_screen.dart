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
  
  Product? _selectedProduct;
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
      if (_selectedProduct == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product')),
        );
        return;
      }

      final quantity = int.parse(_quantityController.text.trim());
      final note = _noteController.text.trim();
      final provider = Provider.of<InventoryProvider>(context, listen: false);

      try {
        if (_updateType == 'IN') {
          await provider.addStockIn(_selectedProduct!, quantity, note);
        } else {
          await provider.addStockOut(_selectedProduct!, quantity, note);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock updated successfully!')),
          );
          // Reset form
          setState(() {
            _selectedProduct = null;
            _quantityController.clear();
            _noteController.clear();
            _updateType = 'IN';
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<Product>(
                    value: _selectedProduct,
                    decoration: const InputDecoration(
                      labelText: 'Select Product',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory_2),
                    ),
                    items: products.map((product) {
                      return DropdownMenuItem(
                        value: product,
                        child: Text('${product.name} (Available: ${product.quantity})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProduct = value;
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
