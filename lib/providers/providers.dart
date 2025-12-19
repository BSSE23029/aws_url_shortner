import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../middleware/api_client.dart';
import '../models/models.dart';
import '../config.dart';
import 'package:flutter/foundation.dart';

// Helper for formatted console logs
void _log(String message) {
  if (kDebugMode) {
    print("🟣 [PROVIDER] $message");
  }
}

// Model for Geo-Map Visualization
class MapDataModel {
  MapDataModel(this.countryCode, this.count, this.latitude, this.longitude);
  final String countryCode;
  final int count;
  final double latitude;
  final double longitude;
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
  final bool isInitialized;

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
    final auth =
        user != null && token != null && !requiresMfa && !confirmationRequired;
    _log(
      "🔍 isAuthenticated check: $auth (user: ${user != null}, token: ${token != null}, mfa: $requiresMfa, confirmation: $confirmationRequired)",
    );
    return auth;
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
  String? _cachedPassword;

  AuthNotifier(this._apiClient) : super(AuthState()) {
    _log("🔧 AuthNotifier initialized");
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    _log("💾 tryAutoLogin: Checking storage...");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userData = prefs.getString('user_model');

    _log(
      "🟣 tryAutoLogin: Token found: ${token != null}, UserData found: ${userData != null}",
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
        _log("❌ tryAutoLogin: Error parsing stored data: $e");
        state = state.copyWith(isInitialized: true);
      }
    } else {
      _log("🟣 tryAutoLogin: No stored credentials found");
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
    _log(
      "🔑 signIn: Starting sign-in for email: $email, rememberMe: $rememberMe",
    );
    state = state.copyWith(isLoading: true, errorMessage: null);
    _cachedPassword = password;
    _log("🔑 signIn: Password cached for potential post-verification login");

    final response = await _apiClient.signIn(email, password);
    _log(
      "🟣 signIn: API response - success: ${response.success}, message: ${response.message}",
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      _log("🔑 signIn: Processing user data for ${data['user']?['email']}");

      if (rememberMe) {
        _log("💾 signIn: Persisting credentials to SharedPreferences");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_model', jsonEncode(data['user']));
      }

      state = state.copyWith(
        user: UserModel.fromJson(data['user']),
        token: data['token'],
        isLoading: false,
      );
      _log("✅ signIn: Login complete");
    } else {
      _log("❌ signIn: Sign-in failed - ${response.message}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Sign in failed',
      );
    }
  }

  void signOut() async {
    _log("🚪 signOut: Starting sign-out process");
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_model');
    _log("🚪 signOut: Storage cleared");

    _cachedPassword = null;
    _apiClient.clearAuthToken();
    state = AuthState(isInitialized: true);
    _log("✅ signOut: Auth state reset complete");
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _log("📝 signUp: Registering new user: $email (Name: $name)");
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      tempEmail: email,
    );
    _cachedPassword = password;

    final response = await _apiClient.signUp(
      email: email,
      password: password,
      name: name,
    );
    _log("🟣 signUp: API response - success: ${response.success}");

