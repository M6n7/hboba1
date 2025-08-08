import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'product_list_page.dart';

class NewInPage extends StatelessWidget {
  final bool isArabic;
  final Function toggleLanguage;
  final String gender; // 👈 Add gender parameter

  const NewInPage({
    Key? key,
    required this.isArabic,
    required this.toggleLanguage,
    required this.gender, // 👈 Require gender
  }) : super(key: key);

  // Fetch newest products with advanced filters
  Future<List<Map<String, dynamic>>> _fetchNewInProducts({
    String? search,
    String? sortBy,
    Map<String, dynamic>? filters,
  }) {
    // Merge gender into filters
    final mergedFilters = {
      'gender': gender,
      if (filters != null) ...filters,
    };
    return SupabaseService.getProducts(
      sortBy: sortBy ?? 'newest',
      filters: mergedFilters,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProductListPage(
      pageTitle: isArabic ? 'جديد في المتجر' : 'New In',
      fetchProducts: _fetchNewInProducts,
      isArabic: isArabic,
      toggleLanguage: toggleLanguage,
      showWishlist: true,
    );
  }
}
