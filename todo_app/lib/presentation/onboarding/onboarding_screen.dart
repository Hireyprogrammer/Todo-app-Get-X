import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/core/routes/app_pages.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/onboard.png',
                height: 300,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              const Text(
                'Get things done with TODo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipisicing. Maxime, tempore! Animi nemo aut atque, deleniti nihil dolorem repellendus.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Get.toNamed(Routes.SIGNIN),
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
} 