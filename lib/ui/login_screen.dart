// lib/ui/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
import 'app_style.dart';
import 'signup_screen.dart';
import 'todo_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  void _onGoogleSignInPressed() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PLACED HERE: The Stack wraps your whole body layout
      body: Stack(
        children: [
          // 1. Top Curved Canvas Banner Background
          SizedBox(
            height: 260,
            width: double.infinity,
            child: CustomPaint(painter: HeaderWavePainter()),
          ),

          // 2. Foreground Scrollable Form Card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppStyles.primaryViolet,
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const TodoScreen()),
                      );
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return AppStyles.buildCardContainer(
                      padding: const EdgeInsets.all(28.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppStyles.buildHeaderTitle(
                                  'Welcome Back 👋',
                                  subtitle: 'Sign in to access your dashboard',
                                )
                                .animate()
                                .fade(duration: 400.ms)
                                .slideY(
                                  begin: -0.2,
                                  end: 0,
                                  curve: Curves.easeOut,
                                ),

                            const SizedBox(height: 28),

                            TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email Address',
                                    prefixIcon: Icon(
                                      Icons.mail_outline_rounded,
                                      color: AppStyles.primaryViolet,
                                    ),
                                  ),
                                  validator: (val) =>
                                      val == null || !val.contains('@')
                                      ? 'Enter a valid email'
                                      : null,
                                )
                                .animate()
                                .fade(delay: 100.ms, duration: 400.ms)
                                .slideX(begin: -0.05, end: 0),

                            const SizedBox(height: 16),

                            TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      color: AppStyles.primaryViolet,
                                    ),
                                  ),
                                  validator: (val) =>
                                      val == null || val.length < 6
                                      ? 'Minimum 6 characters'
                                      : null,
                                )
                                .animate()
                                .fade(delay: 200.ms, duration: 400.ms)
                                .slideX(begin: -0.05, end: 0),

                            const SizedBox(height: 24),

                            SizedBox(
                                  width: double.infinity,
                                  child: AppStyles.buildPrimaryButton(
                                    text: 'Log In',
                                    isLoading: isLoading,
                                    onPressed: isLoading
                                        ? null
                                        : _onLoginPressed,
                                  ),
                                )
                                .animate()
                                .fade(delay: 300.ms, duration: 400.ms)
                                .scale(begin: const Offset(0.96, 0.96)),

                            const SizedBox(height: 20),

                            Row(
                              children: const [
                                Expanded(
                                  child: Divider(color: AppStyles.borderLight),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: AppStyles.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: AppStyles.borderLight),
                                ),
                              ],
                            ).animate().fade(delay: 350.ms, duration: 300.ms),

                            const SizedBox(height: 20),

                            SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: OutlinedButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : _onGoogleSignInPressed,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppStyles.borderLight,
                                        width: 1.5,
                                      ),
                                      backgroundColor: const Color(0xFFF8FAFC),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: Image.network(
                                      'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                                      height: 20,
                                      width: 20,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.g_mobiledata_rounded,
                                                size: 28,
                                                color: AppStyles.primaryViolet,
                                              ),
                                    ),
                                    label: const Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppStyles.textPrimary,
                                      ),
                                    ),
                                  ),
                                )
                                .animate()
                                .fade(delay: 400.ms, duration: 400.ms)
                                .scale(begin: const Offset(0.96, 0.96)),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account?",
                                  style: TextStyle(
                                    color: AppStyles.textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: AppStyles.primaryViolet,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate().fade(delay: 450.ms, duration: 400.ms),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
