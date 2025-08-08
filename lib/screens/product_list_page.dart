import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  final String pageTitle;
  final Future<List<Map<String, dynamic>>> Function({
    String? search,
    String? sortBy,
    Map<String, dynamic>? filters,
  }) fetchProducts;
  final bool isArabic;
  final Function toggleLanguage;
  final Map<String, dynamic>? initialFilters;
  final bool showWishlist;

  const ProductListPage({
    required this.pageTitle,
    required this.fetchProducts,
    required this.isArabic,
    required this.toggleLanguage,
    this.initialFilters,
    this.showWishlist = false,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String searchQuery = '';
  Set<String> wishlist = {};
  String sortOption = 'newest';
  Map<String, dynamic> filters = {};
  List<Map<String, dynamic>> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    filters = widget.initialFilters ?? {};
    fetchProducts();
    loadWishlist();
  }

  Future<void> fetchProducts() async {
    setState(() => loading = true);
    try {
      final result = await widget.fetchProducts(
        search: searchQuery,
        sortBy: sortOption,
        filters: filters,
      );
      setState(() {
        products = result;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint('Error fetching products: $e');
    }
  }

  void updateSearch(String value) {
    setState(() {
      searchQuery = value;
    });
    fetchProducts();
  }

  void updateSort(String? value) {
    if (value != null) {
      setState(() {
        sortOption = value;
      });
      fetchProducts();
    }
  }

  void updateFilters(Map<String, dynamic> newFilters) {
    setState(() {
      filters = newFilters;
    });
    fetchProducts();
  }

  Future<void> loadWishlist() async {
  final ids = await SupabaseService.getWishlist();
  setState(() => wishlist = ids);
}

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.isArabic;
    final textAlign = isArabic ? TextAlign.right : TextAlign.left;
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;
    final pageTitle = widget.pageTitle;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  centerTitle: true,
  leading: BackButton(color: Colors.black),
  title: Text(
    widget.pageTitle,
    style: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    textAlign: TextAlign.center,
  ),
  actions: [],
),
        body: Column(
          children: [
            // --- Search, Sort, Filter Row ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: updateSearch,
                              textDirection: textDirection,
                              decoration: InputDecoration(
                                hintText: isArabic ? 'ابحث في الصفحة' : 'Search this page',
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Sort Button
                  IconButton(
                    icon: const Icon(Icons.sort, color: Color(0xFFB30059)),
                    tooltip: isArabic ? 'ترتيب' : 'Sort by',
                    onPressed: () async {
                      final selected = await showModalBottomSheet<String>(
                        context: context,
                        builder: (_) => _SortSheet(
                          selected: sortOption,
                          isArabic: isArabic,
                        ),
                      );
                      if (selected != null) updateSort(selected);
                    },
                  ),
                  // Filter Button
                  IconButton(
                    icon: const Icon(Icons.filter_alt_outlined, color: Color(0xFFB30059)),
                    tooltip: isArabic ? 'تصفية' : 'Filter',
                    onPressed: () async {
                      final selectedFilters = await showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        builder: (_) => _FilterSheet(
                          isArabic: isArabic,
                          initial: filters,
                        ),
                      );
                      if (selectedFilters != null) updateFilters(selectedFilters);
                    },
                  ),
                ],
              ),
            ),
            // --- Product Grid ---
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : products.isEmpty
                      ? Center(
                          child: Text(
                            isArabic ? 'لا توجد منتجات' : 'No products',
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
  final product = products[index];
  final productId = product['id'].toString();
  final isWished = wishlist.contains(productId); // ✅ from local Set
  final userId = SupabaseService.getCurrentUserId();

  return ProductCard(
    product: product,
    isArabic: isArabic,
    rootContext: context,
    isWished: isWished,
    showWishlist: true,
    onWishlistTap: () async {
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isArabic ? 'الرجاء تسجيل الدخول لإضافة المنتج إلى المفضلة' : 'Please login to add to wishlist')),
        );
        return;
      }

      await SupabaseService.toggleWishlist(productId);
      loadWishlist(); // 👈 reload wishlist to update UI
    },
  );
},

                        ),
            ),
          ],
        ),
        // Bottom nav with full language support
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: const Color(0xFFB30059),
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            // Add navigation logic if needed
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: isArabic ? 'الرئيسية' : 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.category),
              label: isArabic ? 'الفئات' : 'Categories',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border),
              label: isArabic ? 'المفضلة' : 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart),
              label: isArabic ? 'السلة' : 'Cart',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: isArabic ? 'حسابي' : 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ----- SORT SHEET (modal) -----
