import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../providers/language_provider.dart';
import 'brand_products_page.dart';

class AllBrandsPage extends StatefulWidget {
  final String genderKey;
  const AllBrandsPage({required this.genderKey, Key? key}) : super(key: key);

  @override
  State<AllBrandsPage> createState() => _AllBrandsPageState();
}

class _AllBrandsPageState extends State<AllBrandsPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: BackButton(color: Colors.black),
          title: Text(
            isArabic ? 'كل الماركات' : 'All Brands',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),
        body: Column(
          children: [
            // --- Search Bar ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (val) => setState(() => searchQuery = val),
                        textDirection: textDirection,
                        decoration: InputDecoration(
                          hintText: isArabic ? 'ابحث عن ماركة' : 'Search brands',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // --- Brands Grid ---
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: SupabaseService.getBrands(gender: widget.genderKey),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  List<Map<String, dynamic>> brands = snapshot.data!;
                  // Search filter
                  if (searchQuery.isNotEmpty) {
                    brands = brands.where((b) {
                      final name = isArabic ? (b['name_ar'] ?? '') : (b['name_en'] ?? '');
                      return name.toString().toLowerCase().contains(searchQuery.toLowerCase());
                    }).toList();
                  }
                  if (brands.isEmpty) {
                    return Center(child: Text(isArabic ? 'لا توجد ماركات' : 'No brands found.'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 18,
                      childAspectRatio: 0.77,
                    ),
                    itemCount: brands.length,
                    itemBuilder: (context, idx) {
                      final brand = brands[idx];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BrandProductsPage(
                                brand: brand,
                                gender: widget.genderKey,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                brand['logo_url'] ?? '',
                                width: 68,
                                height: 68,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(Icons.store, size: 36, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isArabic ? (brand['name_ar'] ?? brand['name_en']) : (brand['name_en'] ?? ''),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
