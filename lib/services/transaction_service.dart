// lib/services/transaction_service.dart
import 'dart:convert';
import '../models/transaction_model.dart';
import 'api_service.dart';

class TransactionService {
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await ApiService.get('/transactions/');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Transaction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createTransaction(Transaction transaction, {String? receiptPath}) async {
    try {
      if (receiptPath != null && receiptPath.isNotEmpty) {
        final response = await ApiService.postMultipart(
          '/transactions/',
          transaction.toJson().map((key, value) => MapEntry(key, value.toString())),
          receiptPath,
        );
        if (response.statusCode == 201) {
          return {'success': true, 'data': json.decode(response.body)};
        }
      } else {
        final response = await ApiService.post('/transactions/', transaction.toJson());
        if (response.statusCode == 201) {
          return {'success': true, 'data': json.decode(response.body)};
        }
      }
      return {'success': false, 'error': 'Failed to create transaction'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateTransaction(int id, Transaction transaction) async {
    try {
      final response = await ApiService.put('/transactions/$id/', transaction.toJson());
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'error': 'Failed to update transaction'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      final response = await ApiService.delete('/transactions/$id/');
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getSummary(String period) async {
    try {
      final response = await ApiService.get('/transactions/summary/?period=$period');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}