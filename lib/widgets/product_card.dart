import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isArabic;
  final bool showWishlist;
  final bool isWished;
  final VoidCallback? onWishlistTap;
  final BuildContext rootContext;

  const ProductCard({
    super.key,
    required this.product,
    required this.isArabic,
    this.showWishlist = false,
    this.isWished = false,
    required this.rootContext,
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = isArabic ? product['name_ar'] ?? '' : product['name_en'] ?? '';
    final price = product['price']?.toString() ?? '0';
    final imageUrl = product['image_url'] ?? '';
    final brandName = isArabic
        ? (product['brand']?['name_ar'] ?? '')
        : (product['brand']?['name_en'] ?? '');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
  child: Stack(
    children: [
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: imageUrl.isNotEmpty
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
      ),

      if (showWishlist)
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onWishlistTap,
            child: Icon(
              isWished ? Icons.favorite : Icons.favorite_border,
              color: isWished ? Color(0xFFB30059) : Colors.white,
              size: 22,
              shadows: [Shadow(color: Colors.black45, blurRadius: 5)],
            ),
          ),
        ),
    ],
  ),
),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BRAND NAME ---
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
                ),
                const SizedBox(height: 2),
                // --- PRODUCT NAME ---
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$price SDG',
                  style: const TextStyle(color: Color(0xFFB30059), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
