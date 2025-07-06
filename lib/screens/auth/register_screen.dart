import 'dart:ui';

import 'package:campus_connect/screens/auth/login_screen.dart';
import 'package:campus_connect/services/auth_service.dart';
import 'package:campus_connect/utils/app_styles.dart';
import 'package:campus_connect/utils/custom_page_route.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _collegeController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final user = await _authService.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        college: _collegeController.text,
        department: _departmentController.text,
        year: _yearController.text,
        phone: _phoneController.text,
      );
      setState(() {
        _isLoading = false;
      });
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to register. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppStyles.primaryGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.paddingLarge, vertical: AppStyles.paddingLarge),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(AppStyles.paddingLarge),
                  decoration: AppStyles.glassmorphismBoxDecoration(context),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppStyles.logoWithBackground(width: 60, height: 60),
                        const SizedBox(height: AppStyles.marginLarge),
                        Text(
                          'Create Account',
                          style: AppStyles.textTheme.headlineSmall?.copyWith(color: AppStyles.textDark, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppStyles.marginMedium),
                        TextFormField(
                          controller: _nameController,
                          decoration: _buildInputDecoration('Name'),
                          validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                        ),
                        const SizedBox(height: AppStyles.marginMedium),
                        TextFormField(
                          controller: _collegeController,
                          decoration: _buildInputDecoration('College'),
                          validator: (value) => value!.isEmpty ? 'Enter a college' : null,
                        ),
                        const SizedBox(height: AppStyles.marginMedium),
                        TextFormField(
                          controller: _departmentController,
                          decoration: _buildInputDecoration('Department'),
                          validator: (value) => value!.isEmpty ? 'Enter a department' : null,
                        ),
                        const SizedBox(height: AppStyles.marginMedium),
                        TextFormField(
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('Year'),
                          validator: (value) => value!.isEmpty ? 'Enter a year' : null,
                        ),
                        const SizedBox(height: AppStyles.marginMedium),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _buildInputDecoration('Phone'),
                          validator: (value) => value!.isEmpty ? 'Enter a phone number' : null,
                        ),
                        const SizedBox(height: AppStyles.marginMedium),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
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
                              onPressed: _register,
                              child: const Text('Register'),
                            ),
                          ),
                        const SizedBox(height: AppStyles.marginMedium),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              CustomPageRoute(
                                child: const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Already have an account? Login',
                            style: AppStyles.textTheme.bodyMedium?.copyWith(color: AppStyles.primaryColor, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }
} 