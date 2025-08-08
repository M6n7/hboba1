import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import 'home_page.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool loading = false;
  String errorText = '';

  Future<void> signUp() async {
    setState(() {
      loading = true;
      errorText = '';
    });

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    final isArabic = context.read<LanguageProvider>().isArabic;

    if (password != confirmPassword) {
      setState(() {
        errorText = isArabic ? 'كلمة المرور غير متطابقة' : 'Passwords do not match';
        loading = false;
      });
      return;
    }

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'https://your-website.com/verified',
      );

      final user = response.user;

      if (user == null) {
        setState(() {
          errorText = isArabic ? 'فشل في إنشاء الحساب' : 'Sign-up failed';
          loading = false;
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('first_name', name);
      await prefs.setString('mobile', phone);
      await prefs.setString('email', email);
      await prefs.setString('password', password);

      setState(() {
        errorText = isArabic
            ? 'تم إرسال رابط التحقق إلى بريدك الإلكتروني'
            : 'A confirmation email has been sent. Please verify.';
      });
    } catch (e) {
      setState(() {
        errorText = context.read<LanguageProvider>().isArabic
            ? 'حدث خطأ: $e'
            : 'An error occurred: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final toggleLanguage = context.read<LanguageProvider>().toggleLanguage;

    final langText = isArabic ? 'English' : 'العربية';
    final titleText = isArabic ? 'سجل حساب جديد' : 'Sign Up';
    final subtitleText = isArabic ? 'استمتع بأناقة سودانية عصرية' : 'Discover modern Sudanese elegance';
    final nameHint = isArabic ? 'الاسم الكامل' : 'Full Name';
    final emailHint = isArabic ? 'البريد الإلكتروني' : 'Email';
    final phoneHint = isArabic ? 'رقم الجوال' : 'Phone Number';
    final passwordHint = isArabic ? 'كلمة المرور' : 'Password';
    final confirmPasswordHint = isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password';
    final signUpText = isArabic ? 'إنشاء حساب' : 'Sign Up';
    final orText = isArabic ? 'أو أنشئ الحساب عبر' : 'or Sign up with';
    final guestText = isArabic ? 'المتابعة كضيف' : 'Continue as Guest';
    final loginPrompt = isArabic ? 'هل لديك حساب؟' : 'Already have an account?';
    final loginText = isArabic ? 'تسجيل الدخول' : 'Log In';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/signup_bg.jpg'),
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
                          onPressed: toggleLanguage,
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
                    _buildField(nameHint, nameController),
                    _buildField(emailHint, emailController),
                    _buildField(phoneHint, phoneController),
                    _buildField(passwordHint, passwordController, obscure: true),
                    _buildField(confirmPasswordHint, confirmPasswordController, obscure: true),
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
                        onPressed: loading ? null : signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB30059),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          signUpText,
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
                          loginPrompt,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            loginText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
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
