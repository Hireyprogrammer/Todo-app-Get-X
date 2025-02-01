import 'package:get_storage/get_storage.dart';
import 'package:todo_app/core/services/logger_service.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find<StorageService>();
  
  final _box = GetStorage();
  static const _tokenKey = 'auth_token';
  static const _onboardingKey = 'onboarding_complete';

  Future<StorageService> init() async {
    await GetStorage.init();
    return this;
  }

  Future<void> saveToken(String token) async {
    try {
      await _box.write(_tokenKey, token);
      AppLogger.storageOperation('Token saved successfully');
    } catch (e) {
      AppLogger.storageError('saveToken', e);
      throw 'Failed to save token: $e';
    }
  }

  String? getToken() {
    try {
      return _box.read(_tokenKey);
    } catch (e) {
      AppLogger.storageError('getToken', e);
      return null;
    }
  }

  Future<void> removeToken() async {
    try {
      await _box.remove(_tokenKey);
      AppLogger.storageOperation('Token removed from storage');
    } catch (e) {
      AppLogger.storageError('removeToken', e);
      throw 'Failed to remove token: $e';
    }
  }

  bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // Onboarding methods
  bool isOnboardingComplete() {
    try {
      return _box.read(_onboardingKey) ?? false;
    } catch (e) {
      AppLogger.storageError('isOnboardingComplete', e);
      return false;
    }
  }

  Future<void> markOnboardingComplete() async {
    try {
      await _box.write(_onboardingKey, true);
      AppLogger.storageOperation('Onboarding marked as complete');
    } catch (e) {
      AppLogger.storageError('markOnboardingComplete', e);
      throw 'Failed to mark onboarding as complete: $e';
    }
  }
} 