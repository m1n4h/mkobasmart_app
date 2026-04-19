
// lib/services/debt_service.dart
import 'dart:convert';
import '../models/debt_model.dart';
import 'api_service.dart';

class DebtService {
  Future<List<Debt>> getDebts() async {
    try {
      final response = await ApiService.get('/debts/');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Debt.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching debts: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createDebt(Debt debt) async {
    try {
      final response = await ApiService.post('/debts/', debt.toJson());
      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'error': 'Failed to create debt'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> makePayment(int debtId, double amount, {String note = ''}) async {
    try {
      final response = await ApiService.post('/debts/$debtId/make_payment/', {
        'amount': amount,
        'note': note,
      });
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'error': 'Failed to make payment'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getSummary() async {
    try {
      final response = await ApiService.get('/debts/summary/');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<bool> deleteDebt(int id) async {
    try {
      final response = await ApiService.delete('/debts/$id/');
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
