import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../providers/language_provider.dart';
import 'product_details_page.dart';

class CategoryProductsPage extends StatefulWidget {
  final String? categoryId;
  final String categoryName;
  final String? gender;
  final bool showAll;
  final bool isNewIn;
  final Map<String, dynamic>? filter;

  const CategoryProductsPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    this.gender,
    this.showAll = false,
    this.isNewIn = false,
    this.filter,
  }) : super(key: key);

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  Map<String, dynamic>? _categoryData;
  bool _categoryLoading = true;
  Set<String> wishlist = {};

  @override
  void initState() {
    super.initState();
    _loadCategory();
    _loadWishlist();
  }

  Future<void> _loadCategory() async {
    if (widget.categoryId != null && widget.categoryId!.isNotEmpty) {
      final res = await SupabaseService.getCategoryById(widget.categoryId!);
      setState(() {
        _categoryData = res;
        _categoryLoading = false;
      });
    } else {
      _categoryLoading = false;
    }
  }

  Future<void> _loadWishlist() async {
    final ids = await SupabaseService.getWishlist();
    setState(() => wishlist = ids);
  }

  Future<void> _toggleWishlist(String productId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      final isArabic = context.read<LanguageProvider>().isArabic;
      final message = isArabic ? 'يرجى تسجيل الدخول لإضافة العناصر إلى المفضلة' : 'Please log in to add items to wishlist';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    await SupabaseService.toggleWishlist(productId);
    await _loadWishlist();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    final Map<String, dynamic> finalFilter = {};
    if (widget.gender != null && widget.gender!.isNotEmpty) finalFilter['gender'] = widget.gender;
    if (!widget.showAll && widget.categoryId != null && widget.categoryId!.isNotEmpty)
      finalFilter['category_id'] = widget.categoryId;
    if (widget.filter != null) finalFilter.addAll(widget.filter!);

    if (_categoryLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final cat = _categoryData;
    final bannerUrl = cat != null ? (cat['icon'] ?? '') : '';
    final catName = isArabic
        ? (cat?['name_ar'] ?? widget.categoryName)
        : (cat?['name_en'] ?? widget.categoryName);
    final catDesc = isArabic
        ? (cat?['description_ar'] ?? cat?['description'] ?? '')
        : (cat?['description'] ?? '');

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(color: Colors.black),
          centerTitle: true,
          title: Text(
            catName,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Colors.black,
              child: Column(
                children: [
                  if (bannerUrl.isNotEmpty)
                    Image.network(
                      bannerUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey[800],
                        child: Icon(Icons.image, color: Colors.grey[600], size: 46),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          catName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (catDesc.isNotEmpty) ...[
                          const SizedBox(height: 7),
                          Text(
                            catDesc,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.sort, color: Color(0xFFB30059)),
                    label: Text(
                      isArabic ? "ترتيب" : "Sort",
                      style: TextStyle(color: Color(0xFFB30059)),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    icon: Icon(Icons.filter_alt_outlined, color: Color(0xFFB30059)),
                    label: Text(
                      isArabic ? "تصفية" : "Filter",
                      style: TextStyle(color: Color(0xFFB30059)),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: SupabaseService.getProducts(
                  filters: finalFilter,
                  sortBy: widget.isNewIn ? 'created_at' : null,
                  descending: widget.isNewIn,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        isArabic ? 'حدث خطأ أثناء تحميل المنتجات' : 'Error loading products.',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(isArabic ? 'لا توجد منتجات' : 'No products.'),
                    );
                  }
                  final products = snapshot.data!;
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
                      final prodId = prod['id'].toString();
                      final isWished = wishlist.contains(prodId);
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
  wishlist: wishlist,
  isArabic: isArabic,
),

                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
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
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () async => await _toggleWishlist(prodId),
                                    child: Icon(
                                      isWished ? Icons.favorite : Icons.favorite_border,
                                      color: isWished ? Color(0xFFB30059) : Colors.white,
                                      size: 20,
                                      shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 7),
                            Text(
                              brandName,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isArabic ? (prod['name_ar'] ?? '') : (prod['name_en'] ?? ''),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                fontFamily: 'Montserrat',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${prod['price'] ?? ''} ${isArabic ? "ر.س" : "SAR"}',
                              style: const TextStyle(
                                color: Color(0xFFB30059),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                              textAlign: TextAlign.center,
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
