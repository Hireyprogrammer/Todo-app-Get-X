import 'package:get/get.dart';
import 'package:todo_app/services/auth_service.dart';
import 'package:todo_app/services/storage_service.dart';
import 'package:todo_app/core/routes/app_pages.dart';
import 'package:todo_app/core/widgets/loading_overlay.dart';
import 'package:todo_app/core/services/logger_service.dart';
import 'package:todo_app/core/utils/notification_helper.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuth();
  }

  void checkAuth() {
    if (_storage.isLoggedIn) {
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
      // LoadingOverlay.show();
      errorMessage.value = '';
      
      final token = await _authService.login(email, password);
      NotificationHelper.showSuccess('Welcome back!');
       LoadingOverlay.hide();
      Get.offAllNamed(Routes.HOME);
       
    } catch (e) {
      NotificationHelper.showError(e.toString());
      errorMessage.value = e.toString();
    } finally {
      LoadingOverlay.hide();
    }
  }

  Future<void> logout() async {
    try {
      LoadingOverlay.show();
      await _authService.logout();
      NotificationHelper.showSuccess('Logged out successfully');
      Get.offAllNamed(Routes.SIGNIN);
    } catch (e) {
      NotificationHelper.showError(e.toString());
    } finally {
      LoadingOverlay.hide();
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