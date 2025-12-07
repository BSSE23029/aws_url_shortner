import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Simple state management without external packages
class AppState extends ChangeNotifier {
  UserModel? _currentUser;
  String? _authToken;
  String? _refreshToken;
  List<UrlModel> _urls = [];
  bool _isLoading = false;
  String? _currentRegion;

  // Getters
  UserModel? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null && _currentUser != null;
  List<UrlModel> get urls => List.unmodifiable(_urls);
  bool get isLoading => _isLoading;
  String get currentRegion => _currentRegion ?? 'us-east-1';

  // Authentication methods
  void login(UserModel user, String token, String refreshToken) {
    _currentUser = user;
    _authToken = token;
    _refreshToken = refreshToken;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _authToken = null;
    _refreshToken = null;
    _urls = [];
    notifyListeners();
  }

  void updateToken(String newToken) {
    _authToken = newToken;
    notifyListeners();
  }

  // URL management (optimistic updates)
  void addUrlOptimistic(UrlModel url) {
    _urls.insert(0, url);
    notifyListeners();
  }

  void updateUrl(UrlModel url) {
    final index = _urls.indexWhere((u) => u.id == url.id);
    if (index != -1) {
      _urls[index] = url;
      notifyListeners();
    }
  }

  void removeUrl(String urlId) {
    _urls.removeWhere((u) => u.id == urlId);
    notifyListeners();
  }

  void setUrls(List<UrlModel> urls) {
    _urls = urls;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setCurrentRegion(String region) {
    _currentRegion = region;
    notifyListeners();
  }

  // Simulate optimistic update with rollback capability
  String? _lastRemovedUrlId;
  UrlModel? _lastRemovedUrl;

  void removeUrlOptimistic(String urlId) {
    final index = _urls.indexWhere((u) => u.id == urlId);
    if (index != -1) {
      _lastRemovedUrlId = urlId;
      _lastRemovedUrl = _urls[index];
      _urls.removeAt(index);
      notifyListeners();
    }
  }

  void rollbackLastRemoval() {
    if (_lastRemovedUrl != null) {
      _urls.insert(0, _lastRemovedUrl!);
      _lastRemovedUrl = null;
      _lastRemovedUrlId = null;
      notifyListeners();
    }
  }
}
