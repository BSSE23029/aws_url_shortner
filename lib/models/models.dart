/// URL Model for shortened URLs
class UrlModel {
  final String id;
  final String originalUrl;
  final String shortCode;
  final String shortUrl;
  final DateTime createdAt;
  final int clickCount;
  final String? userId;
  final DateTime? expiresAt;
  final bool isActive;

  UrlModel({
    required this.id,
    required this.originalUrl,
    required this.shortCode,
    required this.shortUrl,
    required this.createdAt,
    this.clickCount = 0,
    this.userId,
    this.expiresAt,
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
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalUrl': originalUrl,
      'shortCode': shortCode,
      'shortUrl': shortUrl,
      'createdAt': createdAt.toIso8601String(),
      'clickCount': clickCount,
      'userId': userId,
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  UrlModel copyWith({
    String? id,
    String? originalUrl,
    String? shortCode,
    String? shortUrl,
    DateTime? createdAt,
    int? clickCount,
    String? userId,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return UrlModel(
      id: id ?? this.id,
      originalUrl: originalUrl ?? this.originalUrl,
      shortCode: shortCode ?? this.shortCode,
      shortUrl: shortUrl ?? this.shortUrl,
      createdAt: createdAt ?? this.createdAt,
      clickCount: clickCount ?? this.clickCount,
      userId: userId ?? this.userId,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// User Model for authentication
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'mfaEnabled': mfaEnabled,
    };
  }
}

/// Analytics Model
class AnalyticsModel {
  final String urlId;
  final int totalClicks;
  final Map<String, int> clicksByDate;
  final Map<String, int> clicksByCountry;
  final Map<String, int> clicksByDevice;

  AnalyticsModel({
    required this.urlId,
    required this.totalClicks,
    required this.clicksByDate,
    required this.clicksByCountry,
    required this.clicksByDevice,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      urlId: json['urlId'] as String,
      totalClicks: json['totalClicks'] as int,
      clicksByDate: Map<String, int>.from(json['clicksByDate'] as Map),
      clicksByCountry: Map<String, int>.from(json['clicksByCountry'] as Map),
      clicksByDevice: Map<String, int>.from(json['clicksByDevice'] as Map),
    );
  }
}

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final ApiErrorType? errorType;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.errorType,
  });

  factory ApiResponse.success(T data, {String? message}) {
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
    ApiErrorType? errorType,
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
  rateLimitExceeded, // 429
  wafBlocked, // Security blocked
  validationError,
  serverError,
  unauthorized,
  notFound,
  unknown,
}
