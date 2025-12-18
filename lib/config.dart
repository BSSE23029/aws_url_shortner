/// Application Configuration
class AppConfig {
  /// Debug mode flag
  static const bool isDebugMode = false;

  /// AWS Lambda Base URLs (Replace with your actual API Gateway URL)
  static const Map<String, String> lambdaUrls = {
    // Now we point to the nice domain!
    'us-east-1': 'https://api.razasoft.tech',
  };

  static const String defaultRegion = 'us-east-1';
  static String currentRegion = defaultRegion;

  static String get currentLambdaUrl {
    return lambdaUrls[currentRegion] ?? lambdaUrls[defaultRegion]!;
  }

  /// AWS Cognito Configuration
  static const String cognitoUserPoolId = 'us-east-1_OJORVuNmI';
  static const String cognitoClientId = '5s971p9gkjn8ughq25jqfo5qk5';
  static const String cognitoRegion = 'us-east-1';

  /// API Endpoints
  // Replaced /urls with /dashboard/sync for the main fetch
  static const String dashboardSyncEndpoint = '/dashboard/sync';

  static const String urlsCreateEndpoint = '/urls/create';
  static const String urlsDeleteEndpoint = '/urls/delete';

  static const Duration requestTimeout = Duration(seconds: 10);
  static const String appName = 'Rad Link';
  static const String appVersion = '1.0.0';
}
