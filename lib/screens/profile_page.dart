import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../providers/language_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final data = await SupabaseService.getCurrentUserProfile();
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final toggleLanguage = context.read<LanguageProvider>().toggleLanguage;
    final textStyle = isArabic ? GoogleFonts.cairo() : GoogleFonts.playfairDisplay();
    final title = isArabic ? 'الملف الشخصي' : 'Profile';
    final languageText = isArabic ? 'English' : 'العربية';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            title,
            style: textStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : userData == null
                ? Center(
                    child: Text(
                      isArabic
                          ? 'تعذر تحميل بيانات الملف الشخصي'
                          : 'Failed to load profile data',
                      style: textStyle,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: userData!['avatar_url'] != null && userData!['avatar_url'] != ''
                              ? NetworkImage(userData!['avatar_url'])
                              : null,
                          child: (userData!['avatar_url'] == null || userData!['avatar_url'] == '')
                              ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userData!['first_name'] ?? '-',
                          style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(userData!['email'] ?? '-', style: textStyle.copyWith(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(userData!['mobile'] ?? '-', style: textStyle.copyWith(fontSize: 14)),
                        const SizedBox(height: 16),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        _buildProfileRow(
                            isArabic ? 'تاريخ الميلاد' : 'Date of Birth',
                            userData!['dob'] ?? '-',
                            textStyle),
                        const SizedBox(height: 12),
                        _buildProfileRow(
                            isArabic ? 'الجنس' : 'Gender',
                            userData!['gender'] ?? '-',
                            textStyle),
                        const SizedBox(height: 12),
                        _buildProfileRow(
                            isArabic ? 'السيرة الذاتية' : 'Bio',
                            userData!['bio'] ?? '-',
                            textStyle),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, TextStyle textStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle.copyWith(fontWeight: FontWeight.w500)),
        Flexible(
          child: Text(
            value,
            style: textStyle.copyWith(color: Colors.grey[800]),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
