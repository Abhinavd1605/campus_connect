import 'dart:ui';

import 'package:campus_connect/screens/auth/register_screen.dart';
import 'package:campus_connect/services/auth_service.dart';
import 'package:campus_connect/utils/app_styles.dart';
import 'package:campus_connect/utils/custom_page_route.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final user = await _authService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to sign in. Please check your credentials.'),
              backgroundColor: AppStyles.error,
            ),
          );
        }
      }
    }
  }

  void _showPasswordResetDialog() {
    final _resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: _resetEmailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _authService.sendPasswordResetEmail(
                    _resetEmailController.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset email sent.'),
                  ),
                );
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppStyles.primaryGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyles.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppStyles.logoWithBackground(width: 80, height: 80),
                const SizedBox(height: AppStyles.marginLarge),
                Text(
                  'Campus Connect',
                  style: AppStyles.textTheme.headlineLarge?.copyWith(color: AppStyles.textLight, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppStyles.marginLarge),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(AppStyles.paddingLarge),
                      decoration: AppStyles.glassmorphismBoxDecoration(context),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              'Login',
                              style: AppStyles.textTheme.headlineSmall?.copyWith(color: AppStyles.textDark, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: AppStyles.marginMedium),
                            TextFormField(
                              controller: _emailController,
                              decoration: _buildInputDecoration('Email'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppStyles.marginMedium),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: _buildInputDecoration('Password'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppStyles.marginLarge),
                            if (_isLoading)
                              const CircularProgressIndicator(color: AppStyles.primaryColor)
                            else
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _login,
                                  child: const Text('Login'),
                                ),
                              ),
                            const SizedBox(height: AppStyles.marginMedium),
                            TextButton(
                              onPressed: _showPasswordResetDialog,
                              child: Text(
                                'Forgot Password?',
                                style: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: AppStyles.marginMedium),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  CustomPageRoute(
                                    child: const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Don\'t have an account? Register',
                                style: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: AppStyles.marginMedium),
                            Text(
                              'Or sign in with',
                              style: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.textMedium),
                            ),
                            const SizedBox(height: AppStyles.marginMedium),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await _authService.signInWithGoogle();
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                                  icon: const Icon(Icons.g_mobiledata,
                                      color: AppStyles.primaryColor, size: 40),
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
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppStyles.accentGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        child: Text(text, style: AppStyles.textTheme.labelLarge),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }
} 