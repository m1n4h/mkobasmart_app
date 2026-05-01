import 'dart:convert';
import '../models/user_model.dart';
import 'api_service.dart';

class AdminService {
  // Helper to extract errors from dynamic bodies similar to BudgetService
  String _extractError(dynamic body, {String fallback = 'Admin request failed'}) {
    try {
      if (body is Map<String, dynamic> && body.containsKey('error')) {
        return body['error']['message'] ?? fallback;
      }
    } catch (_) {}
    return fallback;
  }

  // Fetch KPI Stats for Dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await ApiService.get('/admin-management/dashboard_stats/');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // lib/services/admin_service.dart

Future<List<User>> getAllUsers() async {
  try {
    final response = await ApiService.get('/user-management/');
    if (response.statusCode == 200) {
      final dynamic decodedData = json.decode(response.body);

      List<dynamic> userList;
      
      // Check if backend returned paginated data
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('results')) {
        userList = decodedData['results'];
      } else if (decodedData is List) {
        userList = decodedData;
      } else {
        return [];
      }

      return userList.map((json) => User.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    print("MAPPING ERROR: $e");
    return [];
  }
}

  // USER CRUD: Delete User
  Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final response = await ApiService.delete('/user-management/$id/');
      if (response.statusCode == 204) return {'success': true};
      return {'success': false, 'error': 'Failed to delete user'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Fetch System Logs
  Future<List<dynamic>> getSystemLogs() async {
    try {
      final response = await ApiService.get('/admin-management/system_logs/');
      if (response.statusCode == 200) return json.decode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }
}