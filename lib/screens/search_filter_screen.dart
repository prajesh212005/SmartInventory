import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/inventory_provider.dart';
import '../utils/stock_status.dart';
import '../widgets/product_card.dart';
import '../widgets/mesh_background.dart';
import '../utils/app_colors.dart';

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

    return MeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('Search & Filter'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => _applyFilters(),
                    decoration: InputDecoration(
                      hintText: 'Search products by name...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Category Filter
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory ?? 'All',
                              isExpanded: true,
                              dropdownColor: AppColors.surface,
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
                      ),
                      const SizedBox(width: 12),
                      // Status Filter
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<StockStatus?>(
                              value: _selectedStatus,
                              isExpanded: true,
                              dropdownColor: AppColors.surface,
                              hint: const Text('All Status'),
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredProducts.isEmpty
                  ? const Center(child: Text('No products match your search.', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: _filteredProducts[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
