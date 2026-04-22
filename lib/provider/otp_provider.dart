// lib/providers/otp_provider.dart
import 'package:flutter/material.dart';
import '../services/otp_service.dart';

class OTPProvider extends ChangeNotifier {
  final OTPService _otpService = OTPService();
  
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<bool> sendOTP({
    required String identifier,
    required bool isEmail,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _otpService.sendOTP(
        identifier: identifier,
        isEmail: isEmail,
      );
      
      _setLoading(false);
      
      if (result['success']) {
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> verifyOTP({
    required String identifier,
    required String otp,
    required bool isEmail,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _otpService.verifyOTP(
        identifier: identifier,
        otp: otp,
        isEmail: isEmail,
      );
      
      _setLoading(false);
      
      if (result['success']) {
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
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