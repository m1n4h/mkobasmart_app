// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  get token => null;

 // lib/providers/auth_provider.dart

// Update the login method
Future<bool> login({
  String? email,
  String? phone,
  required String password,
}) async {
  _setLoading(true);
  _clearError();

  try {
    final result = await _authService.login(
      email: email,
      phone: phone,
      password: password,
    );

    if (result['success']) {
      _currentUser = result['user'];
      _setLoading(false);
      return true;
    } else {
      // Extract the error code and message
      final errorData = result['error'];
      final String code = errorData['code'] ?? '';
      final String message = errorData['message'] ?? 'Login failed';

      if (code == 'account_not_found') {
        _error = "USER_NOT_FOUND"; // Custom flag for UI
      } else {
        _error = message;
      }
      
      _setLoading(false);
      return false;
    }
  } catch (e) {
    _error = "Connection Error";
    _setLoading(false);
    return false;
  }
}

// Update the register method
Future<bool> register({
  required String username,
  required String email,
  required String password,
  String? phoneNumber,
  String? firstName,
  String? lastName,
}) async {
  _setLoading(true);
  _clearError();

  try {
    final result = await _authService.register(
      username: username,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
    );

    if (result['success']) {
      _currentUser = result['user'];
      _setLoading(false);
      return true;
    } else {
      final errorData = result['error'];
      final String code = errorData['code'] ?? '';
      
      if (code == 'user_exists') {
        _error = "USER_ALREADY_EXISTS"; // Custom flag for UI
      } else {
        _error = errorData['message'] ?? 'Registration failed';
      }
      
      _setLoading(false);
      return false;
    }
  } catch (e) {
    _error = "Connection Error";
    _setLoading(false);
    return false;
  }
}

  Future<bool> guestLogin() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.guestLogin();

      if (result['success']) {
        _currentUser = result['user'];
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _error = result['error'].toString();
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
Future<bool> googleLogin({required String email, required String name}) async {
  _setLoading(true);
  _clearError();

  try {
    // Pass the data to your service!
    final result = await _authService.googleLogin(email: email, name: name);

    if (result['success']) {
      _currentUser = result['user'];
      // Store your tokens here (Access/Refresh)
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _error = result['error']?['message'] ?? 'Login failed';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  } catch (e) {
    _error = "Connection Error: Check if server is running";
    _setLoading(false);
    notifyListeners();
    return false;
  }
}
// lib/providers/auth_provider.dart

Future<void> logout() async {
  // 1. Call the backend service to invalidate the token/session
  await _authService.logout();

  // 2. Clear all local session data to force a fresh login
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('is_logged_in');
  await prefs.remove('is_admin');
  await prefs.remove('token'); // If you store the JWT here

  // 3. Reset the in-memory user and notify the UI
  _currentUser = null;
  notifyListeners();
}

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
