import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../middleware/api_client.dart';
import '../models/models.dart';
import '../config.dart';

// ============================================
// API Client Provider
// ============================================

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// ============================================
// Authentication State
// ============================================

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? errorMessage;
  final bool requiresMfa;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.errorMessage,
    this.requiresMfa = false,
  });

  bool get isAuthenticated => user != null && token != null && !requiresMfa;

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    String? errorMessage,
    bool? requiresMfa,
    bool clearUser = false,
    bool clearToken = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      token: clearToken ? null : (token ?? this.token),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      requiresMfa: requiresMfa ?? this.requiresMfa,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;

  AuthNotifier(this._apiClient) : super(AuthState());

  /// Sign in
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _apiClient.signIn(email, password);

    if (response.success && response.data != null) {
      final data = response.data!;
      final requiresMfa = data['requiresMfa'] as bool? ?? false;

      if (requiresMfa) {
        // MFA required
        state = state.copyWith(
          isLoading: false,
          requiresMfa: true,
        );
      } else {
        // Direct login
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        
        _apiClient.setAuthToken(token);
        
        state = state.copyWith(
          user: UserModel.fromJson(userData),
          token: token,
          isLoading: false,
          requiresMfa: false,
        );
      }
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Sign in failed',
      );
    }
  }

  /// Sign up
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _apiClient.signUp(
      email: email,
      password: password,
      name: name,
    );

    if (response.success) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Sign up failed',
      );
    }
  }

  /// Verify MFA
  Future<void> verifyMfa(String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _apiClient.verifyMfa(code);

    if (response.success && response.data != null) {
      final data = response.data!;
      final token = data['token'] as String;
      final userData = data['user'] as Map<String, dynamic>;
      
      _apiClient.setAuthToken(token);
      
      state = state.copyWith(
        user: UserModel.fromJson(userData),
        token: token,
        isLoading: false,
        requiresMfa: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'MFA verification failed',
      );
    }
  }

  /// Forgot password
  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _apiClient.forgotPassword(email);

    state = state.copyWith(
      isLoading: false,
      errorMessage: response.success ? null : response.message,
    );

    return response.success;
  }

  /// Sign out
  void signOut() {
    _apiClient.clearAuthToken();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthNotifier(apiClient);
});

// ============================================
// URLs State
// ============================================

class UrlsState {
  final List<UrlModel> urls;
  final bool isLoading;
  final String? errorMessage;

  UrlsState({
    this.urls = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  UrlsState copyWith({
    List<UrlModel>? urls,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UrlsState(
      urls: urls ?? this.urls,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class UrlsNotifier extends StateNotifier<UrlsState> {
  final ApiClient _apiClient;

  UrlsNotifier(this._apiClient) : super(UrlsState());

  /// Load all URLs
  Future<void> loadUrls() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _apiClient.getUrls();

    if (response.success && response.data != null) {
      final urlsList = response.data!['urls'] as List;
      final urls = urlsList.map((json) => UrlModel.fromJson(json)).toList();
      
      state = state.copyWith(
        urls: urls,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Failed to load URLs',
      );
    }
  }

  /// Create new URL (optimistic update)
  Future<void> createUrl({
    required String originalUrl,
    String? customCode,
  }) async {
    // Optimistic update: add placeholder immediately
    final tempUrl = UrlModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      originalUrl: originalUrl,
      shortCode: customCode ?? 'pending...',
      shortUrl: 'https://short.link/${customCode ?? "pending"}',
      clickCount: 0,
      createdAt: DateTime.now(),
      isActive: true,
    );

    state = state.copyWith(
      urls: [tempUrl, ...state.urls],
    );

    // Make actual API call
    final response = await _apiClient.createUrl(
      originalUrl: originalUrl,
      customCode: customCode,
    );

    if (response.success && response.data != null) {
      final urlData = response.data!['url'] as Map<String, dynamic>;
      final newUrl = UrlModel.fromJson(urlData);
      
      // Replace temp URL with real one
      final updatedUrls = state.urls.map((url) {
        return url.id == tempUrl.id ? newUrl : url;
      }).toList();
      
      state = state.copyWith(urls: updatedUrls);
    } else {
      // Remove temp URL on failure
      state = state.copyWith(
        urls: state.urls.where((url) => url.id != tempUrl.id).toList(),
        errorMessage: response.message ?? 'Failed to create URL',
      );
    }
  }

  /// Delete URL
  Future<void> deleteUrl(String urlId) async {
    final response = await _apiClient.deleteUrl(urlId);

    if (response.success) {
      state = state.copyWith(
        urls: state.urls.where((url) => url.id != urlId).toList(),
      );
    } else {
      state = state.copyWith(
        errorMessage: response.message ?? 'Failed to delete URL',
      );
    }
  }

  /// Get URL analytics
  Future<AnalyticsModel?> getAnalytics(String urlId) async {
    final response = await _apiClient.getAnalytics(urlId);

    if (response.success && response.data != null) {
      final analyticsData = response.data!['analytics'] as Map<String, dynamic>;
      return AnalyticsModel.fromJson(analyticsData);
    }
    
    return null;
  }
}

final urlsProvider = StateNotifierProvider<UrlsNotifier, UrlsState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UrlsNotifier(apiClient);
});

// ============================================
// Region Provider (multi-region support)
// ============================================

final regionProvider = StateProvider<String>((ref) {
  return AppConfig.defaultRegion;
});

// ============================================
// Debug Mode Provider
// ============================================

final debugModeProvider = Provider<bool>((ref) {
  return AppConfig.isDebugMode;
});
