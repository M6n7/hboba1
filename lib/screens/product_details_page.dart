import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final Set<String> wishlist;
  final bool isArabic;

  const ProductDetailsPage({
    Key? key,
    required this.product,
    required this.wishlist,
    required this.isArabic,
  }) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late bool isWished;
  late String productId;
  List<Map<String, dynamic>> configurations = [];
  Map<String, dynamic>? selectedConfig;

  @override
  void initState() {
    super.initState();
    productId = widget.product['id'].toString();
    isWished = widget.wishlist.contains(productId);
    _loadConfigurations();
  }

  Future<void> _loadConfigurations() async {
    final configs =
        await SupabaseService.getConfigurationsForProduct(productId);
    if (configs.isNotEmpty) {
      setState(() {
        configurations = configs;
        selectedConfig = configs.first;
      });
    }
  }

  Future<void> toggleWishlist() async {
    final userId = SupabaseService.getCurrentUserId();
    if (userId == null) {
      _showSnackbar(widget.isArabic
          ? 'الرجاء تسجيل الدخول لإضافة المنتج إلى المفضلة'
          : 'Please login to add to wishlist');
      return;
    }

    if (isWished) {
      await SupabaseService.removeFromWishlist(productId);
    } else {
      await SupabaseService.addToWishlist(productId);
    }

    setState(() {
      isWished = !isWished;
    });
  }

  Future<void> addToCart() async {
    final userId = SupabaseService.getCurrentUserId();
    if (userId == null) {
      _showSnackbar(widget.isArabic
          ? 'الرجاء تسجيل الدخول لإضافة المنتج إلى السلة'
          : 'Please login to add to cart');
      return;
    }

    if (selectedConfig == null) {
      _showSnackbar(widget.isArabic
          ? 'الرجاء اختيار الحجم أو اللون أولاً'
          : 'Please select a size or color first');
      return;
    }

    final configId = (selectedConfig!['id'] is int)
    ? selectedConfig!['id']
    : int.parse(selectedConfig!['id'].toString());

final prodId = (widget.product['id'] is int)
    ? widget.product['id']
    : int.parse(widget.product['id'].toString());

print('🧪 Adding configId: $configId (type: ${configId.runtimeType})');
print('🧪 Adding productId: $prodId (type: ${prodId.runtimeType})');

await SupabaseService.addToCart(
  configId: configId,
  productId: prodId,
);


    _showSnackbar(widget.isArabic
        ? 'تمت إضافة المنتج إلى السلة'
        : 'Product added to cart');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.isArabic;
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    final name = isArabic
        ? (widget.product['name_ar'] ?? '')
        : (widget.product['name_en'] ?? '');

    final brand = isArabic
        ? (widget.product['brand']?['name_ar'] ?? '')
        : (widget.product['brand']?['name_en'] ?? '');

    final image =
        selectedConfig?['image_url'] ?? widget.product['image_url'] ?? '';
    final price = selectedConfig?['price']?.toString() ??
        widget.product['price']?.toString() ??
        '';
    final description = isArabic
        ? (widget.product['description_ar'] ?? '')
        : (widget.product['description_en'] ?? '');

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            name,
            style: GoogleFonts.playfairDisplay(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 0.95,
                          child: image.isNotEmpty
                              ? Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image,
                                        size: 48),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image,
                                      size: 48),
                                ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: toggleWishlist,
                            child: Icon(
                              isWished
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isWished
                                  ? const Color(0xFFB30059)
                                  : Colors.white,
                              size: 28,
                              shadows: const [
                                Shadow(color: Colors.black45, blurRadius: 6)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            brand,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$price ${isArabic ? "ريال" : "SAR"}',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB30059),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (configurations.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic
                                      ? 'اختر الحجم واللون:'
                                      : 'Choose Size & Color:',
                                  style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                DropdownButton<Map<String, dynamic>>(
                                  isExpanded: true,
                                  value: selectedConfig,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedConfig = value;
                                    });
                                  },
                                  items: configurations.map((config) {
                                    final size = config['size'] ?? '';
                                    final color = config['color'] ?? '';
                                    return DropdownMenuItem(
                                      value: config,
                                      child: Text('$size / $color'),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),
                          if (description.isNotEmpty)
                            Text(
                              description,
                              style: GoogleFonts.cairo(
                                  fontSize: 15, color: Colors.black87),
                            ),
                          if (description.isEmpty)
                            Text(
                              isArabic ? "لا يوجد وصف." : "No description.",
                              style: GoogleFonts.cairo(
                                  fontSize: 15, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB30059),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isArabic ? 'أضف إلى السلة' : 'Add to Cart',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
