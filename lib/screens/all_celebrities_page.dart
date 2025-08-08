import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../providers/language_provider.dart';
import 'celebrity_recommended_products_page.dart'; // adjust path if needed


class AllCelebritiesPage extends StatefulWidget {
  final String genderKey; // 'men', 'women'
  const AllCelebritiesPage({required this.genderKey, super.key});

  @override
  State<AllCelebritiesPage> createState() => _AllCelebritiesPageState();
}

class _AllCelebritiesPageState extends State<AllCelebritiesPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
      final toggleLanguage = context.read<LanguageProvider>().toggleLanguage;


    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isArabic ? 'كل المشاهير' : 'All Celebrities',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [],
      ),
      body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: isArabic ? 'ابحث عن المشاهير' : 'Search celebrities',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
                onChanged: (value) => setState(() => searchQuery = value.trim()),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: SupabaseService.getAllCelebrities(widget.genderKey),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  List<Map<String, dynamic>> celebrities = snapshot.data!;
                  // Alphabetical sort by display name
                  celebrities.sort((a, b) =>
                      (isArabic
                          ? (a['name_ar'] ?? a['name_en'] ?? '')
                          : (a['name_en'] ?? ''))
                      .toString()
                      .compareTo(
                          (isArabic
                                  ? (b['name_ar'] ?? b['name_en'] ?? '')
                                  : (b['name_en'] ?? ''))
                              .toString()));
                  // Filter by search
                  if (searchQuery.isNotEmpty) {
                    celebrities = celebrities.where((celeb) {
                      final name = isArabic
                          ? (celeb['name_ar'] ?? celeb['name_en'] ?? '')
                          : (celeb['name_en'] ?? '');
                      return name.toString().toLowerCase().contains(searchQuery.toLowerCase());
                    }).toList();
                  }
                  if (celebrities.isEmpty) {
                    return Center(child: Text(isArabic ? 'لا يوجد مشاهير' : 'No celebrities found.'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.77,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: celebrities.length,
                    itemBuilder: (context, idx) {
                      final celeb = celebrities[idx];
                      return GestureDetector(
                        onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CelebrityRecommendedProductsPage(
        celebrity: celeb,
      ),
    ),
  );
},

                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                celeb['image_url'] ?? '',
                                width: 82,
                                height: 82,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 82,
                                  height: 82,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.person, size: 34, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 82,
                              child: Text(
                                isArabic
                                    ? (celeb['name_ar'] ?? celeb['name_en'] ?? '')
                                    : (celeb['name_en'] ?? ''),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
