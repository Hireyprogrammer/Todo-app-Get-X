import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  // Auth Logging
  static void authStart(String method) => _logger.i('🔐 Starting $method...');
  static void authSuccess(String method) => _logger.i('✅ $method successful!');
  static void authError(String method, dynamic error) => _logger.e('❌ $method failed: $error');

  // API Logging
  static void apiRequest(String endpoint) => _logger.i('🌐 API Request to: $endpoint');
  static void apiResponse(String endpoint, dynamic data) => _logger.d('📩 Response from $endpoint: $data');
  static void apiError(String endpoint, dynamic error) => _logger.e('💥 API Error at $endpoint: $error');

  // Navigation Logging
  static void navigation(String from, String to) => _logger.i('🔄 Navigation: $from ➡️ $to');

  // Storage Logging
  static void storageOperation(String operation) => _logger.i('💾 Storage: $operation');
  static void storageError(String operation, dynamic error) => _logger.e('📛 Storage Error during $operation: $error');

  // Connectivity Logging
  static void connectionStatus(bool isConnected) => 
      _logger.i(isConnected ? '🌍 Connected to internet' : '📡 No internet connection');

  // Validation Logging
  static void validationError(String field, String message) => _logger.w('⚠️ Validation Error - $field: $message');

  // General Logging
  static void info(String message) => _logger.i('ℹ️ $message');
  static void warning(String message) => _logger.w('⚠️ $message');
  static void error(String message, [dynamic error]) => _logger.e('❌ $message ${error ?? ''}');
  static void debug(String message) => _logger.d('🔍 $message');
} 