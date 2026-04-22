
// lib/services/debt_service.dart
import 'dart:convert';
import '../models/debt_model.dart';
import 'api_service.dart';

class DebtService {
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
      return {
        'success': false,
        'error': _extractError(json.decode(response.body), fallback: 'Failed to create debt'),
      };
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
      return {
        'success': false,
        'error': _extractError(json.decode(response.body), fallback: 'Failed to make payment'),
      };
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

  Future<Map<String, dynamic>> deleteDebt(int id) async {
    try {
      final response = await ApiService.delete('/debts/$id/');
      if (response.statusCode == 204) {
        return {'success': true};
      }
      return {
        'success': false,
        'error': _extractError(json.decode(response.body), fallback: 'Failed to delete debt'),
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
