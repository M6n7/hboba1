import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hboba/screens/cart_page.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/product_details_page.dart';
import '../providers/language_provider.dart';
import 'category_products_page.dart';
import 'featured_products_page.dart';
import 'new_in_page.dart';
import 'all_categories_page.dart';
import 'all_celebrities_page.dart'; // adjust path if in a subfolder
import 'all_brands_page.dart';
import 'celebrity_recommended_products_page.dart';
import 'brand_products_page.dart';
import 'wishlist_page.dart';

// Consistent spacings for sections
const double kSectionTop = 22;     // space above each section title (matches Ounass/Farfetch)
const double kSectionMid = 12;     // space between title and section content
const double kSectionSmall = 12;   // small gaps (between items/images/cards)
const double kSectionBottom = 22;  // after section before next section (matches top)
const double kPaddingHorizontal = 16; // left/right consistent padding

// MAIN HOME PAGE
class HomePage extends StatefulWidget {
  final String? gender;  // 👈 Add this line (gender is now optional)
  const HomePage({Key? key, this.gender}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String selectedGender;
  int currentIndex = 0;

  final genders = ['Men', 'Women', 'Kids'];
  final gendersAr = ['رجالي', 'نسائي', 'أطفال'];
  final genderKeys = ['men', 'women', 'kids'];

  @override
void initState() {
  super.initState();
  if (widget.gender != null && widget.gender!.isNotEmpty) {
    final passedGender = widget.gender!.toLowerCase();
    final idx = genderKeys.indexOf(passedGender);
    selectedGender = (idx != -1) ? genders[idx] : 'Men';
  } else {
    selectedGender = 'Men';
  }
}

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final toggleLanguage = context.read<LanguageProvider>().toggleLanguage;
    final textStyle = isArabic ? GoogleFonts.cairo() : GoogleFonts.playfairDisplay();
    final langText = isArabic ? 'English' : 'العربية';
    final categoryTitle = isArabic ? 'الفئات' : 'Categories';
    final featuredTitle = isArabic ? 'المنتجات المميزة' : 'Featured Products';
    final newInTitle = isArabic ? 'جديد في المتجر' : 'New In';
    final genderKey = genderKeys[genders.indexOf(selectedGender)];
    final languageKey = isArabic ? 'ar' : 'en';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  automaticallyImplyLeading: false, // no back button on home page
  centerTitle: true, // center the logo/title
  title: Text(
    'HBOBA',
    style: textStyle.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 22,
      letterSpacing: 1.2,
    ),
  ),
),
        body: SafeArea(
          child: IndexedStack(
            index: currentIndex,
            children: [
              // --- Home tab (main homepage ListView) ---
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  // --- Search Bar (with Filter & Sort inside the box) ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              style: textStyle,
                              decoration: InputDecoration(
                                hintText: isArabic ? 'ابحث عن المنتجات' : 'Search products',
                                hintStyle: textStyle.copyWith(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.filter_alt_outlined, color: Color(0xFFB30059)),
                            onPressed: () {},
                            tooltip: isArabic ? 'تصفية' : 'Filter',
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          IconButton(
                            icon: Icon(Icons.sort, color: Color(0xFFB30059)),
                            onPressed: () {},
                            tooltip: isArabic ? 'ترتيب' : 'Sort',
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // --- Announcement Bar (Carousel) ---
                  const SizedBox(height: 18),
                  _AnnouncementBar(),

                  // --- Gender Tabs ---
                  const SizedBox(height: 22),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(genders.length, (i) {
                        final selected = selectedGender == genders[i];
                        return GestureDetector(
                          onTap: () => setState(() => selectedGender = genders[i]),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: selected ? Color(0xFFB30059) : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              isArabic ? gendersAr[i] : genders[i],
                              style: textStyle.copyWith(
                                color: selected ? Color(0xFFB30059) : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // --- Gender Banner Carousel (bigger height + spacing below) ---
                  const SizedBox(height: 10),
                  _GenderBannerCarousel(
                    gender: genderKey,
                    language: languageKey,
                    bannerHeight: 270,
                  ),
                  const SizedBox(height: 28),

                  // --- Celebrities Section (Men/Women only) ---
                  if (genderKey != 'kids') ...[
                    const SizedBox(height: kSectionTop),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isArabic ? 'المشاهير' : 'Celebrities',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AllCelebritiesPage(genderKey: genderKey),
                                    ),
                                  );
                                },
                                child: Text(isArabic ? 'عرض الكل' : 'Show All',
                                    style: TextStyle(color: Color(0xFFB30059), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: kSectionMid),
                          _CelebritiesSection(genderKey: genderKey),
                        ],
                      ),
                    ),
                  ],

                  // --- Categories Section ---
                  const SizedBox(height: kSectionTop),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              categoryTitle,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AllCategoriesPage(
                                      categoryId: null,
                                      categoryName: categoryTitle,
                                      gender: genderKey,
                                      showAll: true,
                                      filter: {},
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                isArabic ? 'عرض الكل' : 'Show All',
                                style: const TextStyle(
                                    color: Color(0xFFB30059), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _CategoriesGrid(genderKey: genderKey),
                      ],
                    ),
                  ),

                  // --- Featured Products ---
                  const SizedBox(height: kSectionTop),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(featuredTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FeaturedProductsPage(
                                      gender: genderKey,      // 👈 Pass genderKey
                                      isArabic: isArabic,
                                      toggleLanguage: toggleLanguage,
                                    ),
                                  ),
                                );
                              },
                              child: Text(isArabic ? 'عرض الكل' : 'Show All',
                                  style: TextStyle(color: Color(0xFFB30059), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: kSectionMid),
                        _ProductHorizontalList(
                          gender: genderKey,
                          filter: {'featured': true},
                          listHeight: 285,
                        ),
                      ],
                    ),
                  ),

                  // --- Featured Brands Section ---
                  const SizedBox(height: kSectionTop),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isArabic ? 'الماركات' : 'Brands',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AllBrandsPage(genderKey: genderKey),
                                  ),
                                );
                              },
                              child: Text(isArabic ? 'عرض الكل' : 'Show All',
                                  style: TextStyle(color: Color(0xFFB30059), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: kSectionMid),
                        _FeaturedBrandsSection(genderKey: genderKey),
                      ],
                    ),
                  ),

                  // --- New In Products ---
                  const SizedBox(height: kSectionTop),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(newInTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NewInPage(
                                      gender: genderKey,
                                      isArabic: isArabic,
                                      toggleLanguage: toggleLanguage,
                                    ),
                                  ),
                                );
                              },
                              child: Text(isArabic ? 'عرض الكل' : 'Show All',
                                  style: TextStyle(color: Color(0xFFB30059), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: kSectionMid),
                        _ProductHorizontalList(
                          gender: genderKey,
                          filter: {},
                          sortBy: 'newest',
                          listHeight: 285,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: kSectionBottom),
                ],
              ),
              // --- Categories tab ---
              AllCategoriesPage(gender: genderKey),
              // --- Wishlist tab ---
              WishlistPage(),
              // --- Cart tab ---
              CartPage(),
              // --- Profile tab ---
              Placeholder(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          selectedItemColor: const Color(0xFFB30059),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.shifting,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: isArabic ? 'الرئيسية' : 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.category_outlined), label: isArabic ? 'الفئات' : 'Categories'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: isArabic ? 'المفضلة' : 'Wishlist'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: isArabic ? 'السلة' : 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: isArabic ? 'حسابي' : 'Profile'),
          ],
        ),
      ),
    );
  }
}

