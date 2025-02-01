import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/core/routes/app_pages.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:todo_app/services/storage_service.dart';

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
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(delay: 400.ms),
              const SizedBox(height: 40),
              const Text(
                'Get things done with TODo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )
              .animate()
              .fadeIn(delay: 800.ms)
              .moveX(begin: -30, end: 0),
              const SizedBox(height: 16),
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipisicing. Maxime, tempore! Animi nemo aut atque, deleniti nihil dolorem repellendus.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              )
              .animate()
              .fadeIn(delay: 1000.ms),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Mark onboarding as completed
                  StorageService.to.markOnboardingComplete();
                  Get.toNamed(Routes.SIGNIN);
                },
                child: const Text('Get Started'),
              )
              .animate()
              .fadeIn(delay: 1200.ms)
              .moveY(begin: 20, end: 0),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}