import 'package:get/get.dart';
import 'package:todo_app/services/auth_service.dart';
import 'package:todo_app/services/storage_service.dart';
import 'package:todo_app/core/routes/app_pages.dart';
import 'package:todo_app/core/widgets/loading_overlay.dart';
import 'package:todo_app/core/services/logger_service.dart';
import 'package:todo_app/core/utils/notification_helper.dart';
import 'package:todo_app/controllers/task_controller.dart';
import 'package:flutter/widgets.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final StorageService _storage = Get.find<StorageService>();
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Add back the auth state listener
    ever(isAuthenticated, handleAuthenticationChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAuthStatus();
    });
  }

  void checkAuthStatus() {
    final token = _storage.getToken();
    if (token != null) {
      isAuthenticated.value = true;
      Get.offAllNamed(Routes.HOME);
    } else {
      // Check if onboarding is completed
      if (_storage.isOnboardingComplete()) {
        Get.offAllNamed(Routes.SIGNIN);
      } else {
        Get.offAllNamed(Routes.ONBOARDING);
      }
    }
  }

  void handleAuthenticationChanged(bool authenticated) {
    if (!authenticated) {
      // No token -> Go to SignIn
      Get.offAllNamed(Routes.SIGNIN);
    } else {
      // Has token -> Go to Home
      Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> signUp(String username, String email, String password) async {
    AppLogger.info('Starting signup process for: $email');
    try {
      LoadingOverlay.show();
      errorMessage.value = '';
      
      await _authService.register(username, email, password);
      AppLogger.navigation('SignUp', 'VerifyEmail');
        LoadingOverlay.hide();
      Get.toNamed(Routes.VERIFY_EMAIL, arguments: {'email': email});
    } catch (e) {
      AppLogger.error('Signup process failed', e);
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      LoadingOverlay.hide();
    }
  }

  Future<void> verifyEmail(String email, String pin) async {
    try {
      LoadingOverlay.show();
      errorMessage.value = '';
      
      await _authService.verifyEmail(email, pin);
      NotificationHelper.showSuccess('Email verified successfully');
      Get.toNamed(Routes.SIGNIN);
    } catch (e) {
      NotificationHelper.showError(e.toString());
      errorMessage.value = e.toString();
    } finally {
      LoadingOverlay.hide();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      LoadingOverlay.show();
      
      final token = await _authService.login(email, password);
      await _storage.saveToken(token);
      
      isAuthenticated.value = true;
      NotificationHelper.showSuccess('Welcome back!');
    } catch (e) {
      isAuthenticated.value = false;
      NotificationHelper.showError(e.toString());
    } finally {
      LoadingOverlay.hide();
    }
  }

  Future<void> logout() async {
    try {
      await _storage.removeToken();
      isAuthenticated.value = false;
    } catch (e) {
      NotificationHelper.showError(e.toString());
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  bool validatePassword(String password) {
    return password.length >= 8 && 
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password) &&
           RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }
} 