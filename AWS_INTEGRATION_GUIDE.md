# AWS Integration Guide

This guide explains how to integrate the Flutter frontend with your AWS serverless backend.

## 🏗️ Architecture Components

### Backend Services Required

1. **Amazon Cognito User Pool** - Authentication
2. **API Gateway** - REST API endpoints
3. **AWS Lambda** - Business logic
4. **DynamoDB** - Data storage
5. **DynamoDB DAX** - Caching layer
6. **S3** - Frontend hosting
7. **Route 53** - DNS and geo-routing
8. **AWS WAF** - Web Application Firewall

## 📡 API Integration

### 1. Create API Service Layer

Create `lib/services/api_service.dart`:

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'https://YOUR-API-ID.execute-api.REGION.amazonaws.com/prod';
  
  // Cognito Configuration
  static const String cognitoUserPoolId = 'YOUR-USER-POOL-ID';
  static const String cognitoClientId = 'YOUR-CLIENT-ID';
  static const String cognitoRegion = 'us-east-1';
  
  String? _authToken;
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };
  
  // Authentication
  Future<ApiResponse<UserModel>> signIn(String email, String password) async {
    try {
      // Use AWS Cognito SDK or direct API calls
      // Example using amazon-cognito-identity-js equivalent
      final response = await _post('/auth/signin', {
        'email': email,
        'password': password,
      });
    
      if (response.success) {
        final user = UserModel.fromJson(response.data['user']);
        _authToken = response.data['token'];
        return ApiResponse.success(user);
      }
    
      return ApiResponse.error(message: response.message ?? 'Login failed');
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // URLs
  Future<ApiResponse<List<UrlModel>>> fetchUrls() async {
    try {
      final response = await _get('/urls');
    
      if (response.success) {
        final urls = (response.data as List)
            .map((json) => UrlModel.fromJson(json))
            .toList();
        return ApiResponse.success(urls);
      }
    
      return ApiResponse.error(message: response.message ?? 'Failed to fetch URLs');
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<ApiResponse<UrlModel>> createUrl(String originalUrl, {String? customCode}) async {
    try {
      final response = await _post('/urls', {
        'originalUrl': originalUrl,
        if (customCode != null) 'customCode': customCode,
      });
    
      if (response.success) {
        final url = UrlModel.fromJson(response.data);
        return ApiResponse.success(url);
      }
    
      return ApiResponse.error(message: response.message ?? 'Failed to create URL');
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<ApiResponse<AnalyticsModel>> getAnalytics(String urlId) async {
    try {
      final response = await _get('/urls/$urlId/analytics');
    
      if (response.success) {
        final analytics = AnalyticsModel.fromJson(response.data);
        return ApiResponse.success(analytics);
      }
    
      return ApiResponse.error(message: response.message ?? 'Failed to fetch analytics');
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // Helper methods
  Future<dynamic> _get(String path) async {
    // Implement HTTP GET
    // Use dart:io HttpClient or implement your own
  }
  
  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    // Implement HTTP POST
  }
  
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error.toString().contains('429')) {
      return ApiResponse.error(
        message: 'Rate limit exceeded',
        statusCode: 429,
        errorType: ApiErrorType.rateLimitExceeded,
      );
    } else if (error.toString().contains('403')) {
      return ApiResponse.error(
        message: 'Request blocked by WAF',
        statusCode: 403,
        errorType: ApiErrorType.wafBlocked,
      );
    } else if (error.toString().contains('401')) {
      return ApiResponse.error(
        message: 'Session expired',
        statusCode: 401,
        errorType: ApiErrorType.sessionExpired,
      );
    }
  
    return ApiResponse.error(
      message: error.toString(),
      errorType: ApiErrorType.unknown,
    );
  }
}
```

### 2. Update Authentication Screens

In `sign_in_screen.dart`, replace the mock API call:

```dart
Future<void> _handleSignIn() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);
  
    final apiService = ApiService();
    final response = await apiService.signIn(
      _emailController.text,
      _passwordController.text,
    );
  
    setState(() => _isLoading = false);
  
    if (response.success && response.data != null) {
      // Store auth token and user
      final appState = context.read<AppState>();
      appState.login(response.data!, response.authToken!, response.refreshToken!);
    
      // Check if MFA is required
      if (response.data!.mfaEnabled) {
        Navigator.pushReplacementNamed(context, '/mfa');
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } else {
      ErrorToast.show(
        context,
        message: response.message ?? 'Login failed',
        errorType: response.errorType,
      );
    
      // Handle specific errors
      if (response.errorType == ApiErrorType.wafBlocked) {
        Navigator.pushNamed(context, '/waf-blocked');
      }
    }
  }
}
```

### 3. Update Dashboard to Fetch Real Data

In `dashboard_screen.dart`:

```dart
Future<void> _loadData() async {
  setState(() => _isLoading = true);
  
  final apiService = ApiService();
  final response = await apiService.fetchUrls();
  
  if (response.success && response.data != null) {
    setState(() {
      _urls = response.data!;
      _totalUrls = _urls.length;
      _totalClicks = _urls.fold<int>(0, (sum, url) => sum + url.clickCount);
      _activeUrls = _urls.where((url) => url.isActive).length;
      _isLoading = false;
    });
  } else {
    setState(() => _isLoading = false);
  
    if (mounted) {
      ErrorToast.show(
        context,
        message: response.message ?? 'Failed to load data',
        errorType: response.errorType,
      );
    
      // Handle session expiry
      if (response.errorType == ApiErrorType.sessionExpired) {
        showSessionExpiredDialog(
          context,
          onReauthenticated: _loadData,
        );
      }
    }
  }
}
```

### 4. Update Create URL with Optimistic UI

In `create_url_screen.dart`:

```dart
Future<void> _handleCreateUrl() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isCreating = true);
  
    // Generate optimistic data
    final shortCode = _useCustomCode && _customCodeController.text.isNotEmpty
        ? _customCodeController.text
        : _generateRandomCode();
  
    final shortUrl = 'https://short.ly/$shortCode';
  
    // Show success immediately (optimistic)
    setState(() {
      _createdShortUrl = shortUrl;
      _isCreating = false;
    });
  
    // Create URL in background
    final apiService = ApiService();
    final response = await apiService.createUrl(
      _urlController.text,
      customCode: _useCustomCode ? _customCodeController.text : null,
    );
  
    if (!response.success) {
      // Rollback on error
      if (mounted) {
        setState(() {
          _createdShortUrl = null;
        });
      
        ErrorToast.show(
          context,
          message: response.message ?? 'Failed to create URL',
          errorType: response.errorType,
        );
      
        if (response.errorType == ApiErrorType.rateLimitExceeded) {
          ThrottlingToast.show(context);
        }
      }
    } else {
      // Update with actual data from backend
      setState(() {
        _createdShortUrl = response.data!.shortUrl;
      });
    }
  }
}
```

## 🔐 Cognito Integration

### Install AWS Amplify (Optional)

If you want to use AWS Amplify for easier Cognito integration:

```yaml
dependencies:
  amplify_flutter: ^1.0.0
  amplify_auth_cognito: ^1.0.0
