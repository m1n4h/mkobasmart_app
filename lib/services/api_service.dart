// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
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

  static Future<http.Response> get(String endpoint) async {
    final headers = await getHeaders();
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  static Future<http.Response> post(String endpoint, dynamic data) async {
    final headers = await getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
  }

  static Future<http.Response> put(String endpoint, dynamic data) async {
    final headers = await getHeaders();
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await getHeaders();
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
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
