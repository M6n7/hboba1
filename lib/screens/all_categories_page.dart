import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../providers/language_provider.dart';
import 'category_products_page.dart';

class AllCategoriesPage extends StatefulWidget {
  final String? gender; // <- filter by gender
  final String? categoryId;
  final String? categoryName;
  final bool showAll;
  final Map<String, dynamic>? filter;

  const AllCategoriesPage({
    Key? key,
    this.gender,
    this.categoryId,
    this.categoryName,
    this.showAll = false,
    this.filter,
  }) : super(key: key);

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  List<Map<String, dynamic>> categories = [];
  bool loading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() => loading = true);
    try {
      final result = await SupabaseService.getCategories();
      setState(() {
        categories = result;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint('Error fetching categories: $e');
    }
  }

  List<Map<String, dynamic>> get filteredCategories {
    var filtered = categories;
    // Gender filtering
    if (widget.gender != null && widget.gender!.isNotEmpty) {
      filtered = filtered.where((cat) =>
        (cat['gender']?.toString().toLowerCase() ?? '') == widget.gender!.toLowerCase()
      ).toList();
    }
    // Search filtering
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = filtered.where((cat) {
        final en = (cat['name_en'] ?? '').toString().toLowerCase();
        final ar = (cat['name_ar'] ?? '').toString().toLowerCase();
        return en.contains(q) || ar.contains(q);
      }).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Use Provider here, NOT widget.isArabic or widget.toggleLanguage!
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final toggleLanguage = context.read<LanguageProvider>().toggleLanguage;
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;
    final pageTitle = widget.categoryName ?? (isArabic ? 'الفئات' : 'Categories');

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  centerTitle: true,
  leading: BackButton(color: Colors.black),
  title: Text(
    pageTitle,
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
            // Search bar for categories
            Padding(
              padding: const EdgeInsets.all(12.0),
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
                        onChanged: (v) => setState(() => searchQuery = v),
                        textDirection: textDirection,
                        decoration: InputDecoration(
                          hintText: isArabic ? 'ابحث في الفئات' : 'Search categories',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Categories grid
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCategories.isEmpty
                      ? Center(
                          child: Text(
                            isArabic ? 'لا توجد فئات' : 'No categories found',
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(10),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,
  crossAxisSpacing: 10,
  mainAxisSpacing: 10,
  childAspectRatio: 0.80,
),
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            final cat = filteredCategories[index];
                            final catName = isArabic ? cat['name_ar'] ?? '' : cat['name_en'] ?? '';
                            final catImage = cat['icon'] ?? '';
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CategoryProductsPage(
                                      categoryId: cat['uuid'].toString(),
                                      categoryName: catName,
                                      gender: widget.gender,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 3,
        offset: const Offset(0, 1.5),
      ),
    ],
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: catImage.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  catImage,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.broken_image, size: 32, color: Colors.grey[400]),
                ),
              )
            : Icon(Icons.category, size: 32, color: Colors.grey[400]),
      ),
      const SizedBox(height: 7),
      Text(
        catName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0.1,
        ),
      ),
    ],
  ),
),
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