```

### Configure Amplify

```dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    await Amplify.addPlugin(auth);
  
    const amplifyconfig = '''{
      "UserAgent": "aws-amplify-cli/2.0",
      "Version": "1.0",
      "auth": {
        "plugins": {
          "awsCognitoAuthPlugin": {
            "UserAgent": "aws-amplify-cli/0.1.0",
            "Version": "0.1.0",
            "IdentityManager": {
              "Default": {}
            },
            "CredentialsProvider": {
              "CognitoIdentity": {
                "Default": {
                  "PoolId": "YOUR-IDENTITY-POOL-ID",
                  "Region": "us-east-1"
                }
              }
            },
            "CognitoUserPool": {
              "Default": {
                "PoolId": "YOUR-USER-POOL-ID",
                "AppClientId": "YOUR-CLIENT-ID",
                "Region": "us-east-1"
              }
            },
            "Auth": {
              "Default": {
                "authenticationFlowType": "USER_SRP_AUTH"
              }
            }
          }
        }
      }
    }''';
  
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    debugPrint('Error configuring Amplify: $e');
  }
}
```

## 🌍 Region Detection

Add this service to detect the user's region:

```dart
class RegionService {
  static Future<String> detectRegion() async {
    try {
      // Call a lightweight endpoint to get region info
      // This should be a simple Lambda@Edge function or CloudFront header
      final response = await http.get(
        Uri.parse('https://your-cloudfront-url.cloudfront.net/api/region'),
      );
    
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['region'] ?? 'us-east-1';
      }
    } catch (e) {
      debugPrint('Error detecting region: $e');
    }
  
