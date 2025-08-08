// lib/screens/welcome_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // ⬅️ Add this
import '../providers/language_provider.dart'; // ⬅️ Add this, adjust path if needed
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key}); // No more isArabic/toggleLanguage

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final toggleLanguage = context.read<LanguageProvider>().toggleLanguage;
    final fontStyle = isArabic ? GoogleFonts.cairo() : GoogleFonts.playfairDisplay();
    final langText = isArabic ? 'English' : 'العربية';
    final welcomeText = isArabic ? 'حبابك في HBOBA' : 'Welcome to HBOBA';
    final subtitleText = isArabic
        ? 'تسوق أزياء سودانية أصيلة بذوق عصري فاخر'
        : 'Shop authentic Sudanese fashion with a touch of modernity.';
    final loginText = isArabic ? 'تسجيل الدخول' : 'Log In';
    final signupText = isArabic ? 'إنشاء حساب' : 'Sign Up';
    final guestText = isArabic ? 'المتابعة كضيف' : 'Continue as Guest';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/welcome_bg.jpg',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withOpacity(0.25)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          welcomeText,
                          style: fontStyle.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          subtitleText,
                          style: fontStyle.copyWith(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                          foregroundColor: Colors.white,
                          shadowColor: Colors.black26,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(signupText, style: fontStyle),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(loginText, style: fontStyle),
                      ),
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      splashColor: Colors.white24,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          guestText,
                          style: fontStyle.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => toggleLanguage(),
                      child: Text(
                        langText,
                        style: fontStyle.copyWith(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
