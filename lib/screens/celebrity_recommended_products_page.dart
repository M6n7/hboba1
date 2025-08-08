import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/supabase_service.dart';
import '../providers/language_provider.dart';

class CelebrityRecommendedProductsPage extends StatefulWidget {
  final Map<String, dynamic> celebrity;
  const CelebrityRecommendedProductsPage({Key? key, required this.celebrity}) : super(key: key);

  @override
  State<CelebrityRecommendedProductsPage> createState() => _CelebrityRecommendedProductsPageState();
}

class _CelebrityRecommendedProductsPageState extends State<CelebrityRecommendedProductsPage> {
  String sortBy = 'newest';
  Map<String, dynamic> filter = {};
  bool showFilter = false;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final themeColor = const Color(0xFFB30059);

    final name = isArabic
        ? (widget.celebrity['name_ar'] ?? widget.celebrity['name_en'] ?? '')
        : (widget.celebrity['name_en'] ?? '');
    final discount = widget.celebrity['discount_code'] ?? '';
    final avatarUrl = widget.celebrity['image_url'] ?? '';
    final heroUrl = widget.celebrity['hero_image_url'] ?? '';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            name,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: SupabaseService.getCelebrityBanners(widget.celebrity['id'].toString()),
          builder: (context, bannerSnap) {
            final banners = bannerSnap.data ?? [];
            return CustomScrollView(
              slivers: [
                // HERO SECTION
SliverToBoxAdapter(
  child: Container(
    width: double.infinity,
    height: 240,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(36),
        bottomRight: Radius.circular(36),
      ),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        // Hero Image
        if (heroUrl.isNotEmpty)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
            child: Image.network(
              heroUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[100]!, Colors.grey[200]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
          ),
        // Gradient overlay (for text readability)
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.44),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Content: avatar, name, discount
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: avatarUrl.isEmpty
                        ? Icon(Icons.person, size: 45, color: Colors.grey[400])
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                    color: Colors.white,
                    letterSpacing: 0.2,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black45,
                        offset: Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
                if (discount.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.82),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        isArabic ? 'رمز الخصم: $discount' : 'Discount Code: $discount',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: themeColor,
                          fontSize: 15,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
),

                // CAROUSEL
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 6),
                    child: banners.isNotEmpty
                        ? CarouselSlider(
                            options: CarouselOptions(
                              height: 185,
                              enlargeCenterPage: true,
                              viewportFraction: 0.98,
                              autoPlay: banners.length > 1,
                              autoPlayInterval: Duration(seconds: 5),
                            ),
                            items: banners.map((banner) {
                              final url = banner['image_url'] ?? '';
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  url,
                                  width: double.infinity,
                                  height: 185,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 185,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.broken_image, size: 44, color: Colors.grey[400]),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : Container(
                            height: 185,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                  ),
                ),
                // SORT/FILTER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.sort, color: themeColor),
                            label: Text(
                              isArabic ? 'ترتيب' : 'Sort',
                              style: TextStyle(color: themeColor),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              side: BorderSide(color: themeColor, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => _showSortSheet(context, isArabic),
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.filter_alt_outlined, color: themeColor),
                            label: Text(
                              isArabic ? 'تصفية' : 'Filter',
                              style: TextStyle(color: themeColor),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              side: BorderSide(color: themeColor, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => setState(() => showFilter = !showFilter),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // FILTER
                if (showFilter)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                      child: Text(
                        isArabic ? "هنا خيارات الفلترة (قيد التطوير)" : "Filter options go here (TBD)",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                // PRODUCTS GRID OR EMPTY
                SliverToBoxAdapter(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: SupabaseService.getCelebrityRecommendedProducts(
                      celebrityId: widget.celebrity['id'].toString(),
                      sortBy: sortBy,
                      filter: filter,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final products = snapshot.data!;
                      if (products.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Center(
                            child: Text(
                              isArabic
                                  ? 'لا توجد منتجات لهذا المشهور بعد'
                                  : 'No products for this celebrity yet.',
                              style: TextStyle(color: Colors.grey[700], fontSize: 16),
                            ),
                          ),
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 22,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, idx) {
                          final prod = products[idx];
                          return Card(
                            elevation: 1.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      prod['image_url'] ?? '',
                                      height: 110,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 110,
                                        color: Colors.grey[200],
                                        child: Icon(Icons.broken_image, size: 32, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 9),
                                  Text(
                                    prod['brand']?.toString() ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isArabic
                                        ? (prod['name_ar'] ?? prod['name_en'] ?? '')
                                        : (prod['name_en'] ?? ''),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${prod['price'] ?? ''} SAR',
                                    style: TextStyle(
                                      color: themeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(isArabic ? "الأحدث" : "Newest"),
              onTap: () {
                setState(() => sortBy = 'newest');
                Navigator.pop(context);
              },
              selected: sortBy == 'newest',
            ),
            ListTile(
              title: Text(isArabic ? "الأقل سعراً" : "Price: Low to High"),
              onTap: () {
                setState(() => sortBy = 'price_asc');
                Navigator.pop(context);
              },
              selected: sortBy == 'price_asc',
            ),
            ListTile(
              title: Text(isArabic ? "الأعلى سعراً" : "Price: High to Low"),
              onTap: () {
                setState(() => sortBy = 'price_desc');
                Navigator.pop(context);
              },
              selected: sortBy == 'price_desc',
            ),
          ],
        ),
      ),
    );
  }
}
