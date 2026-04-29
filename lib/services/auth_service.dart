// lib/services/auth_service.dart
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  String _extractError(dynamic body, {String fallback = 'Request failed'}) {
    if (body is Map<String, dynamic>) {
      final error = body['error'];
      if (error is String && error.isNotEmpty) return error;
      if (error is Map<String, dynamic>) {
        final message = error['message']?.toString();
        if (message != null && message.isNotEmpty) return message;
      }
      final message = body['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
    return fallback;
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await _saveTokens(data['access'], data['refresh']);
        return {'success': true, 'user': User.fromJson(data['user'])};
      } else {
        final body = json.decode(response.body);
        return {'success': false, 'error': _extractError(body, fallback: 'Failed to register')};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveTokens(data['access'], data['refresh']);
        return {'success': true, 'user': User.fromJson(data['user'])};
      } else {
        final body = json.decode(response.body);
        return {'success': false, 'error': _extractError(body, fallback: 'Login failed')};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> guestLogin() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/guest_login/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveTokens(data['access'], data['refresh']);
        return {'success': true, 'user': User.fromJson(data['user'])};
      } else {
        final body = json.decode(response.body);
        return {'success': false, 'error': _extractError(body, fallback: 'Guest login failed')};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }



Future<Map<String, dynamic>> googleLogin({required String email, required String name}) async {
  // Ensure ApiService.baseUrl is "http://192.168.0.107:8000/api"
  final String url = "${ApiService.baseUrl}/auth/google_login/"; 

  try {
    print('Sending POST to: $url');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'name': name,
      }),
    );

    print('Server Response Code: ${response.statusCode}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // DON'T FORGET TO SAVE TOKENS
      await _saveTokens(data['access'], data['refresh']);
      return {'success': true, 'user': User.fromJson(data['user'])};
    } else {
      final body = jsonDecode(response.body);
      return {'success': false, 'error': _extractError(body)};
    }
  } catch (e) {
    print('Flutter Error Details: $e');
    return {'success': false, 'error': 'Connection failed: $e'};
  }
}

  Future<void> _saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
    await prefs.setBool('is_logged_in', true);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await ApiService.get('/auth/me/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final user = User.fromJson(data['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', user.email);
        await prefs.setString('user_name', user.fullName);
        await prefs.setBool('is_admin', user.isAdmin);
        await prefs.setBool('is_guest', user.isGuest);

        return {'success': true, 'user': user};
      }
      final body = json.decode(response.body);
      return {'success': false, 'error': _extractError(body, fallback: 'Failed to fetch profile')};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  // update profile user 
  
  // Add these to your existing AuthService class
Future<Map<String, dynamic>> updateProfile({String? name, String? email, String? imagePath}) async {
  try {
    // If you have a profile picture, you'd use a MultipartRequest here
    final response = await ApiService.put('/auth/profile/update/', {
      'full_name': name,
      'email': email,
      // 'image': imagePath, // Handle image upload logic if applicable
    });
    return {'success': response.statusCode == 200};
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}

// change the password
Future<Map<String, dynamic>> changePassword(String newPassword) async {
  try {
    final response = await ApiService.post('/auth/password/change/', {
      'new_password': newPassword,
    });
    return {'success': response.statusCode == 200};
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}
}