import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../providers/language_provider.dart';
import 'product_details_page.dart';

class BrandProductsPage extends StatefulWidget {
  final Map<String, dynamic> brand;
  final String gender;

  const BrandProductsPage({
    required this.brand,
    required this.gender,
    Key? key,
  }) : super(key: key);

  @override
  State<BrandProductsPage> createState() => _BrandProductsPageState();
}

class _BrandProductsPageState extends State<BrandProductsPage> {
  String? selectedCategory; // For category tabs
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  late Future<Map<String, dynamic>> _brandFuture;

  Map<String, dynamic>? _brandData;
  bool _brandLoading = true;

  @override
  void initState() {
    super.initState();
    _brandFuture = SupabaseService.getBrandById(widget.brand['id']);
    _categoriesFuture = SupabaseService.getCategoriesForBrandAndGender(
      brandId: widget.brand['id'],
      gender: widget.gender,
    );
    _loadBrand();
  }

  void _loadBrand() async {
    if (widget.brand.keys.length == 1 && widget.brand.containsKey('id')) {
      final brand = await SupabaseService.getBrandById(widget.brand['id']);
      setState(() {
        _brandData = brand;
        _brandLoading = false;
      });
    } else {
      setState(() {
        _brandData = widget.brand;
        _brandLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;
    if (_brandLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final brand = _brandData!;
    final brandName = isArabic
        ? (brand['name_ar'] ?? brand['name_en'] ?? '')
        : (brand['name_en'] ?? '');
    final brandLogo = brand['logo_url'] ?? '';
    final about = isArabic
        ? (brand['description_ar'] ?? brand['description_en'] ?? '')
        : (brand['description_en'] ?? '');
    final gender = widget.gender;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            brandName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Brand header (circle logo + name + description) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (brandLogo.isNotEmpty)
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(7),
                      child: Image.network(
                        brandLogo,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.store, size: 28, color: Colors.grey[400]),
                      ),
                    ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          brandName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            fontFamily: 'Montserrat', // or your font
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 7),
                        if (about.isNotEmpty)
                          Text(
                            about,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),

            // --- Category Tabs (Farfetch Style) ---
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Categories error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                final categories = snapshot.data!;
                if (categories.isEmpty) return const SizedBox.shrink();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      _CategoryTab(
                        label: isArabic ? "الكل" : "All",
                        selected: selectedCategory == null,
                        onTap: () => setState(() => selectedCategory = null),
                      ),
                      ...categories.map((cat) {
                        final name = isArabic
                            ? (cat['name_ar'] ?? cat['name_en'] ?? '')
                            : (cat['name_en'] ?? '');
                        return _CategoryTab(
                          label: name,
                          selected: selectedCategory == cat['uuid'],
                          onTap: () => setState(() => selectedCategory = cat['uuid']),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            // --- Sort/Filter Row ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.sort, color: Color(0xFFB30059)),
                    label: Text(
                      isArabic ? "ترتيب" : "Sort",
                      style: TextStyle(color: Color(0xFFB30059)),
                    ),
                    onPressed: () {
                      // To be implemented
                    },
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    icon: Icon(Icons.filter_alt_outlined, color: Color(0xFFB30059)),
                    label: Text(
                      isArabic ? "تصفية" : "Filter",
                      style: TextStyle(color: Color(0xFFB30059)),
                    ),
                    onPressed: () {
                      // To be implemented
                    },
                  ),
                ],
              ),
            ),

            // --- Products Grid ---
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: SupabaseService.getProducts(
                  filters: {
                    'brand_id': brand['id'],
                    'gender': gender,
                    if (selectedCategory != null) 'category_id': selectedCategory,
                  },
                  sortBy: 'newest',
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final products = snapshot.data!;
                  if (products.isEmpty) {
                    return Center(
                        child: Text(isArabic
                            ? "لا توجد منتجات لهذه الماركة."
                            : "No products found for this brand."));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, idx) {
  final prod = products[idx];
  final brandName = isArabic
      ? (prod['brand']?['name_ar'] ?? '')
      : (prod['brand']?['name_en'] ?? '');
  return GestureDetector(
    onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProductDetailsPage(
        product: prod,
        wishlist: {}, // you can load the real wishlist later if needed
        isArabic: isArabic,
      ),
    ),
  );
},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                prod['image_url'] ?? '',
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 140,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic
                                      ? (brand['name_ar'] ?? brand['name_en'] ?? '')
                                      : (brand['name_en'] ?? ''),
                                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isArabic
                                      ? (prod['name_ar'] ?? prod['name_en'] ?? '')
                                      : (prod['name_en'] ?? ''),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${prod['price'] ?? ''} ${isArabic ? "ر.س" : "SAR"}',
                              style: const TextStyle(
                                color: Color(0xFFB30059),
                                fontWeight: FontWeight.bold,
                              ),
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

// --- Category Tab Widget (Farfetch Style) ---
class _CategoryTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
                fontFamily: 'Montserrat', // unify font if you want
              ),
            ),
            SizedBox(height: 3),
            AnimatedContainer(
              duration: Duration(milliseconds: 180),
              height: 2.6,
              width: selected ? 26 : 0,
              decoration: BoxDecoration(
                color: selected ? Color(0xFFB30059) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
