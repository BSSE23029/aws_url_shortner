import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/foundation.dart';
import '../config.dart';
import '../models/models.dart';

void _log(String message) {
  if (kDebugMode) {
    print('🔵 API CLIENT: $message');
  }
}

class ApiClient {
  String? _authToken;
  late final CognitoUserPool _userPool;
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;

  ApiClient() {
    _log(
      'ApiClient: Initializing with UserPoolId: ${AppConfig.cognitoUserPoolId}',
    );
    _userPool = CognitoUserPool(
      AppConfig.cognitoUserPoolId,
      AppConfig.cognitoClientId,
    );
    _log('ApiClient: Initialization complete');
  }

  void setAuthToken(String token) {
    _log('setAuthToken: Setting auth token (length: ${token.length})');
    _authToken = token;
  }

  void clearAuthToken() {
    _log('clearAuthToken: Clearing auth token and Cognito session');
    _authToken = null;
    _cognitoUser = null;
    _session = null;
  }

  void _resetCognito() {
    _log('_resetCognito: Resetting Cognito user and session');
    _cognitoUser = null;
    _session = null;
  }

  Future<ApiResponse<Map<String, dynamic>>> signIn(
    String email,
    String password,
  ) async {
    _log('signIn: Starting sign-in for email: $email');
    // Clear any stale session data before attempting a new login
    _resetCognito();

    try {
      _log('signIn: Creating CognitoUser for email: $email');
      _cognitoUser = CognitoUser(email, _userPool);
      final authDetails = AuthenticationDetails(
        username: email,
        password: password,
      );

      _log('signIn: Authenticating user with Cognito');
      _session = await _cognitoUser!.authenticateUser(authDetails);

      if (_session == null || !_session!.isValid()) {
        _log('signIn: Invalid session received');
        throw CognitoClientException('Invalid session');
      }

      _log('signIn: Session valid, extracting tokens');
      final idToken = _session!.getIdToken().getJwtToken();
      setAuthToken(idToken!);

      _log('signIn: Fetching user attributes');
      final attributes = await _cognitoUser!.getUserAttributes();
      final attrMap = {
        for (var attr in attributes ?? []) attr.name!: attr.value,
      };
      _log('signIn: Retrieved ${attrMap.length} user attributes');

      final userId = _session!.getIdToken().payload['sub'];
      _log('signIn: Sign-in successful for user ID: $userId');

      return ApiResponse.success({
        'token': idToken,
        'user': {
          'id': userId,
          'email': attrMap['email'] ?? email,
          'name': attrMap['name'] ?? email,
          'createdAt': DateTime.now().toIso8601String(),
          'mfaEnabled': false,
        },
      });
    } on CognitoClientException catch (e) {
      _log('signIn: CognitoClientException - ${e.message}');
      return ApiResponse.error(message: e.message ?? "Authentication failed");
    } catch (e) {
      _log('signIn: Unknown error - $e');
      return ApiResponse.error(message: 'Unknown error occurred');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _log('signUp: Starting sign-up for email: $email, name: $name');
    try {
      final userAttributes = [
        AttributeArg(name: 'email', value: email),
        AttributeArg(name: 'name', value: name),
      ];
      _log(
        'signUp: Calling Cognito signUp with ${userAttributes.length} attributes',
      );
      final result = await _userPool.signUp(
        email,
        password,
        userAttributes: userAttributes,
      );
      _cognitoUser = result.user;
      final confirmationRequired = !(result.userConfirmed ?? false);
      _log(
        'signUp: Sign-up successful, confirmationRequired: $confirmationRequired',
      );
      return ApiResponse.success({
        'user': {'email': email, 'name': name},
        'confirmationRequired': confirmationRequired,
      });
    } on CognitoClientException catch (e) {
      _log('signUp: CognitoClientException - ${e.message}');
      return ApiResponse.error(message: e.message ?? "Sign up failed");
    } catch (e) {
      _log('signUp: Unknown error - $e');
      return ApiResponse.error(message: 'Error: $e');
    }
  }

  Future<ApiResponse<bool>> confirmAccount(String email, String code) async {
    _log('confirmAccount: Starting confirmation for email: $email');
    try {
      _cognitoUser = CognitoUser(email, _userPool);
      _log('confirmAccount: Confirming registration with code');
      final success = await _cognitoUser!.confirmRegistration(code);
      _log('confirmAccount: Confirmation result: $success');
      return ApiResponse.success(success);
    } catch (e) {
      _log('confirmAccount: Verification failed - $e');
      return ApiResponse.error(message: 'Verification failed');
    }
  }

  Future<ApiResponse<String>> resendConfirmationCode(String email) async {
    _log('resendConfirmationCode: Resending code for email: $email');
    try {
      _cognitoUser = CognitoUser(email, _userPool);
      _log('resendConfirmationCode: Calling resendConfirmationCode');
      await _cognitoUser!.resendConfirmationCode();
      _log('resendConfirmationCode: Code resent successfully');
      return ApiResponse.success('sent');
    } catch (e) {
      _log('resendConfirmationCode: Error - $e');
      return ApiResponse.error(message: 'Error resending code');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyMfa(String code) async {
    _log('verifyMfa: Starting MFA verification');
    try {
      if (_cognitoUser == null) {
        _log('verifyMfa: No cognitoUser found, session lost');
        return ApiResponse.error(message: 'Session lost');
      }
      _log('verifyMfa: Sending MFA code');
      _session = await _cognitoUser!.sendMFACode(code);
      if (_session != null && _session!.isValid()) {
        _log('verifyMfa: MFA code valid, extracting token');
        final idToken = _session!.getIdToken().getJwtToken();
        setAuthToken(idToken!);
        _log(
          'verifyMfa: MFA verification successful for user: ${_cognitoUser!.username}',
        );
        return ApiResponse.success({
          'token': idToken,
          'user': {'email': _cognitoUser!.username},
        });
      }
      _log('verifyMfa: Invalid MFA code or session');
      return ApiResponse.error(message: 'Invalid MFA Code');
    } catch (e) {
      _log('verifyMfa: MFA error - $e');
      return ApiResponse.error(message: 'MFA Error');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(String email) async {
    _log('forgotPassword: Starting password reset for email: $email');
    try {
      final user = CognitoUser(email, _userPool);
      _log('forgotPassword: Calling forgotPassword');
      await user.forgotPassword();
      _log('forgotPassword: Password reset initiated successfully');
      return ApiResponse.success({});
    } catch (e) {
      _log('forgotPassword: Reset error - $e');
      return ApiResponse.error(message: 'Reset error');
    }
  }

  Future<ApiResponse<T>> request<T>({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    _log('request: $method ${AppConfig.currentLambdaUrl}$endpoint');
    _log('request: requiresAuth=$requiresAuth, hasToken=${_authToken != null}');
    final url = Uri.parse('${AppConfig.currentLambdaUrl}$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (requiresAuth && _authToken != null)
        'Authorization': 'Bearer $_authToken',
    };
    if (body != null) _log('request: Body keys: ${body.keys.join(", ")}');

    try {
      http.Response response;
      if (method == 'GET') {
        _log('request: Executing GET request');
        response = await http.get(url, headers: headers);
      } else if (method == 'POST') {
        _log('request: Executing POST request');
        response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(body),
        );
      } else if (method == 'DELETE') {
        _log('request: Executing DELETE request');
        response = await http.delete(url, headers: headers);
      } else {
        _log('request: Unsupported method: $method');
        throw Exception('Method not supported');
      }

      _log('request: Response status: ${response.statusCode}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        _log('request: Response body parsed successfully');
        if (data is Map && data.containsKey('data')) {
          _log('request: Returning data envelope');
          return ApiResponse.success(data['data'] as T?);
        }
        _log('request: Returning raw data');
        return ApiResponse.success(data as T?);
      }
      _log('request: Server error - status ${response.statusCode}');
      return ApiResponse.error(
        message: 'Server error',
        statusCode: response.statusCode,
      );
    } catch (e) {
      _log('request: Connection failed - $e');
      return ApiResponse.error(message: 'Connection failed');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getDashboardSync() {
    _log('getDashboardSync: Fetching dashboard data');
    return request(endpoint: AppConfig.dashboardSyncEndpoint, method: 'GET');
  }

  Future<ApiResponse<Map<String, dynamic>>> createUrl({
    required String originalUrl,
    String? customCode,
  }) {
    _log(
      'createUrl: Creating URL - original: $originalUrl, customCode: $customCode',
    );
    return request(
      endpoint: AppConfig.urlsCreateEndpoint,
      method: 'POST',
      body: {'originalUrl': originalUrl, 'customCode': customCode},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteUrl(String id) {
    _log('deleteUrl: Deleting URL with ID: $id');
    return request(
      endpoint: '${AppConfig.urlsDeleteEndpoint}/$id',
      method: 'DELETE',
    );
  }
}
