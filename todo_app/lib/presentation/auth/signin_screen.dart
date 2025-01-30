import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/core/routes/app_pages.dart';
import 'package:todo_app/controllers/auth_controller.dart';
import 'package:todo_app/core/utils/notification_helper.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  void _validateAndSignIn() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      NotificationHelper.showError('Please fill all fields');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      NotificationHelper.showError('Please enter a valid email');
      return;
    }

    _authController.signIn(email, password).then((_) {
      // NotificationHelper.showSuccess('Login successful');
    }).catchError((error) {
      NotificationHelper.showError(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
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
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Image.asset(
                  'assets/images/login.png',
                  height: 280,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter your Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: !_authController.isPasswordVisible.value,
                decoration: InputDecoration(
                  hintText: 'Enter Password',
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
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 40),
              Obx(() => _authController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _validateAndSignIn,
                      icon: const Icon(Icons.login),
                      label: const Text('Sign In'),
                    )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton.icon(
                    onPressed: () => Get.toNamed(Routes.SIGNUP),
                    icon: const Icon(Icons.person_add_outlined, size: 18),
                    label: const Text('Sign Up'),
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