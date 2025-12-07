import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/models.dart';

/// Plug-and-play API middleware for AWS Lambda
/// 
/// Automatically handles:
/// - Debug mode (mock data) vs Production mode (real AWS calls)
/// - Multi-region support
/// - Error handling
/// - Authentication headers
/// - JSON serialization
/// 
/// Just plug in your Lambda URLs in config.dart and it works!
class ApiClient {
  String? _authToken;
  
  /// Set authentication token (JWT from Cognito)
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Main request method - handles both debug and production modes
  Future<ApiResponse<T>> request<T>({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    // DEBUG MODE: Return mock data
    if (AppConfig.isDebugMode) {
      return _getMockResponse<T>(endpoint, method, body);
    }

    // PRODUCTION MODE: Make real AWS Lambda calls
    try {
      final url = Uri.parse('${AppConfig.currentLambdaUrl}$endpoint');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'X-Region': AppConfig.currentRegion,
      };

      // Add auth token if required
      if (requiresAuth && _authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers).timeout(AppConfig.requestTimeout);
          break;
        case 'POST':
          response = await http.post(url, headers: headers, body: jsonEncode(body)).timeout(AppConfig.requestTimeout);
          break;
        case 'PUT':
          response = await http.put(url, headers: headers, body: jsonEncode(body)).timeout(AppConfig.requestTimeout);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers).timeout(AppConfig.requestTimeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        errorType: ApiErrorType.networkError,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(http.Response response) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    // Success responses (200-299)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse<T>(
        success: true,
        data: data['data'] as T?,
        message: data['message'] as String?,
      );
    }

    // Error responses
    ApiErrorType errorType;
    switch (response.statusCode) {
      case 401:
        errorType = ApiErrorType.sessionExpired;
        break;
      case 403:
        errorType = ApiErrorType.wafBlocked;
        break;
      case 429:
        errorType = ApiErrorType.rateLimitExceeded;
        break;
      case 404:
        errorType = ApiErrorType.notFound;
        break;
      default:
        errorType = ApiErrorType.serverError;
    }

