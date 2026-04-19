
// lib/services/budget_service.dart
import 'dart:convert';
import '../models/budget_model.dart';
import 'api_service.dart';

class BudgetService {
  Future<List<Budget>> getBudgets() async {
    try {
      final response = await ApiService.get('/budgets/');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Budget.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching budgets: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createBudget(Budget budget) async {
    try {
      final response = await ApiService.post('/budgets/', budget.toJson());
      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'error': 'Failed to create budget'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<List<Budget>> getCurrentBudgets() async {
    try {
      final response = await ApiService.get('/budgets/current/');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Budget.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteBudget(int id) async {
    try {
      final response = await ApiService.delete('/budgets/$id/');
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}