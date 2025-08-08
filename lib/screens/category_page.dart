import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'product_list_page.dart';

class CategoryPage extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final String sortBy;
  final bool isArabic;
  final Function toggleLanguage;
  final String? genderFilter;
  final String? sizeFilter;
  final String? colorFilter;

  const CategoryPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.sortBy,
    required this.isArabic,
    required this.toggleLanguage,
    this.genderFilter,
    this.sizeFilter,
    this.colorFilter,
  });

  // Dynamic fetchProducts callback for ProductListPage
  Future<List<Map<String, dynamic>>> _fetchCategoryProducts({
    String? search,
    String? sortBy,
    Map<String, dynamic>? filters,
  }) {
    // Merge initial filters if they exist
    final mergedFilters = {
      if (genderFilter != null) 'gender': genderFilter,
      if (sizeFilter != null) 'size': sizeFilter,
      if (colorFilter != null) 'color': colorFilter,
      if (filters != null) ...filters,
    };
    return SupabaseService.getProducts(
      categoryId: categoryId.isEmpty ? null : categoryId,
      sortBy: sortBy,
      filters: mergedFilters,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProductListPage(
      pageTitle: categoryName,
      fetchProducts: _fetchCategoryProducts,
      isArabic: isArabic,
      toggleLanguage: toggleLanguage,
      initialFilters: {
        if (genderFilter != null) 'gender': genderFilter,
        if (sizeFilter != null) 'size': sizeFilter,
        if (colorFilter != null) 'color': colorFilter,
      },
    );
  }
}
