import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/controllers/auth_controller.dart';
import 'package:todo_app/core/widgets/base_screen.dart';
import 'package:todo_app/core/utils/notification_helper.dart';

class VerifyEmailScreen extends StatelessWidget {
  VerifyEmailScreen({Key? key}) : super(key: key);

  final TextEditingController _pinController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  final String email = Get.arguments['email'];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Verify Email',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_read_outlined,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Verification code sent to\n$email',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'Enter 6-digit code',
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => _authController.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyEmail,
                    child: const Text('Verify Email'),
                  )),
            const SizedBox(height: 16),
            Obx(() => Text(
                  _authController.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                )),
          ],
        ),
      ),
    );
  }

  void _verifyEmail() {
    final pin = _pinController.text.trim();
    
    if (pin.isEmpty) {
      NotificationHelper.showError('Please enter verification code');
      return;
    }

    if (pin.length != 6) {
      NotificationHelper.showError('Please enter a valid 6-digit code');
      return;
    }

    _authController.verifyEmail(email, pin).then((_) {
      NotificationHelper.showSuccess('Email verified successfully');
    }).catchError((error) {
      NotificationHelper.showError(error.toString());
    });
  }
} 