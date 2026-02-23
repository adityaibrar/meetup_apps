import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/api_service.dart';
import '../../../../features/user/data/datasources/region_remote_datasource.dart';
import '../../../../features/user/domain/entities/region.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/product_card.dart';
import 'add_product_screen.dart';

/// Screen Marketplace dengan category pills, search, dan filter lokasi.
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final ApiService _apiService = ApiService();
  final RegionService _regionService = RegionService();

  List<dynamic> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _selectedCategory;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  // Region filter
  List<Region> _provinces = [];
  List<Region> _cities = [];
  Region? _filterProvince;
  Region? _filterCity;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;
    setState(() => _isLoading = true);
    try {
      _categories = await _apiService.getCategories();
      _provinces = await _regionService.getProvinces();
      await _fetchProducts(token);
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchProducts(String token) async {
    try {
      _products = await _apiService.getProducts(
        token,
        category: _selectedCategory,
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        province: _filterProvince?.name,
        city: _filterCity?.name,
      );
      if (mounted) setState(() {});
    } catch (_) {}
  }

  void _onSearch() {
    _searchQuery = _searchController.text.trim();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) _fetchProducts(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marketplace', style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune, size: 20),
            ),
            onPressed: _showFilterSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari produk...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _onSearch(),
              ),
            ),
          ),

          // Category Pills
          if (_categories.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isSelected = _selectedCategory == null;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = null);
                          final token = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          ).token;
                          if (token != null) _fetchProducts(token);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? AppColors.primaryGradient
                                : null,
                            color: isSelected ? null : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Semua',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  final cat = _categories[index - 1];
                  final isSelected = _selectedCategory == cat['slug'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = cat['slug']);
                        final token = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).token;
                        if (token != null) _fetchProducts(token);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? AppColors.primaryGradient
                              : null,
                          color: isSelected ? null : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (cat['name'] as String).toUpperCase(),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 12),

          // Products Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 60,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada produk',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) =>
                          ProductCard(product: _products[index]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (result == true) _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Jual'),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Filter Lokasi', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Region>(
                    // ignore: deprecated_member_use
                    value: _filterProvince,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Provinsi'),
                    items: _provinces
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(
                              r.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) async {
                      setSheetState(() {
                        _filterProvince = v;
                        _filterCity = null;
                        _cities = [];
                      });
                      if (v != null) {
                        _cities = await _regionService.getRegencies(v.id);
                        setSheetState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Region>(
                    // ignore: deprecated_member_use
                    value: _filterCity,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Kota/Kabupaten',
                    ),
                    items: _cities
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(
                              r.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setSheetState(() => _filterCity = v),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _filterProvince = null;
                              _filterCity = null;
                            });
                            final token = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).token;
                            if (token != null) _fetchProducts(token);
                            Navigator.pop(context);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                            final token = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).token;
                            if (token != null) _fetchProducts(token);
                            Navigator.pop(context);
                          },
                          child: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
