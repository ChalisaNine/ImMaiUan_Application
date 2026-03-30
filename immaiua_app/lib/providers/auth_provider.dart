import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AuthStatus _status = AuthStatus.unknown;
  String _errorMessage = '';

  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  AuthService get authService => _authService;

  Future<void> init() async {
    try {
      await _authService.init();
      final isLoggedIn = await _authService.checkAuthStatus();
      _status =
          isLoggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = '';

    if (_authService.cookieJar == null) {
      await _authService.init();
    }

    try {
      final response = await _authService.login(email, password);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }

      _status = AuthStatus.unauthenticated;
      _errorMessage = response.data['error'] ?? 'Login failed';
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      debugPrint('Login Error: $e\n$stackTrace');
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Connection error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password,
    String confirmPassword,
  ) async {
    _errorMessage = '';

    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }

    try {
      final response = await _authService.register(email, password, '20');

      if (response.statusCode == 201) {
        return await login(email, password);
      }

      _errorMessage = response.data['error'] ?? 'Registration failed';
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Connection error';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
