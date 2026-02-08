import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AuthStatus _status = AuthStatus.unknown;
  String _errorMessage = '';

  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;

  // Initialize: check cookie/session
  Future<void> init() async {
    try {
      await _authService.init(); // Initialize cookie jar
      final isLoggedIn = await _authService.checkAuthStatus();
      _status = isLoggedIn
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // _status = AuthStatus.unknown; // Don't trigger global loading to keep LoginScreen mounted
    _errorMessage = '';
    // notifyListeners();

    try {
      final response = await _authService.login(email, password);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = response.data['error'] ?? 'Login failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Connection error or server unreachable';
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
      _errorMessage = "Passwords do not match";
      notifyListeners();
      return false;
    }

    try {
      // Backend requires age_group. Defaulting to "20".
      final response = await _authService.register(email, password, "20");

      if (response.statusCode == 201) {
        // Registration successful. Auto-login.
        return await login(email, password);
      } else {
        _errorMessage = response.data['error'] ?? 'Registration failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
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