// -------- Celebrities Section --------
class _CelebritiesSection extends StatelessWidget {
  final String genderKey;
  const _CelebritiesSection({required this.genderKey});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    return SizedBox(
      height: 110,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: SupabaseService.getFeaturedCelebritiesByGender(genderKey),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          final celebrities = snapshot.data!;
          if (celebrities.isEmpty) {
            return Center(child: Text(isArabic ? 'لا يوجد مشاهير' : 'No celebrities'));
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: celebrities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
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
                        width: 78,
                        height: 78,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey[200], child: Icon(Icons.person, size: 32, color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 78,
                      child: Text(
                        isArabic ? (celeb['name_ar'] ?? celeb['name_en']) : (celeb['name_en'] ?? ''),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -------- Featured brands section --------
class _FeaturedBrandsSection extends StatelessWidget {
  final String genderKey;
  const _FeaturedBrandsSection({required this.genderKey});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;

    return SizedBox(
      height: 100,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: SupabaseService.getFeaturedBrands(gender: genderKey),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          final brands = snapshot.data!;
          if (brands.isEmpty) {
            return Center(child: Text(isArabic ? 'لا توجد ماركات' : 'No brands'));
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: brands.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, idx) {
              final brand = brands[idx];
              return GestureDetector(
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BrandProductsPage(
        brand: brand,
        gender: genderKey, // ✅ correct key name
      ),
    ),
  );
},

                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        brand['logo_url'] ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[200], child: Icon(Icons.store, size: 32, color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 60,
                      child: Text(
                        isArabic ? (brand['name_ar'] ?? brand['name_en']) : (brand['name_en'] ?? ''),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -------- Brands Grid/List Only (NO header/title/Show All) --------
class _BrandsSection extends StatelessWidget {
  final String genderKey;
  const _BrandsSection({required this.genderKey});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;

    return SizedBox(
      height: 100,
      child: FutureBuilder<List<Map<String, dynamic>>>(
  future: SupabaseService.getFeaturedBrands(gender: genderKey),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          final brands = snapshot.data!;
          if (brands.isEmpty) {
            return Center(child: Text(isArabic ? 'لا توجد ماركات' : 'No brands'));
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: brands.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, idx) {
              final brand = brands[idx];
              return GestureDetector(
                onTap: () {
                  // TODO: Navigate to a brand details/products page
                },
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        brand['logo_url'] ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey[200], child: Icon(Icons.store, size: 32, color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 60,
                      child: Text(
                        isArabic ? (brand['name_ar'] ?? brand['name_en']) : (brand['name_en'] ?? ''),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -------- Announcement Bar Carousel --------
class _AnnouncementBar extends StatelessWidget {
  const _AnnouncementBar();

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    return SizedBox(
      height: 44,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: SupabaseService.getAnnouncements(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              height: 44,
              color: Color(0xFFF9E6F0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final data = snapshot.data!;
          if (data.isEmpty) return SizedBox(height: 44);
          return CarouselSlider(
            options: CarouselOptions(
              height: 44,
              viewportFraction: 1,
              autoPlay: data.length > 1,
              autoPlayInterval: Duration(seconds: 3),
              disableCenter: true,
              scrollPhysics: data.length == 1 ? NeverScrollableScrollPhysics() : null,
            ),
            items: data.map((item) {
              return Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Color(0xFFF9E6F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _iconFromName(item['icon_name']),
                      color: Color(0xFFB30059),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isArabic ? (item['text_ar'] ?? '') : (item['text_en'] ?? ''),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFB30059),
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

IconData _iconFromName(String? name) {
  switch (name) {
    case 'card_giftcard':
      return Icons.card_giftcard;
    case 'local_offer':
      return Icons.local_offer;
    default:
      return Icons.announcement_rounded;
  }
}

// -------- Gender Banner Carousel --------
class _GenderBannerCarousel extends StatelessWidget {
  final String gender;
  final String language;
  final double bannerHeight;
  const _GenderBannerCarousel({
    required this.gender,
    required this.language,
    this.bannerHeight = 270,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: SupabaseService.getGenderBanners(gender: gender, language: language),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: bannerHeight,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final data = snapshot.data!;
        if (data.isEmpty) return SizedBox(height: bannerHeight);
        return CarouselSlider(
          options: CarouselOptions(
            height: bannerHeight,
            viewportFraction: 1,
            autoPlay: data.length > 1,
            autoPlayInterval: Duration(seconds: 4),
            disableCenter: true,
          ),
          items: data.map((item) {
            return Container(
              width: double.infinity,
              height: bannerHeight,
              margin: EdgeInsets.symmetric(horizontal: 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item['image_url'] ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: bannerHeight,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// -------- Categories Grid (filtered by gender) --------
class _CategoriesGrid extends StatelessWidget {
  final String genderKey;
  const _CategoriesGrid({required this.genderKey});
  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    return SizedBox(
      height: 90,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: SupabaseService.getCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          final cats = snapshot.data!;
          final filteredCats = cats.where((cat) =>
            (cat['gender']?.toString().toLowerCase() ?? '') == genderKey.toLowerCase()
          ).toList();
          if (filteredCats.isEmpty)
            return Center(child: Text(isArabic ? 'لا توجد فئات' : 'No categories'));
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filteredCats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, idx) {
              final cat = filteredCats[idx];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryProductsPage(
                        categoryId: cat['uuid'].toString(),
                        categoryName: isArabic ? (cat['name_ar'] ?? '') : (cat['name_en'] ?? ''),
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: cat['icon'] != null && cat['icon'].toString().isNotEmpty
                        ? NetworkImage(cat['icon']) : null,
                      child: (cat['icon'] == null || cat['icon'].toString().isEmpty) ? Icon(Icons.category, size: 34, color: Colors.grey) : null,
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isArabic ? (cat['name_ar'] ?? '') : (cat['name_en'] ?? ''),
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -------- Products Horizontal List --------
class _ProductHorizontalList extends StatefulWidget {
  final String gender;
  final Map<String, dynamic> filter;
  final String? sortBy;
  final double listHeight;
  const _ProductHorizontalList({
    required this.gender,
    required this.filter,
    this.sortBy,
    this.listHeight = 285,
  });

  @override
  State<_ProductHorizontalList> createState() => _ProductHorizontalListState();
}

class _ProductHorizontalListState extends State<_ProductHorizontalList> {
  Set<String> wishlist = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final ids = await SupabaseService.getWishlist();
    setState(() => wishlist = ids);
  }

  Future<void> _toggleWishlist(String productId) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<LanguageProvider>().isArabic
              ? 'يرجى تسجيل الدخول لإضافة للمفضلة'
              : 'Please login to add to wishlist',
        ),
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }

  setState(() => isLoading = true);
  await SupabaseService.toggleWishlist(productId);
  await _loadWishlist();
  setState(() => isLoading = false);
}


  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    return SizedBox(
      height: widget.listHeight,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: SupabaseService.getProducts(
          filters: {'gender': widget.gender, ...widget.filter},
          sortBy: widget.sortBy,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          final products = snapshot.data!;
          if (products.isEmpty) {
            return Center(child: Text(isArabic ? 'لا توجد منتجات' : 'No products.'));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: products.length,
            itemBuilder: (context, idx) {
              final prod = products[idx];
              final prodId = prod['id'].toString();
              final brandName = isArabic
                  ? (prod['brand']?['name_ar'] ?? '')
                  : (prod['brand']?['name_en'] ?? '');
              return _ProductListItem(
                name: isArabic ? (prod['name_ar'] ?? '') : (prod['name_en'] ?? ''),
                brand: brandName,
                image: prod['image_url'] ?? '',
                price: prod['price']?.toString() ?? '',
                isWished: wishlist.contains(prodId),
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
                onWishlistTap: () async => await _toggleWishlist(prodId),
              );
            },
          );
        },
      ),
    );
  }
}


// -------- Single Product List Item (No Card, Like Ounass) --------
class _ProductListItem extends StatelessWidget {
  final String name;
  final String brand;
  final String image;
  final String price;
  final bool isWished;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;

  const _ProductListItem({
    required this.name,
    required this.brand,
    required this.image,
    required this.price,
    this.isWished = false,
    this.onTap,
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 14, bottom: 6, top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: onTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 4 / 5,
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 40)),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8, right: 8,
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
          const SizedBox(height: 8),
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
          const SizedBox(height: 2),
          Text(
            name,
            style: GoogleFonts.playfairDisplay(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$price SAR',
            style: const TextStyle(
              color: Color(0xFFB30059),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