    if (response.success) {
      final confRequired = response.data?['confirmationRequired'] ?? false;
      _log(
        "✅ signUp: Registration success. Confirmation required: $confRequired",
      );
      state = state.copyWith(
        isLoading: false,
        confirmationRequired: confRequired,
      );
    } else {
      _log("❌ signUp: Registration failed - ${response.message}");
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<void> confirmAccount(String code) async {
    _log(
      "✉️ confirmAccount: Attempting code verification for ${state.tempEmail}",
    );
    if (state.tempEmail == null) {
      _log("⚠️ confirmAccount: No tempEmail found in state");
      return;
    }
    state = state.copyWith(isLoading: true);
    final response = await _apiClient.confirmAccount(state.tempEmail!, code);

    if (response.success) {
      _log("✅ confirmAccount: Verification successful");
      if (_cachedPassword != null) {
        _log("🚀 confirmAccount: Cached password found, triggering auto-login");
        await signIn(state.tempEmail!, _cachedPassword!, rememberMe: true);
      } else {
        _log(
          "🟣 confirmAccount: No cached password, user must log in manually",
        );
        state = state.copyWith(isLoading: false, confirmationRequired: false);
      }
    } else {
      _log("❌ confirmAccount: Verification failed - ${response.message}");
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<void> resendCode() async {
    _log("📨 resendCode: Requesting new code for ${state.tempEmail}");
    if (state.tempEmail != null)
      await _apiClient.resendConfirmationCode(state.tempEmail!);
  }

  Future<void> verifyMfa(String code) async {
    _log("🔐 verifyMfa: Starting MFA code verification");
    state = state.copyWith(isLoading: true);
    final response = await _apiClient.verifyMfa(code);
    _log("🟣 verifyMfa: API response success: ${response.success}");

    if (response.success && response.data != null) {
      _log("✅ verifyMfa: MFA Accepted");
      state = state.copyWith(
        user: UserModel.fromJson(response.data!['user']),
        token: response.data!['token'],
        isLoading: false,
        requiresMfa: false,
      );
    } else {
      _log("❌ verifyMfa: MFA Rejected - ${response.message}");
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<bool> forgotPassword(String email) async {
    _log("🔑 forgotPassword: Reset requested for $email");
    state = state.copyWith(isLoading: true);
    final response = await _apiClient.forgotPassword(email);
    state = state.copyWith(isLoading: false);
    _log("🟣 forgotPassword: Success: ${response.success}");
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
    final count = urls.fold(0, (sum, item) => sum + item.clickCount);
    return count;
  }

  double get systemSaturation =>
      (globalStats.totalSystemLinks / 100).clamp(0.0, 1.0);
  double get efficiencyScore =>
      urls.isEmpty ? 0 : (myTotalClicks / urls.length) / 10;

  List<MapDataModel> get mapIntelligence {
    _log("🗺️ mapIntelligence: Mapping geoDistribution to coordinates...");
    final Map<String, List<double>> coords = {
      'PK': [30.3753, 69.3451],
      'US': [37.0902, -95.7129],
      'DE': [51.1657, 10.4515],
      'UK': [55.3781, -3.4360],
      'CN': [35.8617, 104.1954],
      'IN': [20.5937, 78.9629],
    };
    final data = globalStats.geoDistribution.entries.map((e) {
      final c = coords[e.key] ?? [0.0, 0.0];
      return MapDataModel(e.key, e.value, c[0], c[1]);
    }).toList();
    _log("🗺️ mapIntelligence: Created ${data.length} map data points");
    return data;
  }

  List<MapEntry<int, int>> get hourlyActivity {
    return List.generate(
      24,
      (i) => MapEntry(i, (i * 150 % 1000) + (i > 18 ? 2000 : 500)),
    );
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
    state = state.copyWith(isLoading: true);

    _log("📊 loadDashboard: Calling API getDashboardSync...");
    final response = await _apiClient.getDashboardSync();
    _log(
      "🟣 loadDashboard: API response - success: ${response.success}, message: ${response.message}",
    );

    if (response.success && response.data != null) {
      try {
        final data = response.data!;
        _log(
          "🟣 [loadDashboard API Response]: ${jsonEncode(data).substring(0, 100)}...",
        );
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
      } catch (e, stack) {
        _log("❌ loadDashboard: CRITICAL PARSE ERROR: $e");
        debugPrint(stack.toString());
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Data synchronization error",
        );
      }
    } else {
      _log("❌ loadDashboard: Sync failed - ${response.message}");
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<void> createUrl({
    required String originalUrl,
    String? customCode,
  }) async {
    _log("🔗 createUrl: Starting deployment for $originalUrl");
    state = state.copyWith(isLoading: true);
    final response = await _apiClient.createUrl(
      originalUrl: originalUrl,
      customCode: customCode,
    );
    _log("🟣 createUrl: API response success: ${response.success}");

    if (response.success && response.data != null) {
      _log("🔗 createUrl: Parsing new URL data...");
      final newUrl = UrlModel.fromJson(response.data!['url'] ?? response.data!);
      _log("🔗 createUrl: New shortCode - ${newUrl.shortCode}");
      state = state.copyWith(urls: [newUrl, ...state.urls], isLoading: false);
      _log("✅ createUrl: Success. Asset deployed and state updated");
    } else {
      _log("❌ createUrl: Deployment failed - ${response.message}");
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<void> deleteUrl(String id) async {
    _log("🗑️ deleteUrl: Preparing to decommission asset ID: $id");
    final prev = state.urls;

    _log("🗑️ deleteUrl: Performing optimistic state update");
    state = state.copyWith(urls: state.urls.where((u) => u.id != id).toList());

    final response = await _apiClient.deleteUrl(id);
    _log("🟣 deleteUrl: API response success: ${response.success}");

    if (!response.success) {
      _log("❌ deleteUrl: Remote deletion failed. Rolling back state.");
      state = state.copyWith(urls: prev, errorMessage: response.message);
    } else {
      _log("✅ deleteUrl: Asset decommissioned successfully");
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

final authStateProvider = Provider<AuthState>((ref) {
  _log(
    "🏗️ authStateProvider: Providing AuthState - isAuthenticated: ${ref.watch(authProvider).isAuthenticated}",
  );
  return ref.watch(authProvider);
});

final urlsProvider = StateNotifierProvider<UrlsNotifier, UrlsState>((ref) {
  _log("🏗️ urlsProvider: Creating UrlsNotifier instance");
  return UrlsNotifier(ref.watch(apiClientProvider));
});

final regionProvider = StateProvider<String>((ref) {
  _log("🏗️ regionProvider: Defaulting to ${AppConfig.defaultRegion}");
  return AppConfig.defaultRegion;
});
