class ApiConstants {
  // For Android Emulator, use 10.0.2.2 instead of localhost
  // For Physical Device, use your computer's IP address (e.g., 192.168.1.100)
  static const String baseUrl = 'http://10.0.2.2:9000/api';
  
  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String verifyEmail = '/auth/verify-email';
  
  // Headers
  static Map<String, String> headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
} 