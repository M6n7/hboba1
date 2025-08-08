import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

// Import your actual page widgets here
import 'home_page.dart';
import 'all_categories_page.dart';
import 'all_brands_page.dart';
import 'all_celebrities_page.dart';
import 'profile_page.dart';

class MainTabScaffold extends StatefulWidget {
  final String gender; // Pass the selected gender here (e.g., 'men', 'women', etc.)
  const MainTabScaffold({Key? key, required this.gender}) : super(key: key);

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  int _selectedIndex = 0;

  // Define the list of tab widgets
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(gender: widget.gender),
      AllCategoriesPage(gender: widget.gender),
      AllBrandsPage(genderKey: widget.gender),
      AllCelebritiesPage(genderKey: widget.gender),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFB30059),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 13,
          unselectedFontSize: 12,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              label: isArabic ? 'الرئيسية' : 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.category_outlined),
              label: isArabic ? 'الفئات' : 'Categories',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.star_border),
              label: isArabic ? 'الماركات' : 'Brands',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.emoji_emotions_outlined),
              label: isArabic ? 'المشاهير' : 'Celebrities',
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
