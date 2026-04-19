// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
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

  Future<bool> googleLogin({
    required String email,
    required String name,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.googleLogin(
        email: email,
        name: name,
      );

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

  Future<void> logout() async {
    await _authService.logout();
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
