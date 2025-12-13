import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import '../config.dart';
import '../models/models.dart';

class ApiClient {
  String? _authToken;
  late final CognitoUserPool _userPool;
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;

  ApiClient() {
    _userPool = CognitoUserPool(
      AppConfig.cognitoUserPoolId,
      AppConfig.cognitoClientId,
    );
  }

  void setAuthToken(String token) => _authToken = token;
  void clearAuthToken() {
    _authToken = null;
    _cognitoUser = null;
    _session = null;
  }

  // ===========================================================================
  // AUTHENTICATION METHODS
  // ===========================================================================

  Future<ApiResponse<Map<String, dynamic>>> signIn(String email, String password) async {
    if (AppConfig.isDebugMode) return _mockSignIn(email);

    try {
      _cognitoUser = CognitoUser(email, _userPool);
      final authDetails = AuthenticationDetails(
        username: email,
        password: password,
      );

      _session = await _cognitoUser!.authenticateUser(authDetails);

      if (_session == null || !_session!.isValid()) {
        throw CognitoClientException('Invalid session');
      }

      final idToken = _session!.getIdToken().getJwtToken();
      setAuthToken(idToken!);

      final attributes = await _cognitoUser!.getUserAttributes();
      final attrMap = {for (var attr in attributes ?? []) attr.name!: attr.value};

      final userData = {
        'id': _session!.getIdToken().payload['sub'],
        'email': attrMap['email'] ?? email,
        'name': attrMap['name'] ?? email,
        'createdAt': DateTime.now().toIso8601String(),
        'mfaEnabled': false,
      };

      return ApiResponse.success({
        'token': idToken,
        'user': userData,
        'requiresMfa': false,
      }, message: 'Sign in successful');

    } on CognitoClientException catch (e) {
      return _handleCognitoError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Unknown error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (AppConfig.isDebugMode) return _mockSignUp(email);

    try {
      final userAttributes = [
        AttributeArg(name: 'email', value: email),
        AttributeArg(name: 'name', value: name),
      ];

      final result = await _userPool.signUp(
        email,
        password,
        userAttributes: userAttributes,
      );

      _cognitoUser = result.user;

      // FIX: Handle nullable boolean
      final isConfirmed = result.userConfirmed ?? false;

      return ApiResponse.success({
        'user': {'email': email, 'name': name},
        'confirmationRequired': !isConfirmed,
      }, message: 'Account created. Please verify your email.');

    } on CognitoClientException catch (e) {
      return _handleCognitoError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Error: $e');
    }
  }

  Future<ApiResponse<bool>> confirmAccount(String email, String code) async {
    if (AppConfig.isDebugMode) return ApiResponse.success(true);

    try {
      _cognitoUser = CognitoUser(email, _userPool);
      
      // FIX: Correct method name is confirmRegistration
      final success = await _cognitoUser!.confirmRegistration(code);
      
      return success 
        ? ApiResponse.success(true, message: 'Account verified! Please log in.')
        : ApiResponse.error(message: 'Verification failed. Invalid code.');
        
    } on CognitoClientException catch (e) {
      return _handleCognitoError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Error: $e');
    }
  }

  Future<ApiResponse<String>> resendConfirmationCode(String email) async {
    if (AppConfig.isDebugMode) return ApiResponse.success('sent');

    try {
      _cognitoUser = CognitoUser(email, _userPool);
      await _cognitoUser!.resendConfirmationCode();
      return ApiResponse.success('sent', message: 'Code resent to $email');
    } on CognitoClientException catch (e) {
      return _handleCognitoError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyMfa(String code) async {
    if (AppConfig.isDebugMode) return _mockMfa();

    try {
      if (_cognitoUser == null) {
        return ApiResponse.error(message: 'Session lost. Please login again.');
      }

      _session = await _cognitoUser!.sendMFACode(code);

      if (_session != null && _session!.isValid()) {
         final idToken = _session!.getIdToken().getJwtToken();
         setAuthToken(idToken!);
         
         final attributes = await _cognitoUser!.getUserAttributes();
         final attrMap = {for (var attr in attributes ?? []) attr.name!: attr.value};
         
         return ApiResponse.success({
           'token': idToken,
           'user': {
             'id': _session!.getIdToken().payload['sub'],
             'email': attrMap['email'],
             'mfaEnabled': true,
           }
         }, message: 'MFA Verified');
      }
      return ApiResponse.error(message: 'Invalid MFA Code');
    } on CognitoClientException catch (e) {
      return _handleCognitoError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Error: $e');
    }
  }
  
   Future<ApiResponse<Map<String, dynamic>>> forgotPassword(String email) async {
    if (AppConfig.isDebugMode) return ApiResponse.success({}, message: 'Mock email sent');
    
    try {
      final user = CognitoUser(email, _userPool);
      await user.forgotPassword();
      return ApiResponse.success({}, message: 'Reset code sent to email');
    } on CognitoClientException catch (e) {
      return _handleCognitoError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Network error');
    }
  }

  // ===========================================================================
  // API REQUESTS
  // ===========================================================================

  Future<ApiResponse<T>> request<T>({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    if (AppConfig.isDebugMode) return _getMockResponse<T>(endpoint);

    try {
      final url = Uri.parse('${AppConfig.currentLambdaUrl}$endpoint');
      final headers = {
        'Content-Type': 'application/json',
        'X-Region': AppConfig.currentRegion,
        if (requiresAuth && _authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET': response = await http.get(url, headers: headers); break;
        case 'POST': response = await http.post(url, headers: headers, body: jsonEncode(body)); break;
        case 'DELETE': response = await http.delete(url, headers: headers); break;
        default: throw Exception('Method not supported');
      }

      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse.error(message: 'Network error: $e', errorType: ApiErrorType.networkError);
    }
  }

  ApiResponse<T> _handleResponse<T>(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      // FIX: Cast safely now that success accepts T?
      return ApiResponse.success(data['data'] as T?, message: data['message']);
    }
    return ApiResponse.error(
      message: 'Request failed: ${response.statusCode}', 
      statusCode: response.statusCode
    );
  }

  ApiResponse<T> _handleCognitoError<T>(CognitoClientException e) {
    String msg = e.message ?? 'Authentication Error';
    if (e.code == 'UserNotConfirmedException') msg = 'Account not confirmed. Please verify email.';
    if (e.code == 'NotAuthorizedException') msg = 'Incorrect email or password.';
    if (e.code == 'UsernameExistsException') msg = 'Account already exists.';
    return ApiResponse.error(message: msg, errorType: ApiErrorType.authenticationFailed);
  }

  // Mocks
  dynamic _mockSignIn(String email) => ApiResponse.success({'token':'mock','user':{'email':email}}, message:'Mock Login');
  dynamic _mockSignUp(String email) => ApiResponse.success({'user':{'email':email},'confirmationRequired':true});
  dynamic _mockMfa() => ApiResponse.success({'token':'mock'}, message:'Mock MFA');
  
  Future<ApiResponse<T>> _getMockResponse<T>(String endpoint) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // FIX: Safely mock return null
    return ApiResponse.success(null, message: 'Mock Data');
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getUrls() => request(endpoint: AppConfig.urlsListEndpoint, method: 'GET');
  Future<ApiResponse<Map<String, dynamic>>> createUrl({required String originalUrl, String? customCode}) => 
    request(endpoint: AppConfig.urlsCreateEndpoint, method: 'POST', body: {'originalUrl': originalUrl, 'customCode': customCode});
  Future<ApiResponse<Map<String, dynamic>>> deleteUrl(String id) => request(endpoint: '${AppConfig.urlsDeleteEndpoint}/$id', method: 'DELETE');
}