import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'home_page.dart';
import 'signup_page.dart';
import '../providers/language_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String errorText = '';

  Future<void> login() async {
    setState(() {
      loading = true;
      errorText = '';
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final firstName = prefs.getString('first_name') ?? '';
        final mobile = prefs.getString('mobile') ?? '';
        final emailSaved = prefs.getString('email') ?? user.email ?? '';

        // ✅ Ensure we get a fresh token from Supabase
        final session = supabase.auth.currentSession;
        final token = session?.accessToken;

        if (token != null) {
          final edgeResponse = await http.post(
            Uri.parse('https://yzqbojvyorjrtevwblng.functions.supabase.co/insert-profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'id': user.id,
              'first_name': firstName,
              'last_name': '',
              'email': emailSaved,
              'mobile': mobile,
              'dob': null,
              'gender': '',
              'avatar_url': '',
              'bio': '',
            }),
          );

          if (edgeResponse.statusCode != 200) {
            print('Edge Function error: ${edgeResponse.body}');
          }
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        setState(() {
          errorText = context.read<LanguageProvider>().isArabic ? 'فشل تسجيل الدخول' : 'Login failed';
        });
      }
    } catch (e) {
      setState(() {
        errorText = context.read<LanguageProvider>().isArabic
            ? 'حدث خطأ: $e'
            : 'An error occurred: $e';
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final toggleLanguage = context.read<LanguageProvider>().toggleLanguage;
    final langText = isArabic ? 'English' : 'العربية';
    final titleText = isArabic ? 'تسجيل الدخول' : 'Log In';
    final subtitleText = isArabic ? 'أهلاً بعودتك' : 'Welcome back';
    final emailHint = isArabic ? 'البريد الإلكتروني' : 'Email';
    final passwordHint = isArabic ? 'كلمة المرور' : 'Password';
    final loginText = isArabic ? 'تسجيل الدخول' : 'Log In';
    final orText = isArabic ? 'أو سجل عن طريق' : 'or Log in with';
    final bottomPrompt = isArabic ? 'ليس لديك حساب؟' : "Don't have an account?";
    final signupLink = isArabic ? 'إنشاء حساب' : 'Sign Up';
    final guestText = isArabic ? 'المتابعة كضيف' : 'Continue as Guest';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(color: Colors.black.withOpacity(0.4)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Align(
                        alignment: isArabic ? Alignment.topLeft : Alignment.topRight,
                        child: TextButton(
                          onPressed: () {
                            toggleLanguage();
                          },
                          child: Text(
                            langText,
                            style: const TextStyle(
                              color: Color(0xFFB30059),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                    Text(
                      titleText,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitleText,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildField(emailHint, emailController),
                    _buildField(passwordHint, passwordController, obscure: true),
                    if (errorText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(errorText, style: const TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB30059),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          loginText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(orText, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon('assets/icons/apple.png'),
                        const SizedBox(width: 16),
                        _buildSocialIcon('assets/icons/google.png'),
                        const SizedBox(width: 16),
                        _buildSocialIcon('assets/icons/facebook.png'),
                      ],
                    ),
                    const Spacer(flex: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bottomPrompt,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
                              ),
                            );
                          },
                          child: Text(
                            signupLink,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      },
                      child: Text(
                        guestText,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
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

  Widget _buildField(String hint, TextEditingController controller, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          labelText: hint,
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String assetPath) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.white,
      child: Image.asset(assetPath, width: 24, height: 24),
    );
  }
}
