// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.107:8000/api';
  // For Android emulator, use: 'http://10.0.2.2:8000/api'
  // For iOS simulator, use: 'http://localhost:8000/api'
  
  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.setBool('is_logged_in', false);
  }

  static Future<bool> _refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString('refresh_token');
    if (refresh == null || refresh.isEmpty) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh': refresh}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final newAccess = data['access']?.toString();
      final newRefresh = data['refresh']?.toString();
      if (newAccess != null && newAccess.isNotEmpty) {
        await prefs.setString('access_token', newAccess);
      }
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await prefs.setString('refresh_token', newRefresh);
      }
      await prefs.setBool('is_logged_in', true);
      return true;
    }

    await _clearSession();
    return false;
  }

  static Future<http.Response> _requestWithRefresh(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    var headers = await getHeaders();
    var response = await request(headers);
    if (response.statusCode != 401) return response;

    final refreshed = await _refreshAccessToken();
    if (!refreshed) return response;

    headers = await getHeaders();
    return request(headers);
  }

  static Future<http.Response> get(String endpoint) async {
    return _requestWithRefresh(
      (headers) => http.get(Uri.parse('$baseUrl$endpoint'), headers: headers),
    );
  }

  static Future<http.Response> post(String endpoint, dynamic data) async {
    return _requestWithRefresh(
      (headers) => http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      ),
    );
  }

  static Future<http.Response> put(String endpoint, dynamic data) async {
    return _requestWithRefresh(
      (headers) => http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      ),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    return _requestWithRefresh(
      (headers) => http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers),
    );
  }

  static Future<http.Response> postMultipart(String endpoint, Map<String, String> data, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );
    
    request.headers['Authorization'] = 'Bearer $token';
    
    for (var entry in data.entries) {
      request.fields[entry.key] = entry.value;
    }
    
    if (filePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('receipt_image', filePath));
    }
    
    var response = await request.send();
    return http.Response.fromStream(response);
  }
}