class _SortSheet extends StatelessWidget {
  final String selected;
  final bool isArabic;
  const _SortSheet({required this.selected, required this.isArabic});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text(isArabic ? 'الأحدث' : 'Newest'),
            selected: selected == 'newest',
            onTap: () => Navigator.pop(context, 'newest'),
          ),
          ListTile(
            title: Text(isArabic ? 'الأقدم' : 'Oldest'),
            selected: selected == 'oldest',
            onTap: () => Navigator.pop(context, 'oldest'),
          ),
          ListTile(
            title: Text(isArabic ? 'الأعلى سعراً' : 'Highest Price'),
            selected: selected == 'price_high',
            onTap: () => Navigator.pop(context, 'price_high'),
          ),
          ListTile(
            title: Text(isArabic ? 'الأقل سعراً' : 'Lowest Price'),
            selected: selected == 'price_low',
            onTap: () => Navigator.pop(context, 'price_low'),
          ),
          ListTile(
            title: Text(isArabic ? 'الأعلى تقييماً' : 'Highest Rated'),
            selected: selected == 'high',
            onTap: () => Navigator.pop(context, 'high'),
          ),
          ListTile(
            title: Text(isArabic ? 'الأقل تقييماً' : 'Lowest Rated'),
            selected: selected == 'low',
            onTap: () => Navigator.pop(context, 'low'),
          ),
        ],
      ),
    );
  }
}

// ----- FILTER SHEET (modal) -----
class _FilterSheet extends StatefulWidget {
  final bool isArabic;
  final Map<String, dynamic> initial;
  const _FilterSheet({required this.isArabic, required this.initial});
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Map<String, dynamic> filters;

  @override
  void initState() {
    super.initState();
    filters = Map.from(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    // Arabic/English options for gender, size, and color
    List<String> genders = widget.isArabic ? ['رجالي', 'نسائي', 'أطفال'] : ['Men', 'Women', 'Kids'];
    List<String> sizes = widget.isArabic ? ['XS', 'S', 'M', 'L', 'XL'] : ['XS', 'S', 'M', 'L', 'XL'];
    List<String> colors = widget.isArabic
        ? ['أسود', 'أبيض', 'أحمر', 'أزرق', 'أخضر']
        : ['Black', 'White', 'Red', 'Blue', 'Green'];

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildFilterSection(
                label: widget.isArabic ? 'الجنس' : 'Gender',
                options: genders,
                keyName: 'gender',
              ),
              _buildFilterSection(
                label: widget.isArabic ? 'المقاس' : 'Size',
                options: sizes,
                keyName: 'size',
              ),
              _buildFilterSection(
                label: widget.isArabic ? 'اللون' : 'Color',
                options: colors,
                keyName: 'color',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context, <String, dynamic>{});
                      },
                      child: Text(widget.isArabic ? 'إعادة تعيين' : 'Reset'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB30059),
                      ),
                      onPressed: () {
                        Navigator.pop(context, filters);
                      },
                      child: Text(widget.isArabic ? 'تطبيق' : 'Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String label,
    required List<String> options,
    required String keyName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            final isSelected = filters[keyName] == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  filters[keyName] = option;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
