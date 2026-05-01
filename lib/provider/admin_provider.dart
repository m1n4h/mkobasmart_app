import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  Map<String, dynamic> _stats = {};
  List<User> _users = [];
  List<dynamic> _logs = [];
  bool _isLoading = false;

  Map<String, dynamic> get stats => _stats;
  List<User> get users => _users;
  List<dynamic> get logs => _logs;
  bool get isLoading => _isLoading;

// lib/provider/admin_provider.dart

Future<void> fetchAdminData() async {
  _isLoading = true;
  // Use a try-catch to prevent silent failures that lead to empty lists
  try {
    _stats = await _adminService.getDashboardStats();
    _users = await _adminService.getAllUsers();
    _logs = await _adminService.getSystemLogs();
    
    debugPrint("Successfully parsed ${_users.length} users");
  } catch (e) {
    debugPrint("Provider Mapping Error: $e");
  } finally {
    _isLoading = false;
    notifyListeners(); 
  }
}

  Future<bool> removeUser(int id) async {
    final result = await _adminService.deleteUser(id);
    if (result['success']) {
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}