import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/inventory_provider.dart';
import '../utils/stock_status.dart';
import '../widgets/product_card.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  StockStatus? _selectedStatus;
  
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    
    // First search by query
    List<Product> results = provider.searchProducts(_searchController.text);
    
    // Then apply filters
    results = results.where((p) {
      bool categoryMatch = _selectedCategory == null || _selectedCategory == 'All' || p.category == _selectedCategory;
      bool statusMatch = _selectedStatus == null || StockStatusHelper.getStatus(p) == _selectedStatus;
      return categoryMatch && statusMatch;
    }).toList();

    setState(() {
      _filteredProducts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final categories = provider.getCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products by name...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    ),
                  ),
                  onChanged: (_) => _applyFilters(),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Category Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory ?? 'All',
                            hint: const Text('Category'),
                            items: categories.map((c) {
                              return DropdownMenuItem(value: c, child: Text(c));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                              _applyFilters();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Status Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<StockStatus?>(
                            value: _selectedStatus,
                            hint: const Text('Stock Status'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Status')),
                              ...StockStatus.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(StockStatusHelper.getStatusString(s)),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value;
                              });
                              _applyFilters();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text('No products match your search/filters.'))
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: _filteredProducts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
