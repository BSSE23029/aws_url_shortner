/// Application Configuration
///
/// Set isDebugMode = true to use mock data (no AWS connection needed)
/// Set isDebugMode = false to connect to real AWS Lambda functions
class AppConfig {
  /// Debug mode flag
  /// true = Mock data, no server calls, no permissions needed
  /// false = Real AWS Lambda connections
  static const bool isDebugMode = true;

  /// AWS Lambda Base URLs (multi-region support)
  /// Update these with your actual Lambda function URLs after deployment
  static const Map<String, String> lambdaUrls = {
    'us-east-1': 'https://your-api-id.execute-api.us-east-1.amazonaws.com/prod',
    'us-west-2': 'https://your-api-id.execute-api.us-west-2.amazonaws.com/prod',
    'eu-west-1': 'https://your-api-id.execute-api.eu-west-1.amazonaws.com/prod',
    'ap-southeast-1':
        'https://your-api-id.execute-api.ap-southeast-1.amazonaws.com/prod',
  };

  /// Default region to use
  static const String defaultRegion = 'us-east-1';

  /// Current active region (can be changed at runtime)
  static String currentRegion = defaultRegion;

  /// Get the current Lambda base URL
  static String get currentLambdaUrl {
    return lambdaUrls[currentRegion] ?? lambdaUrls[defaultRegion]!;
  }

  /// API Endpoints (Lambda function paths)
  static const String authSignInEndpoint = '/auth/signin';
  static const String authSignUpEndpoint = '/auth/signup';
  static const String authMfaEndpoint = '/auth/mfa';
  static const String authForgotPasswordEndpoint = '/auth/forgot-password';
  static const String authResetPasswordEndpoint = '/auth/reset-password';

  static const String urlsListEndpoint = '/urls';
  static const String urlsCreateEndpoint = '/urls/create';
  static const String urlsDetailsEndpoint = '/urls/details';
  static const String urlsAnalyticsEndpoint = '/urls/analytics';
  static const String urlsDeleteEndpoint = '/urls/delete';

  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 10);

  /// App metadata
  static const String appName = 'AWS URL Shortener';
  static const String appVersion = '1.0.0';
}
