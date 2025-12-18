/// URL Model for shortened URLs
class UrlModel {
  final String id;
  final String originalUrl;
  final String shortCode;
  final String shortUrl;
  final DateTime createdAt;
  final int clickCount;
  final String? userId;
  final bool isActive;

  UrlModel({
    required this.id,
    required this.originalUrl,
    required this.shortCode,
    required this.shortUrl,
    required this.createdAt,
    this.clickCount = 0,
    this.userId,
    this.isActive = true,
  });

  factory UrlModel.fromJson(Map<String, dynamic> json) {
    return UrlModel(
      id: json['id'] as String,
      originalUrl: json['originalUrl'] as String,
      shortCode: json['shortCode'] as String,
      shortUrl: json['shortUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      clickCount: json['clickCount'] as int? ?? 0,
      userId: json['userId'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

/// GLOBAL STATS MODEL (The "Stupidity" Data)
class GlobalStatsModel {
  final int totalSystemClicks;
  final int totalSystemLinks;
  final Map<String, int> osDistribution;
  final Map<String, int> geoDistribution;

  GlobalStatsModel({
    required this.totalSystemClicks,
    required this.totalSystemLinks,
    required this.osDistribution,
    required this.geoDistribution,
  });

  factory GlobalStatsModel.fromJson(Map<String, dynamic> json) {
    return GlobalStatsModel(
      totalSystemClicks: json['totalSystemClicks'] as int? ?? 0,
      totalSystemLinks: json['totalSystemLinks'] as int? ?? 0,
      osDistribution: Map<String, int>.from(json['osDistribution'] ?? {}),
      geoDistribution: Map<String, int>.from(json['geoDistribution'] ?? {}),
    );
  }

  factory GlobalStatsModel.empty() {
    return GlobalStatsModel(
      totalSystemClicks: 0,
      totalSystemLinks: 0,
      osDistribution: {},
      geoDistribution: {},
    );
  }
}

/// User Model
class UserModel {
  final String id;
  final String email;
  final String? name;
  final DateTime createdAt;
  final bool mfaEnabled;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    required this.createdAt,
    this.mfaEnabled = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      mfaEnabled: json['mfaEnabled'] as bool? ?? false,
    );
  }
}

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final ApiErrorType? errorType; // Re-added

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.errorType, // Re-added
  });

  factory ApiResponse.success(T? data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: 200,
    );
  }

  factory ApiResponse.error({
    required String message,
    int? statusCode,
    ApiErrorType? errorType, // Re-added
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      errorType: errorType,
    );
  }
}

/// Error types for specific handling
enum ApiErrorType {
  networkError,
  sessionExpired,
  authenticationFailed,
  rateLimitExceeded, // 429
  wafBlocked, // Security blocked
  validationError,
  serverError,
  unauthorized,
  notFound,
  unknown,
}
