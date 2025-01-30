import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/core/routes/app_pages.dart';
import 'package:todo_app/controllers/auth_controller.dart';
import 'package:get/get_utils/get_utils.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _usernameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    final _authController = Get.find<AuthController>();

    void _validateAndSignUp() {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (username.isEmpty || email.isEmpty || password.isEmpty) {
        Get.snackbar('Error', 'Please fill all fields');
        return;
      }

      if (!GetUtils.isEmail(email)) {
        Get.snackbar('Error', 'Please enter a valid email');
        return;
      }

      if (!_authController.validatePassword(password)) {
        Get.snackbar('Error', 'Password must be at least 8 characters with uppercase, lowercase, number and special character');
        return;
      }

      if (password != confirmPassword) {
        Get.snackbar('Error', 'Passwords do not match');
        return;
      }

      _authController.signUp(username, email, password);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome Onboard!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Let's help you meet up your task",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter your Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => TextField(
                controller: _passwordController,
                obscureText: !_authController.isPasswordVisible.value,
                decoration: InputDecoration(
                  hintText: 'Create a Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _authController.isPasswordVisible.value 
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    ),
                    onPressed: _authController.togglePasswordVisibility,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              )),
              const SizedBox(height: 16),
              Obx(() => TextField(
                controller: _confirmPasswordController,
                obscureText: !_authController.isPasswordVisible.value,
                decoration: InputDecoration(
                  hintText: 'Confirm your Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _authController.isPasswordVisible.value 
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    ),
                    onPressed: _authController.togglePasswordVisibility,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              )),
              const SizedBox(height: 40),
              Obx(() => _authController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _validateAndSignUp,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Sign Up'),
                    )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton.icon(
                    onPressed: () => Get.toNamed(Routes.SIGNIN),
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('Sign In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 