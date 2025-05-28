import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/theme.dart';
import 'package:music_app/logic/auth_bloc.dart';
import 'package:music_app/logic/auth_event.dart';
import 'package:music_app/logic/auth_state.dart';
import 'package:music_app/presentation/screens/home/home.dart';
import 'package:music_app/presentation/screens/account/register.dart';
import 'package:music_app/presentation/screens/account/google_sign_in_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ email và mật khẩu")),
      );
      return;
    }

    context.read<AuthBloc>().add(AuthLoginRequested(email, password));
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final userCredential = await GoogleSignInHelper.signInWithGoogle();
      if (userCredential == null) return; // Người dùng hủy
      // Nếu dùng Bloc, Bloc sẽ tự chuyển sang trang chính
      // Nếu không, bạn có thể điều hướng ở đây nếu muốn
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng nhập Google thất bại: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SlideTransition(
              position: _slideAnimation,
              child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }

                  if (state is AuthAuthenticated) {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (_) => const MusicApp(),
                    ));
                  }
                },
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.music_note, size: 100, color: AppColors.primary),
                        const SizedBox(height: 32),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Mật khẩu",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : () => _onLoginPressed(context),
                              child: isLoading
                                  ? const CircularProgressIndicator(color: AppColors.white)
                                  : const Text("Đăng nhập"),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: Image.asset(
                              'assets/google.png',
                              height: 24,
                            ),
                            label: const Text("Đăng nhập với Google"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.text,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _signInWithGoogle(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Chưa có tài khoản?"),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => RegisterPage()),
                                );
                              },
                              child: const Text("Đăng ký"),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
