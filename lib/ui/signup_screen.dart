// lib/ui/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
import 'app_style.dart';
import 'login_screen.dart';
import 'todo_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: VibrantMeshPainter(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                            'Get Started 🚀',
                            subtitle: 'Create your account to continue',
                          )
                              .animate()
                              .fade(duration: 400.ms)
                              .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),

                          const SizedBox(height: 28),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.mail_outline_rounded,
                                  color: AppStyles.primaryViolet),
                            ),
                            validator: (val) => val == null || !val.contains('@')
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
                              prefixIcon: Icon(Icons.lock_outline_rounded,
                                  color: AppStyles.primaryViolet),
                            ),
                            validator: (val) => val == null || val.length < 6
                                ? 'Minimum 6 characters'
                                : null,
                          )
                              .animate()
                              .fade(delay: 200.ms, duration: 400.ms)
                              .slideX(begin: -0.05, end: 0),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: Icon(Icons.shield_outlined,
                                  color: AppStyles.primaryViolet),
                            ),
                            validator: (val) => val != _passwordController.text
                                ? 'Passwords do not match'
                                : null,
                          )
                              .animate()
                              .fade(delay: 300.ms, duration: 400.ms)
                              .slideX(begin: -0.05, end: 0),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: AppStyles.buildPrimaryButton(
                              text: 'Create Account',
                              isLoading: isLoading,
                              onPressed: isLoading ? null : _onSignUpPressed,
                            ),
                          )
                              .animate()
                              .fade(delay: 400.ms, duration: 400.ms)
                              .scale(begin: const Offset(0.96, 0.96)),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account?',
                                  style: TextStyle(color: AppStyles.textSecondary)),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Log In',
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
      ),
    );
  }
}