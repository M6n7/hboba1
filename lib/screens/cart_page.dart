// lib/screens/cart_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../providers/language_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    try {
      final data = await SupabaseService.getCartItems();
      setState(() {
        cartItems = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error loading cart: \$e');
    }
  }

  double get totalPrice {
    return cartItems.fold(0, (sum, item) {
      final config = item['product_configurations'];
      final price = config?['price'] ?? 0;
      final qty = item['quantity'] ?? 1;
      return sum + (price * qty);
    });
  }

  Future<void> removeItem(String cartItemId) async {
    await SupabaseService.removeFromCart(cartItemId);
    await loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final textStyle = isArabic ? GoogleFonts.cairo() : GoogleFonts.playfairDisplay();
    final pageTitle = isArabic ? 'سلة التسوق' : 'Shopping Bag';
    final totalText = isArabic ? 'الإجمالي' : 'Grand Total';
    final checkoutText = isArabic ? 'الدفع الآمن' : 'Secure Checkout';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(pageTitle, style: textStyle.copyWith(fontWeight: FontWeight.bold)),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : cartItems.isEmpty
                ? Center(
                    child: Text(
                      isArabic ? 'السلة فارغة' : 'Your cart is empty',
                      style: textStyle,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            final config = item['product_configurations'];
                            final product = config?['products'];
                            final brand = product?['brand'];
                            final cartItemId = item['id'].toString();
                            final name = isArabic
                                ? (product?['name_ar'] ?? '')
                                : (product?['name_en'] ?? '');
                            final brandName = isArabic
                                ? (brand?['name_ar'] ?? '')
                                : (brand?['name_en'] ?? '');
                            final image = product?['image_url'] ?? '';
                            final price = config?['price'] ?? 0;
                            final original = config?['original_price'] ?? price;
                            final discount = config?['discount'] ?? 0;
                            final color = config?['color'] ?? '-';
                            final size = config?['size'] ?? '-';
                            final quantity = item['quantity'] ?? 1;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      image,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (discount > 0)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '-\$discount%',
                                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          Text(brandName, style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                                          Text(name, style: textStyle),
                                          Text(
                                            '${isArabic ? 'اللون' : 'Color'}: $color   ${isArabic ? 'المقاس' : 'Size'}: $size   ${isArabic ? 'الكمية' : 'Qty'}: $quantity',
                                            style: textStyle.copyWith(color: Colors.grey[700], fontSize: 12),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              if (original > price)
                                                Text(
                                                  '${original.toStringAsFixed(2)} AED',
                                                  style: textStyle.copyWith(
                                                    decoration: TextDecoration.lineThrough,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              const SizedBox(width: 8),
                                              Text('${price.toStringAsFixed(2)} AED', style: textStyle),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => removeItem(cartItemId),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: isArabic ? 'رسالة الهدية (اختياري)' : 'Gift Message (Optional)',
                                prefixIcon: const Icon(Icons.card_giftcard),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: isArabic ? 'أدخل رمز القسيمة' : 'Enter Coupon Code',
                                prefixIcon: const Icon(Icons.discount),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  totalText,
                                  style: textStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${totalPrice.toStringAsFixed(2)} AED',
                                  style: textStyle.copyWith(fontSize: 18, color: const Color(0xFFB30059)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB30059),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                // TODO: Checkout logic
                              },
                              child: Text(checkoutText, style: textStyle.copyWith(color: Colors.white)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
      ),
    );
  }
}
