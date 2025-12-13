/// Application Configuration
class AppConfig {
  /// Debug mode flag
  /// true = Mock data, no server calls
  /// false = Real AWS Lambda & Cognito connections
  static const bool isDebugMode = false; 

  /// AWS Lambda Base URLs (multi-region support)
  static const Map<String, String> lambdaUrls = {
    'us-east-1': 'https://bv6uo4yith.execute-api.us-east-1.amazonaws.com/stage',
  };

  static const String defaultRegion = 'us-east-1';
  static String currentRegion = defaultRegion;

  static String get currentLambdaUrl {
    return lambdaUrls[currentRegion] ?? lambdaUrls[defaultRegion]!;
  }

  /// AWS Cognito Configuration
  static const String cognitoUserPoolId = 'us-east-1_OJORVuNmI';
  static const String cognitoClientId   = '5s971p9gkjn8ughq25jqfo5qk5';
  static const String cognitoRegion     = 'us-east-1';

  /// API Endpoints
  static const String urlsListEndpoint = '/urls';
  static const String urlsCreateEndpoint = '/urls/create';
  static const String urlsDetailsEndpoint = '/urls/details';
  static const String urlsAnalyticsEndpoint = '/urls/analytics';
  static const String urlsDeleteEndpoint = '/urls/delete';
  
  // Note: Auth endpoints are removed/unused in production because we talk to Cognito directly,
  // but kept for compatibility with the mock logic if you ever switch isDebugMode back on.
  static const String authSignInEndpoint = '/auth/signin';
  static const String authSignUpEndpoint = '/auth/signup';
  static const String authMfaEndpoint = '/auth/mfa';
  static const String authForgotPasswordEndpoint = '/auth/forgot-password';

  static const Duration requestTimeout = Duration(seconds: 10);
  static const String appName = 'AWS URL Shortener';
  static const String appVersion = '1.0.0';
}