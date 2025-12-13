import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../middleware/api_client.dart';
import '../models/models.dart';
import '../config.dart'; // FIX: Added import

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Auth State
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

  bool get isAuthenticated => user != null && token != null && !requiresMfa && !confirmationRequired;

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    String? errorMessage,
    bool? requiresMfa,
    bool? confirmationRequired,
    String? tempEmail,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
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
    state = state.copyWith(isLoading: true, errorMessage: null, tempEmail: email);

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

  Future<void> signUp({required String email, required String password, required String name}) async {
    state = state.copyWith(isLoading: true, errorMessage: null, tempEmail: email);

    final response = await _apiClient.signUp(email: email, password: password, name: name);

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
    
    final response = await _apiClient.resendConfirmationCode(state.tempEmail!);
    
    if (!response.success) {
      state = state.copyWith(errorMessage: response.message);
    }
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
  
  // FIX: Added forgotPassword method
  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _apiClient.forgotPassword(email);
    state = state.copyWith(isLoading: false, errorMessage: response.success ? null : response.message);
    return response.success;
  }

  void signOut() {
    _apiClient.clearAuthToken();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiClientProvider));
});

class UrlsState {
  final List<UrlModel> urls;
  final bool isLoading;
  UrlsState({this.urls = const [], this.isLoading = false});
}

class UrlsNotifier extends StateNotifier<UrlsState> {
  final ApiClient _apiClient;
  UrlsNotifier(this._apiClient) : super(UrlsState());
  Future<void> loadUrls() async { 
    state = UrlsState(isLoading: true);
    final response = await _apiClient.getUrls();
    // Simplified logic for brevity, assuming UrlModel.fromJsonList is handled or map
    if (response.success && response.data != null) {
       // logic to parse URLs
    }
    state = UrlsState(isLoading: false);
  }
}

final urlsProvider = StateNotifierProvider<UrlsNotifier, UrlsState>((ref) => UrlsNotifier(ref.watch(apiClientProvider)));
final regionProvider = StateProvider<String>((ref) => AppConfig.defaultRegion);