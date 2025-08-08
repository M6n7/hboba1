import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../providers/language_provider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> wishlistItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    try {
      final ids = await SupabaseService.getWishlist();
      final allProducts = await SupabaseService.getProducts();
      final filtered = allProducts.where((prod) => ids.contains(prod['id'].toString())).toList();
      setState(() {
        wishlistItems = filtered;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void removeFromWishlist(String id) async {
    await SupabaseService.removeFromWishlist(id);
    loadWishlist();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final textStyle = isArabic ? GoogleFonts.cairo() : GoogleFonts.playfairDisplay();
    final direction = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: direction,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            isArabic ? 'المفضلة' : 'Wishlist',
            style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : wishlistItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          isArabic ? 'لا توجد عناصر محفوظة' : 'You haven’t saved anything yet.',
                          style: textStyle.copyWith(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: wishlistItems.length,
                      itemBuilder: (context, idx) {
                        final item = wishlistItems[idx];
                        final name = isArabic ? (item['name_ar'] ?? '') : (item['name_en'] ?? '');
                        final brand = isArabic ? (item['brand']?['name_ar'] ?? '') : (item['brand']?['name_en'] ?? '');
                        final price = item['price']?.toString() ?? '';
                        final image = item['image_url'] ?? '';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Image.network(
                                      image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[200],
                                        child: Icon(Icons.broken_image, size: 40),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => removeFromWishlist(item['id'].toString()),
                                    child: Icon(Icons.favorite, color: Color(0xFFB30059), size: 22),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              brand.toUpperCase(),
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                                letterSpacing: 0.8,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              name,
                              style: textStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 14, height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${isArabic ? 'ر.س' : 'SAR'} $price',
                              style: TextStyle(
                                color: Color(0xFFB30059),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}