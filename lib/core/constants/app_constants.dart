import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const String appName = "Matrimonial App";
  static const String appTagline = "Trusted Family Matrimonial Platform";
  
  static String get baseUrl {
    // 1. Check .env file loaded via flutter_dotenv
    try {
      if (dotenv.isInitialized) {
        final dotEnvUrl = dotenv.env['API_BASE_URL'];
        if (dotEnvUrl != null && dotEnvUrl.trim().isNotEmpty) {
          return dotEnvUrl.trim();
        }
      }
    } catch (_) {}

    // 2. Check build flag (--dart-define=API_BASE_URL=https://your-server.com)
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // 3. Platform-specific local fallbacks
    if (kIsWeb) return "http://localhost:8000";
    try {
      if (Platform.isAndroid) return "http://192.168.168.120:8000";
    } catch (_) {}
    return "http://127.0.0.1:8000";
  }
  
  // Storage Keys
  static const String tokenKey = "auth_jwt_token";
  static const String refreshTokenKey = "auth_refresh_token";
  static const String parentIdKey = "parent_id";
  static const String parentNameKey = "parent_name";
  static const String parentEmailKey = "parent_email";
}
