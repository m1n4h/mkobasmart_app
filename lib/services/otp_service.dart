// lib/services/otp_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class OTPService {
  static const String baseUrl = '${ApiService.baseUrl}/otp/';
  
  Future<Map<String, dynamic>> sendOTP({
    required String identifier,
    required bool isEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'identifier': identifier,
          'type': isEmail ? 'email' : 'phone',
        }),
      );
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to send OTP'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  Future<Map<String, dynamic>> verifyOTP({
    required String identifier,
    required String otp,
    required bool isEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'identifier': identifier,
          'otp': otp,
          'type': isEmail ? 'email' : 'phone',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final decoded = json.decode(response.body);
        return {'success': false, 'error': decoded['error'] ?? 'Invalid OTP'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> persistVerificationSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data['access'] != null) {
      await prefs.setString('access_token', data['access']);
    }
    if (data['refresh'] != null) {
      await prefs.setString('refresh_token', data['refresh']);
    }
    await prefs.setBool('is_logged_in', true);
  }
}