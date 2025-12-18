import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../middleware/api_client.dart';
import '../models/models.dart';
import '../config.dart';

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? errorMessage;
  final bool requiresMfa;
  final bool confirmationRequired;
  final String? tempEmail;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.errorMessage,
    this.requiresMfa = false,
    this.confirmationRequired = false,
    this.tempEmail,
  });

  bool get isAuthenticated =>
      user != null && token != null && !requiresMfa && !confirmationRequired;

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    String? errorMessage,
    bool? requiresMfa,
    bool? confirmationRequired,
    String? tempEmail,
    bool clearUser = false, // Magic flag to force logout
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      token: clearUser ? null : (token ?? this.token),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      requiresMfa: requiresMfa ?? this.requiresMfa,
      confirmationRequired: confirmationRequired ?? this.confirmationRequired,
      tempEmail: tempEmail ?? this.tempEmail,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;

  AuthNotifier(this._apiClient) : super(AuthState());

  Future<void> signIn(String email, String password) async {
    // Reset any previous errors or stuck states before starting
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _apiClient.signIn(email, password);

    if (response.success && response.data != null) {
      final data = response.data!;
      state = state.copyWith(
        user: UserModel.fromJson(data['user']),
        token: data['token'],
        isLoading: false,
        requiresMfa: false,
        confirmationRequired: false,
      );
    } else {
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
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      tempEmail: email,
    );
    final response = await _apiClient.signUp(
      email: email,
      password: password,
      name: name,
    );

    if (response.success) {
      final confRequired = response.data?['confirmationRequired'] ?? false;
      state = state.copyWith(
        isLoading: false,
        confirmationRequired: confRequired,
        errorMessage: null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Sign up failed',
      );
    }
  }

  Future<void> confirmAccount(String code) async {
    if (state.tempEmail == null) {
      state = state.copyWith(errorMessage: 'Email lost. Please sign up again.');
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _apiClient.confirmAccount(state.tempEmail!, code);

    if (response.success) {
      state = state.copyWith(
        isLoading: false,
        confirmationRequired: false,
        requiresMfa: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Verification failed',
      );
    }
  }

  Future<void> resendCode() async {
    if (state.tempEmail == null) return;
    await _apiClient.resendConfirmationCode(state.tempEmail!);
  }

  Future<void> verifyMfa(String code) async {
    state = state.copyWith(isLoading: true);
    final response = await _apiClient.verifyMfa(code);

    if (response.success && response.data != null) {
      state = state.copyWith(
        user: UserModel.fromJson(response.data!['user']),
        token: response.data!['token'],
        isLoading: false,
        requiresMfa: false,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _apiClient.forgotPassword(email);
    state = state.copyWith(
      isLoading: false,
      errorMessage: response.success ? null : response.message,
    );
    return response.success;
  }

  void signOut() {
    _apiClient.clearAuthToken();
    // COMPLETE RESET
    state = AuthState();
  }
}

// --- URLS STATE ---
class UrlsState {
  final List<UrlModel> urls;
  final GlobalStatsModel globalStats; // <--- The "Stupidity" Data
  final bool isLoading;
  final String? errorMessage;

  UrlsState({
    this.urls = const [],
    GlobalStatsModel? globalStats,
    this.isLoading = false,
    this.errorMessage,
  }) : globalStats = globalStats ?? GlobalStatsModel.empty();

  // Local Metric: Sum of my own clicks
  int get myTotalClicks => urls.fold(0, (sum, item) => sum + item.clickCount);

  UrlsState copyWith({
    List<UrlModel>? urls,
    GlobalStatsModel? globalStats,
    bool? isLoading,
    String? errorMessage,
  }) {
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
  UrlsNotifier(this._apiClient) : super(UrlsState());

  Future<void> loadDashboard() async {
    print("🔵 [PROVIDER] Loading Dashboard...");
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _apiClient.getDashboardSync();

    if (response.success && response.data != null) {
      try {
        final data = response.data!;
        print("🔵 [PROVIDER] Parsing Data...");

        // Robust Parsing for URLs
        List<UrlModel> urls = [];
        if (data['urls'] != null) {
          final List<dynamic> urlList = data['urls'];
          urls = urlList
              .map((e) {
                try {
                  return UrlModel.fromJson(e);
                } catch (e) {
                  print("⚠️ Failed to parse specific URL: $e");
                  return null;
                }
              })
              .whereType<UrlModel>()
              .toList();
        }

        // Robust Parsing for Global Stats
        GlobalStatsModel global = GlobalStatsModel.empty();
        if (data['globalStats'] != null) {
          global = GlobalStatsModel.fromJson(data['globalStats']);
        }

        print("✅ [PROVIDER] Loaded ${urls.length} URLs and Global Stats");
        state = state.copyWith(
          urls: urls,
          globalStats: global,
          isLoading: false,
        );
      } catch (e, stack) {
        print("❌ [PROVIDER] CRITICAL PARSE ERROR: $e");
        print(stack);
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Data format error: $e",
        );
      }
    } else {
      print("❌ [PROVIDER] API Failed: ${response.message}");
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<void> createUrl({
    required String originalUrl,
    String? customCode,
  }) async {
    print("🔵 [PROVIDER] Creating URL: $originalUrl");
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _apiClient.createUrl(
      originalUrl: originalUrl,
      customCode: customCode,
    );

    if (response.success && response.data != null) {
      try {
        // Handle nested 'url' object if present, or flat response
        final urlData = response.data!['url'] ?? response.data!;
        final newUrl = UrlModel.fromJson(urlData);

        print("✅ [PROVIDER] URL Created: ${newUrl.shortCode}");
        state = state.copyWith(urls: [newUrl, ...state.urls], isLoading: false);
      } catch (e) {
        print("❌ [PROVIDER] Failed to parse Created URL: $e");
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Created but failed to display.",
        );
      }
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? "Failed to create URL",
      );
    }
  }

  Future<void> deleteUrl(String id) async {
    print("🔵 [PROVIDER] Deleting URL: $id");
    final previousUrls = state.urls;
    state = state.copyWith(urls: state.urls.where((u) => u.id != id).toList());

    final response = await _apiClient.deleteUrl(id);
    if (!response.success) {
      print("❌ [PROVIDER] Delete failed, rolling back.");
      state = state.copyWith(
        urls: previousUrls,
        errorMessage: response.message,
      );
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final urlsProvider = StateNotifierProvider<UrlsNotifier, UrlsState>(
  (ref) => UrlsNotifier(ref.watch(apiClientProvider)),
);

// Auth Provider Definitions (Simplified for context)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiClientProvider));
});

final regionProvider = StateProvider<String>((ref) => AppConfig.defaultRegion);
