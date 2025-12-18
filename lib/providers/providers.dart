import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../middleware/api_client.dart';
import '../models/models.dart';
import '../config.dart';
import 'package:flutter/foundation.dart';

void _log(String message) {
  if (kDebugMode) {
    print("🟣 [PROVIDER] $message");
  }
}

// ===========================================================================
// AUTHENTICATION STATE & NOTIFIER
// ===========================================================================

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? errorMessage;
  final bool requiresMfa;
  final bool confirmationRequired;
  final String? tempEmail;
  final bool isInitialized; // Track if local storage check is complete

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.errorMessage,
    this.requiresMfa = false,
    this.confirmationRequired = false,
    this.tempEmail,
    this.isInitialized = false,
  });

  bool get isAuthenticated {
    final result =
        user != null && token != null && !requiresMfa && !confirmationRequired;
    _log(
      "🔍 isAuthenticated check: $result (user: ${user != null}, token: ${token != null}, mfa: $requiresMfa, confirmation: $confirmationRequired)",
    );
    return result;
  }

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    String? errorMessage,
    bool? requiresMfa,
    bool? confirmationRequired,
    String? tempEmail,
    bool? isInitialized,
  }) {
    _log(
      "📝 AuthState.copyWith called: isLoading=${isLoading ?? this.isLoading}, error=${errorMessage ?? 'none'}, mfa=${requiresMfa ?? this.requiresMfa}, confirmation=${confirmationRequired ?? this.confirmationRequired}",
    );
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      requiresMfa: requiresMfa ?? this.requiresMfa,
      confirmationRequired: confirmationRequired ?? this.confirmationRequired,
      tempEmail: tempEmail ?? this.tempEmail,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  String? _cachedPassword; // Used to auto-login after email confirmation

  AuthNotifier(this._apiClient) : super(AuthState()) {
    _log("🔧 AuthNotifier initialized");
    tryAutoLogin();
  }

  /// Check SharedPreferences for existing session on app boot
  Future<void> tryAutoLogin() async {
    _log("💾 tryAutoLogin: Checking storage...");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userData = prefs.getString('user_model');
    _log(
      "💾 tryAutoLogin: Token found=${token != null}, UserData found=${userData != null}",
    );

    if (token != null && userData != null) {
      try {
        _log("💾 tryAutoLogin: Parsing stored user data...");
        final user = UserModel.fromJson(jsonDecode(userData));
        _log(
          "💾 tryAutoLogin: User parsed - ID: ${user.id}, Email: ${user.email}, Name: ${user.name}",
        );
        _apiClient.setAuthToken(token);
        _log("✅ tryAutoLogin: Session restored for ${user.email}");
        state = state.copyWith(user: user, token: token, isInitialized: true);
      } catch (e) {
        _log("⚠️ tryAutoLogin: Failed to parse stored user data - Error: $e");
        state = state.copyWith(isInitialized: true);
      }
    } else {
      _log("ℹ️ tryAutoLogin: No stored session found");
      state = state.copyWith(isInitialized: true);
    }
    _log(
      "💾 tryAutoLogin: Complete - isAuthenticated=${state.isAuthenticated}",
    );
  }

  Future<void> signIn(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    _log("🔑 signIn: Attempting login for $email (rememberMe: $rememberMe)");
    state = state.copyWith(isLoading: true, errorMessage: null);
    _cachedPassword = password; // Cache for post-verification auto-login
    _log("🔑 signIn: Password cached for potential post-verification login");

    _log("🔑 signIn: Calling API signIn...");
    final response = await _apiClient.signIn(email, password);
    _log(
      "🔑 signIn: API response - success: ${response.success}, message: ${response.message}",
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      _log("🔑 signIn: Parsing user data...");
      final user = UserModel.fromJson(data['user']);
      final token = data['token'];
      _log(
        "🔑 signIn: User parsed - ID: ${user.id}, Email: ${user.email}, Name: ${user.name}",
      );

      if (rememberMe) {
        _log("💾 signIn: Saving session to SharedPreferences");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_model', jsonEncode(data['user']));
        _log("💾 signIn: Session saved successfully");
      } else {
        _log("💾 signIn: rememberMe=false, skipping storage");
      }

      state = state.copyWith(
        user: user,
        token: token,
        isLoading: false,
        requiresMfa: false,
        confirmationRequired: false,
      );
      _log("✅ signIn: Success - User authenticated");
    } else {
      _log("❌ signIn: Failed - ${response.message}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Sign in failed',
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _log("📝 signUp: Registering $email with name: $name");
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      tempEmail: email,
    );
    _cachedPassword = password;
    _log("📝 signUp: Password cached, tempEmail set to: $email");

    _log("📝 signUp: Calling API signUp...");
    final response = await _apiClient.signUp(
      email: email,
      password: password,
      name: name,
    );
    _log(
      "📝 signUp: API response - success: ${response.success}, message: ${response.message}",
    );

    if (response.success) {
      final confRequired = response.data?['confirmationRequired'] ?? false;
      _log("✅ signUp: Success (Confirmation required: $confRequired)");
      state = state.copyWith(
        isLoading: false,
        confirmationRequired: confRequired,
      );
    } else {
      _log("❌ signUp: Failed - ${response.message}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Sign up failed',
      );
    }
  }

  Future<void> confirmAccount(String code) async {
    _log("✉️ confirmAccount: Starting with code: $code");
    if (state.tempEmail == null) {
      _log("❌ confirmAccount: tempEmail is null, session expired");
      state = state.copyWith(errorMessage: "Session expired. Please sign in.");
      return;
    }

    _log("✉️ confirmAccount: Verifying email: ${state.tempEmail}");
    state = state.copyWith(isLoading: true);
    _log("✉️ confirmAccount: Calling API confirmAccount...");
    final response = await _apiClient.confirmAccount(state.tempEmail!, code);
    _log(
      "✉️ confirmAccount: API response - success: ${response.success}, message: ${response.message}",
    );

    if (response.success) {
      _log("✅ confirmAccount: Success");
      if (_cachedPassword != null) {
        _log(
          "🚀 confirmAccount: Cached password found, triggering automatic login for ${state.tempEmail}",
        );
        await signIn(state.tempEmail!, _cachedPassword!, rememberMe: true);
        _log("🚀 confirmAccount: Automatic login completed");
      } else {
        _log("ℹ️ confirmAccount: No cached password, user must login manually");
        state = state.copyWith(isLoading: false, confirmationRequired: false);
      }
    } else {
      _log("❌ confirmAccount: Failed - ${response.message}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Verification failed',
      );
    }
  }

  void signOut() async {
    _log("🚪 signOut: Starting sign-out process");
    _log("🚪 signOut: Current user: ${state.user?.email ?? 'none'}");
    final prefs = await SharedPreferences.getInstance();
    _log("🚪 signOut: Removing auth_token from storage");
    await prefs.remove('auth_token');
    _log("🚪 signOut: Removing user_model from storage");
    await prefs.remove('user_model');

    _log("🚪 signOut: Clearing cached password");
    _cachedPassword = null;
    _log("🚪 signOut: Clearing API client auth token");
    _apiClient.clearAuthToken();
    _log("🚪 signOut: Resetting AuthState");
    state = AuthState(isInitialized: true);
    _log("✅ signOut: Complete - User logged out");
  }

  Future<void> resendCode() async {
    _log("📨 resendCode: Starting resend process");
    if (state.tempEmail != null) {
      _log("📨 resendCode: Requesting new code for ${state.tempEmail}");
      await _apiClient.resendConfirmationCode(state.tempEmail!);
      _log("✅ resendCode: Request sent successfully");
    } else {
      _log("❌ resendCode: tempEmail is null, cannot resend");
    }
  }

  Future<void> verifyMfa(String code) async {
    _log("🔐 verifyMfa: Starting verification with code: $code");
    state = state.copyWith(isLoading: true);
    _log("🔐 verifyMfa: Calling API verifyMfa...");
    final response = await _apiClient.verifyMfa(code);
    _log(
      "🔐 verifyMfa: API response - success: ${response.success}, message: ${response.message}",
    );

    if (response.success && response.data != null) {
      _log("🔐 verifyMfa: Parsing user data...");
      final user = UserModel.fromJson(response.data!['user']);
      _log("✅ verifyMfa: Success - User: ${user.email}");
      state = state.copyWith(
        user: user,
        token: response.data!['token'],
        isLoading: false,
        requiresMfa: false,
      );
    } else {
      _log("❌ verifyMfa: Failed - ${response.message}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? "MFA verification failed",
      );
    }
  }

  Future<bool> forgotPassword(String email) async {
    _log("🔑 forgotPassword: Reset requested for $email");
    state = state.copyWith(isLoading: true);
    _log("🔑 forgotPassword: Calling API forgotPassword...");
    final response = await _apiClient.forgotPassword(email);
    _log(
      "🔑 forgotPassword: API response - success: ${response.success}, message: ${response.message}",
    );
    state = state.copyWith(isLoading: false);
    if (response.success) {
      _log("✅ forgotPassword: Reset email sent successfully");
    } else {
      _log("❌ forgotPassword: Failed - ${response.message}");
    }
    return response.success;
  }
}

// ===========================================================================
// URLS STATE & NOTIFIER
// ===========================================================================

class UrlsState {
  final List<UrlModel> urls;
  final GlobalStatsModel globalStats;
  final bool isLoading;
  final String? errorMessage;

  UrlsState({
    this.urls = const [],
    GlobalStatsModel? globalStats,
    this.isLoading = false,
    this.errorMessage,
  }) : globalStats = globalStats ?? GlobalStatsModel.empty();

  int get myTotalClicks {
    final total = urls.fold(0, (sum, item) => sum + item.clickCount);
    _log("🔍 myTotalClicks calculated: $total from ${urls.length} URLs");
    return total;
  }

  UrlsState copyWith({
    List<UrlModel>? urls,
    GlobalStatsModel? globalStats,
    bool? isLoading,
    String? errorMessage,
  }) {
    _log(
      "📝 UrlsState.copyWith: urls=${urls?.length ?? this.urls.length}, isLoading=${isLoading ?? this.isLoading}, error=${errorMessage ?? 'none'}",
    );
    return UrlsState(
      urls: urls ?? this.urls,
      globalStats: globalStats ?? this.globalStats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class UrlsNotifier extends StateNotifier<UrlsState> {
  final ApiClient _apiClient;

  UrlsNotifier(this._apiClient) : super(UrlsState()) {
    _log("🔧 UrlsNotifier initialized");
  }

  Future<void> loadDashboard() async {
    _log("📊 loadDashboard: Called");
    if (state.isLoading) {
      _log("📊 loadDashboard: Already loading, skipping");
      return;
    }

    _log("📊 loadDashboard: Syncing data...");
    state = state.copyWith(isLoading: true, errorMessage: null);

    _log("📊 loadDashboard: Calling API getDashboardSync...");
    final response = await _apiClient.getDashboardSync();
    _log(
      "📊 loadDashboard: API response - success: ${response.success}, message: ${response.message}",
    );

    if (response.success && response.data != null) {
      try {
        final data = response.data!;
        _log("📊 loadDashboard: Response keys: ${data.keys.join(', ')}");

        _log("📊 loadDashboard: Parsing URLs list...");
        final List<UrlModel> urls = (data['urls'] as List? ?? [])
            .map((e) => UrlModel.fromJson(e))
            .toList();
        _log("📊 loadDashboard: Parsed ${urls.length} URLs");

        _log("📊 loadDashboard: Parsing global stats...");
        final global = GlobalStatsModel.fromJson(data['globalStats'] ?? {});
        _log(
          "📊 loadDashboard: Global stats - totalSystemLinks: ${global.totalSystemLinks}, totalSystemClicks: ${global.totalSystemClicks}",
        );

        state = state.copyWith(
          urls: urls,
          globalStats: global,
          isLoading: false,
        );
        _log("✅ loadDashboard: Success. Dashboard loaded and state updated");
      } catch (e) {
        _log("❌ loadDashboard: Parsing error - $e");
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Failed to process server data.",
        );
      }
    } else {
      _log("❌ loadDashboard: API error - ${response.message}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? "Failed to fetch dashboard",
      );
    }
  }

  Future<void> createUrl({
    required String originalUrl,
    String? customCode,
  }) async {
    _log("🔗 createUrl: Starting URL creation");
    _log(
      "🔗 createUrl: originalUrl=$originalUrl, customCode=${customCode ?? 'auto-generated'}",
    );
    state = state.copyWith(isLoading: true, errorMessage: null);

    _log("🔗 createUrl: Calling API createUrl...");
    final response = await _apiClient.createUrl(
      originalUrl: originalUrl,
      customCode: customCode,
    );
    _log(
      "🔗 createUrl: API response - success: ${response.success}, message: ${response.message}",
    );

    if (response.success && response.data != null) {
      try {
        _log("🔗 createUrl: Parsing URL data from response...");
        final urlData = response.data!['url'] ?? response.data!;
        final newUrl = UrlModel.fromJson(urlData);
        _log(
          "🔗 createUrl: New URL created - ID: ${newUrl.id}, shortCode: ${newUrl.shortCode}",
        );
        final previousCount = state.urls.length;
        state = state.copyWith(urls: [newUrl, ...state.urls], isLoading: false);
        _log(
          "✅ createUrl: Success - URLs count: $previousCount → ${state.urls.length}",
        );
      } catch (e) {
        _log("❌ createUrl: Parsing failed - $e");
        state = state.copyWith(isLoading: false);
      }
    } else {
      _log("❌ createUrl: Failed - ${response.message}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? "Could not create URL",
      );
    }
  }

  Future<void> deleteUrl(String id) async {
    _log("🗑️ deleteUrl: Starting deletion for ID: $id");
    final previousUrls = state.urls;
    final previousCount = previousUrls.length;
    final urlToDelete = previousUrls.where((u) => u.id == id).firstOrNull;
    if (urlToDelete != null) {
      _log(
        "🗑️ deleteUrl: URL to delete - shortCode: ${urlToDelete.shortCode}, originalUrl: ${urlToDelete.originalUrl}",
      );
    }

    // Optimistic Update
    _log("🗑️ deleteUrl: Performing optimistic update...");
    state = state.copyWith(urls: state.urls.where((u) => u.id != id).toList());
    _log("🗑️ deleteUrl: URLs count: $previousCount → ${state.urls.length}");

    _log("🗑️ deleteUrl: Calling API deleteUrl...");
    final response = await _apiClient.deleteUrl(id);
    _log(
      "🗑️ deleteUrl: API response - success: ${response.success}, message: ${response.message}",
    );

    if (!response.success) {
      _log("❌ deleteUrl: Failed - ${response.message}, rolling back");
      state = state.copyWith(
        urls: previousUrls,
        errorMessage: response.message,
      );
      _log(
        "🗑️ deleteUrl: Rollback complete - URLs count restored to $previousCount",
      );
    } else {
      _log("✅ deleteUrl: Success - URL deleted permanently");
    }
  }
}

// ===========================================================================
// PROVIDER DECLARATIONS
// ===========================================================================

final apiClientProvider = Provider<ApiClient>((ref) {
  _log("🏗️ apiClientProvider: Creating ApiClient instance");
  return ApiClient();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  _log("🏗️ authProvider: Creating AuthNotifier instance");
  return AuthNotifier(ref.watch(apiClientProvider));
});

/// UI performance optimization: Read-only selector for the auth state
final authStateProvider = Provider<AuthState>((ref) {
  final state = ref.watch(authProvider);
  _log(
    "🏗️ authStateProvider: Providing AuthState - isAuthenticated: ${state.isAuthenticated}",
  );
  return state;
});

final urlsProvider = StateNotifierProvider<UrlsNotifier, UrlsState>((ref) {
  _log("🏗️ urlsProvider: Creating UrlsNotifier instance");
  return UrlsNotifier(ref.watch(apiClientProvider));
});

final regionProvider = StateProvider<String>((ref) {
  _log(
    "🏗️ regionProvider: Initializing with default region: ${AppConfig.defaultRegion}",
  );
  return AppConfig.defaultRegion;
});