    return 'us-east-1'; // Default fallback
  }
  
  static Future<int> measureLatency(String region) async {
    final start = DateTime.now();
  
    try {
      await http.get(
        Uri.parse('https://your-api-$region.amazonaws.com/health'),
      );
    
      final end = DateTime.now();
      return end.difference(start).inMilliseconds;
    } catch (e) {
      return -1;
    }
  }
}
```

Update AppState to use it:

```dart
Future<void> detectAndSetRegion() async {
  final region = await RegionService.detectRegion();
  setCurrentRegion(region);
  
  // Measure latency
  final latency = await RegionService.measureLatency(region);
  if (latency > 0) {
    // Store latency for display
  }
}
```

## 📊 Analytics Integration

Add AWS Pinpoint for analytics:

```yaml
dependencies:
  amplify_analytics_pinpoint: ^1.0.0
```

Track events:

```dart
void trackUrlCreated(UrlModel url) {
  final event = AnalyticsEvent('url_created');
  event.customProperties.addStringProperty('shortCode', url.shortCode);
  event.customProperties.addIntProperty('urlLength', url.originalUrl.length);
  Amplify.Analytics.recordEvent(event: event);
}
```

## 🚀 Deployment

### Build for Web

```bash
flutter build web --release
```

### Deploy to S3 + CloudFront

```bash
# Install AWS CLI
aws configure

# Sync to S3
aws s3 sync build/web/ s3://your-bucket-name/ --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id YOUR-DISTRIBUTION-ID \
  --paths "/*"
```

### Environment Configuration

Create different configs for dev/staging/prod:

```dart
// lib/config/environment.dart
class Environment {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://dev-api.example.com',
  );
  
  static const String cognitoUserPoolId = String.fromEnvironment(
    'COGNITO_USER_POOL_ID',
    defaultValue: 'us-east-1_XXXXXXXXX',
  );
}
```

Build with environment:

```bash
flutter build web --release \
  --dart-define=API_URL=https://prod-api.example.com \
  --dart-define=COGNITO_USER_POOL_ID=us-east-1_PROD123
```

## 🔧 Testing

### API Mock Service

For testing without backend:

```dart
class MockApiService extends ApiService {
  @override
  Future<ApiResponse<List<UrlModel>>> fetchUrls() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return ApiResponse.success(_generateMockUrls());
  }
  
  // ... implement other mocks
}
```

### Integration Tests

```dart
testWidgets('Create URL flow', (tester) async {
  await tester.pumpWidget(const UrlShortenerApp());
  
  // Navigate to create screen
  await tester.tap(find.text('Create Short URL'));
  await tester.pumpAndSettle();
  
  // Enter URL
  await tester.enterText(
    find.byType(TextFormField).first,
    'https://example.com/long-url',
  );
  
  // Submit
  await tester.tap(find.text('Create Short URL'));
  await tester.pumpAndSettle();
  
  // Verify success
  expect(find.text('URL Created!'), findsOneWidget);
});
```

## 📝 Checklist

- [ ] Configure Cognito User Pool
- [ ] Set up API Gateway with CORS
- [ ] Deploy Lambda functions
- [ ] Configure DynamoDB tables
- [ ] Set up DynamoDB DAX cluster
- [ ] Configure CloudFront distribution
- [ ] Set up S3 bucket for hosting
- [ ] Configure Route 53 with geo-routing
- [ ] Set up AWS WAF rules
- [ ] Integrate API service in Flutter
- [ ] Test authentication flow
- [ ] Test URL creation with optimistic UI
- [ ] Test error handling (429, WAF, etc.)
- [ ] Configure region detection
- [ ] Set up analytics
- [ ] Deploy to production
- [ ] Configure custom domain
- [ ] Set up SSL certificate

## 🆘 Troubleshooting

### CORS Issues

Ensure API Gateway has proper CORS configuration:

```json
{
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type,Authorization",
  "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,OPTIONS"
}
```

### Session Timeout

Implement token refresh logic:

```dart
Future<void> refreshToken() async {
  if (_refreshToken != null) {
    final response = await apiService.refreshAuthToken(_refreshToken!);
    if (response.success) {
      _authToken = response.data!;
    }
  }
}
```

### Performance

- Enable DynamoDB DAX for <1ms reads
- Use CloudFront edge locations
- Implement proper caching headers
- Optimize Lambda cold starts

---

**Questions?** Check AWS documentation or open an issue!