    return ApiResponse<T>(
      success: false,
      errorType: errorType,
      message: data['message'] as String? ?? 'Request failed',
    );
  }

  /// Generate mock responses for debug mode
  Future<ApiResponse<T>> _getMockResponse<T>(String endpoint, String method, Map<String, dynamic>? body) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock authentication endpoints
    if (endpoint == AppConfig.authSignInEndpoint) {
      return ApiResponse<T>(
        success: true,
        data: {
          'token': 'mock_jwt_token_12345',
          'user': {
            'id': 'user_123',
            'email': body?['email'] ?? 'demo@example.com',
            'name': 'Demo User',
            'mfaEnabled': true,
          },
          'requiresMfa': true,
        } as T,
        message: 'Sign in successful',
      );
    }

    if (endpoint == AppConfig.authSignUpEndpoint) {
      return ApiResponse<T>(
        success: true,
        data: {
          'user': {
            'id': 'user_new_123',
            'email': body?['email'] ?? 'newuser@example.com',
            'name': body?['name'] ?? 'New User',
          },
        } as T,
        message: 'Account created successfully',
      );
    }

    if (endpoint == AppConfig.authMfaEndpoint) {
      return ApiResponse<T>(
        success: true,
        data: {
          'token': 'mock_jwt_token_verified_67890',
          'user': {
            'id': 'user_123',
            'email': 'demo@example.com',
            'name': 'Demo User',
          },
        } as T,
        message: 'MFA verified',
      );
    }

    if (endpoint == AppConfig.authForgotPasswordEndpoint) {
      return ApiResponse<T>(
        success: true,
        message: 'Password reset email sent',
      );
    }

    // Mock URL endpoints
    if (endpoint == AppConfig.urlsListEndpoint) {
      return ApiResponse<T>(
        success: true,
        data: {
          'urls': [
            {
              'id': 'url_1',
              'originalUrl': 'https://example.com/very-long-url',
              'shortCode': 'abc123',
              'shortUrl': 'https://short.link/abc123',
              'clickCount': 1234,
              'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
              'isActive': true,
            },
            {
              'id': 'url_2',
              'originalUrl': 'https://github.com/flutter/flutter',
              'shortCode': 'xyz789',
              'shortUrl': 'https://short.link/xyz789',
              'clickCount': 567,
              'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
              'isActive': true,
            },
            {
              'id': 'url_3',
              'originalUrl': 'https://docs.flutter.dev',
              'shortCode': 'def456',
              'shortUrl': 'https://short.link/def456',
              'clickCount': 89,
              'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
              'isActive': true,
            },
          ],
          'total': 3,
        } as T,
        message: 'URLs retrieved successfully',
      );
    }

    if (endpoint == AppConfig.urlsCreateEndpoint) {
      final customCode = body?['customCode'] as String?;
      final shortCode = customCode ?? _generateRandomCode();
      
      return ApiResponse<T>(
        success: true,
        data: {
          'url': {
            'id': 'url_new_${DateTime.now().millisecondsSinceEpoch}',
            'originalUrl': body?['originalUrl'] ?? '',
            'shortCode': shortCode,
            'shortUrl': 'https://short.link/$shortCode',
            'clickCount': 0,
            'createdAt': DateTime.now().toIso8601String(),
            'isActive': true,
          },
        } as T,
        message: 'URL created successfully',
      );
    }

    if (endpoint.startsWith(AppConfig.urlsAnalyticsEndpoint)) {
      return ApiResponse<T>(
        success: true,
        data: {
          'analytics': {
            'clicksByDate': {
              '2024-12-01': 45,
              '2024-12-02': 67,
              '2024-12-03': 89,
              '2024-12-04': 123,
              '2024-12-05': 98,
              '2024-12-06': 156,
              '2024-12-07': 134,
            },
            'clicksByCountry': {
              'United States': 234,
              'United Kingdom': 123,
              'Germany': 89,
              'Japan': 67,
              'Canada': 45,
            },
            'clicksByDevice': {
              'Mobile': 345,
              'Desktop': 234,
              'Tablet': 89,
            },
          },
        } as T,
        message: 'Analytics retrieved successfully',
      );
    }

    // Default mock response
    return ApiResponse<T>(
      success: true,
      message: 'Mock response for $endpoint',
    );
  }

  /// Generate random short code
  String _generateRandomCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      List.generate(6, (index) => chars.codeUnitAt(DateTime.now().millisecondsSinceEpoch % chars.length + index % chars.length)),
    );
  }

  // ============================================
  // Convenience methods for common operations
  // ============================================

  /// Sign in with email and password
  Future<ApiResponse<Map<String, dynamic>>> signIn(String email, String password) {
    return request<Map<String, dynamic>>(
      endpoint: AppConfig.authSignInEndpoint,
      method: 'POST',
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );
  }

  /// Sign up new user
  Future<ApiResponse<Map<String, dynamic>>> signUp({
    required String email,
    required String password,
    required String name,
  }) {
    return request<Map<String, dynamic>>(
      endpoint: AppConfig.authSignUpEndpoint,
      method: 'POST',
      body: {'email': email, 'password': password, 'name': name},
      requiresAuth: false,
    );
  }

  /// Verify MFA code
  Future<ApiResponse<Map<String, dynamic>>> verifyMfa(String code) {
    return request<Map<String, dynamic>>(
      endpoint: AppConfig.authMfaEndpoint,
      method: 'POST',
      body: {'code': code},
      requiresAuth: false,
    );
  }

  /// Forgot password
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(String email) {
    return request<Map<String, dynamic>>(
      endpoint: AppConfig.authForgotPasswordEndpoint,
      method: 'POST',
      body: {'email': email},
      requiresAuth: false,
    );
  }

  /// Get all URLs
  Future<ApiResponse<Map<String, dynamic>>> getUrls() {
    return request<Map<String, dynamic>>(
      endpoint: AppConfig.urlsListEndpoint,
      method: 'GET',
    );
  }

  /// Create new URL
  Future<ApiResponse<Map<String, dynamic>>> createUrl({
    required String originalUrl,
    String? customCode,
  }) {
    return request<Map<String, dynamic>>(
      endpoint: AppConfig.urlsCreateEndpoint,
      method: 'POST',
      body: {'originalUrl': originalUrl, 'customCode': customCode},
    );
  }

  /// Get URL analytics
  Future<ApiResponse<Map<String, dynamic>>> getAnalytics(String urlId) {
    return request<Map<String, dynamic>>(
      endpoint: '${AppConfig.urlsAnalyticsEndpoint}/$urlId',
      method: 'GET',
    );
  }

  /// Delete URL
  Future<ApiResponse<Map<String, dynamic>>> deleteUrl(String urlId) {
    return request<Map<String, dynamic>>(
      endpoint: '${AppConfig.urlsDeleteEndpoint}/$urlId',
      method: 'DELETE',
    );
  }
}
