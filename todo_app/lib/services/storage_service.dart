import 'package:get_storage/get_storage.dart';
import 'package:todo_app/core/services/logger_service.dart';

class StorageService {
  final _box = GetStorage();
  static const _tokenKey = 'auth_token';

  Future<void> init() async {
    await GetStorage.init();
  }

  Future<void> saveToken(String token) async {
    print('DEBUG - Full Token: $token'); // Temporary debug print
    AppLogger.storageOperation('Storage: Saving auth token: $token');
    try {
      await _box.write(_tokenKey, token);
      AppLogger.storageOperation('Storage: Token saved successfully in GetStorage');
      
      // Verify stored token
      final storedToken = _box.read(_tokenKey);
      AppLogger.storageOperation('Storage: Verified stored token: $storedToken');
    } catch (e) {
      AppLogger.storageError('saveToken', e);
      rethrow;
    }
  }

  String? getToken() {
    final token = _box.read(_tokenKey);
    AppLogger.storageOperation('Storage: Current stored token: $token');
    return token;
  }

  Future<void> removeToken() async {
    await _box.remove(_tokenKey);
  }

  bool get isLoggedIn => getToken() != null;
} 