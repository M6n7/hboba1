import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'product_list_page.dart';

class FeaturedProductsPage extends StatelessWidget {
  final bool isArabic;
  final Function toggleLanguage;
  final String gender;

  const FeaturedProductsPage({
    Key? key,
    required this.gender,
    required this.isArabic,
    required this.toggleLanguage,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchFeaturedProducts({
  String? search,
  String? sortBy,
  Map<String, dynamic>? filters,
}) async {
  final mergedFilters = {
    'featured': true,
    'gender': gender,
    if (filters != null) ...filters,
  };

  final products = await SupabaseService.getProducts(
    sortBy: sortBy,
    filters: mergedFilters,
  );

  final wishlistIds = await SupabaseService.getWishlist();
  return products.map((p) {
    final id = p['id'].toString();
    return {
      ...p,
      'is_wished': wishlistIds.contains(id),
    };
  }).toList();
}

  @override
  Widget build(BuildContext context) {
    return ProductListPage(
      pageTitle: isArabic ? 'المنتجات المميزة' : 'Featured Products',
      fetchProducts: _fetchFeaturedProducts,
      isArabic: isArabic,
      toggleLanguage: toggleLanguage,
      initialFilters: const {},
      showWishlist: true, // 👈 enable wishlist heart
    );
  }
}
