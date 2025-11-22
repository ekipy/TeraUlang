import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tera_ulang/widgets/wave_background.dart';
import '../services/presence_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;

  double _opacity = 0.0;
  Offset _offset = const Offset(0, 0.1);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
        _offset = Offset.zero;
      });
    });
  }

  void login() async {
    setState(() => loading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      PresenceService.setupPresence();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text("Login gagal: $e")));
    }
    setState(() => loading = false);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: Color(0xFF0D47A1)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }

  Widget _loadingDots() {
    return SizedBox(
      height: 24.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            height: 8.w,
            width: 8.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            transform: Matrix4.translationValues(
              0,
              loading
                  ? (index == 0
                        ? -5
                        : index == 1
                        ? -10
                        : -5)
                  : 0,
              0,
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WaveBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              offset: _offset,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeIn,
                opacity: _opacity,
                child: Column(
                  children: [
                    /// Logo Animasi
                    AnimatedScale(
                      scale: _opacity,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      child: Image.asset(
                        'assets/Logo.png',
                        height: 100.h,
                        width: 100.w,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    /// Card Login
                    Container(
                      padding: EdgeInsets.all(24.w),
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Tera Ulang",
                            style: GoogleFonts.poppins(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D47A1),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          TextField(
                            key: const Key('emailField'),
                            controller: emailController,
                            decoration: _inputDecoration("Email", Icons.email),
                          ),
                          SizedBox(height: 16.h),
                          TextField(
                            key: const Key('passwordField'),
                            controller: passwordController,
                            obscureText: true,
                            decoration: _inputDecoration(
                              "Password",
                              Icons.lock,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          /// Tombol login
                          ElevatedButton(
                            key: const Key('loginButton'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D47A1),
                              elevation: 0,
                              minimumSize: Size(double.infinity, 50.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            onPressed: loading ? null : login,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) =>
                                      FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                              child: loading
                                  ? _loadingDots()
                                  : Text(
                                      "Login",
                                      key: const ValueKey('loginText'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
