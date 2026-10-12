import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/bouncing_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    // Sign up logic simulation / API call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sign up successful! Please sign in with your email.'),
        backgroundColor: Color(0xFF1E88E5),
      ),
    );

    // Navigate to Login screen
    Navigator.of(context).pushReplacement(
      SmoothPageRoute(page: const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-Screen Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_login_sigup.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Subtle gradient overlay to keep inputs readable
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
            ),
          ),

          // 3. Back Button in Safe Area
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BouncingButton(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? const Color(0xFF1E293B).withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border:
                          isDark
                              ? Border.all(color: const Color(0xFF334155))
                              : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. Centered Sign Up Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.96)
                          : Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(28),
                  border:
                      isDark
                          ? Border.all(
                            color: const Color(0xFF334155),
                            width: 1.2,
                          )
                          : null,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF0F172A,
                      ).withValues(alpha: isDark ? 0.35 : 0.18),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Title
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? Colors.white : const Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Join Blue Panda today and discover great deals.',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isDark
                                  ? Colors.grey.shade400
                                  : const Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Full Name Field
                      CustomTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        prefixIcon: Icons.person_outline,
                        validator:
                            (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Enter your full name'
                                    : null,
                      ),
                      const SizedBox(height: 14),

                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        validator: Validators.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                          ),
                          onPressed:
                              () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Confirm Password Field
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        prefixIcon: Icons.lock_reset_outlined,
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),

                      // Submit Button with Bouncing Tap
                      BouncingButton(
                        onTap: authProvider.isLoading ? null : _handleSignUp,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E88E5),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF1E88E5,
                                ).withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Switch to Sign In
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(
                              color:
                                  isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                SmoothPageRoute(page: const LoginScreen()),
                              );
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Color(0xFF1E88E5),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

