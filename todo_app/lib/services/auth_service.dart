import 'package:dio/dio.dart';
import 'package:todo_app/core/constants/api_constants.dart';
import 'package:todo_app/services/storage_service.dart';
import 'package:todo_app/core/services/logger_service.dart';
import 'package:get/get.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    validateStatus: (status) => status! < 500,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  
  final StorageService _storage = StorageService();

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    AppLogger.authStart('Registration');
    AppLogger.apiRequest('${ApiConstants.register} - User: $email');
    
    try {
      final response = await _dio.post(ApiConstants.register, data: {
        'username': username,
        'email': email,
        'password': password,
      });

     

      if (response.statusCode == 201) {
        AppLogger.authSuccess('Registration');
        AppLogger.apiResponse(ApiConstants.register, response.data);
        return response.data;
      }
      throw response.data['message'] ?? 'Registration faileds';
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw 'Unable to connect to server. Please check your internet connection.';
      }
      throw 'Registration failed: ${e.message}';
    } catch (e) {
      throw 'Registration failed: $e';
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String pin) async {
    try {
      final response = await _dio.post(ApiConstants.verifyEmail, data: {
        'email': email,
        'pin': pin,
      });

      if (response.statusCode == 200) {
        if (response.data['token'] != null) {
          await _storage.saveToken(response.data['token']);
        }
        return response.data;
      }
      throw response.data['message'] ?? 'Verification failed';
    } catch (e) {
      throw 'Verification failed: $e';
    }
  }

  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storage.saveToken(token);
        return token;
      }
      
      throw response.data['message'] ?? 'Login failed';
    } catch (e) {
      throw 'Login failed: $e';
    }
  }

  Future<void> logout() async {
    await _storage.removeToken();
 
  }

  Future<TokenResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      
      return TokenResponse.fromJson(response.data);
    } catch (e) {
      throw 'Failed to refresh token';
    }
  }
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;

  TokenResponse({required this.accessToken, required this.refreshToken});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
} 