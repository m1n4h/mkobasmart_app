// lib/services/transaction_service.dart
import 'dart:convert';
import '../models/transaction_model.dart';
import 'api_service.dart';

class TransactionService {
  String _extractError(dynamic body, {String fallback = 'Request failed'}) {
    try {
      if (body is String) {
        final decoded = json.decode(body);
        return _extractError(decoded, fallback: fallback);
      }
      
      if (body is Map<String, dynamic>) {
        // Check for 'error' key (common format)
        final error = body['error'];
        if (error is String && error.isNotEmpty) return error;
        if (error is Map<String, dynamic>) {
          final message = error['message']?.toString();
          if (message != null && message.isNotEmpty) return message;
          final details = error['details'];
          if (details is Map<String, dynamic>) {
            return details.entries
                .map((e) => '${e.key}: ${e.value}')
                .join(', ');
          }
        }
        
        // Check for direct 'message' key
        final message = body['message']?.toString();
        if (message != null && message.isNotEmpty) return message;
        
        // Check for field-specific errors
        final nonFieldErrors = body['non_field_errors'];
        if (nonFieldErrors is List && nonFieldErrors.isNotEmpty) {
          return nonFieldErrors.first.toString();
        }
      }
    } catch (e) {
      // Silently handle parsing errors
    }
    return fallback;
  }

Future<List<Transaction>> getTransactions() async {
  try {
    final response = await ApiService.get('/transactions/');
    
    if (response.statusCode == 200) {
      // 1. Decode as dynamic first, because we don't know if it's a Map or List yet
      final dynamic decodedData = json.decode(response.body);
      
      List<dynamic> listData;

      // 2. Check if it's a Paginated Map (has 'results' key) or a simple List
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('results')) {
        listData = decodedData['results']; 
      } else if (decodedData is List) {
        listData = decodedData;
      } else {
        print('Unexpected JSON structure: $decodedData');
        return [];
      }

      // 3. Map the list to your Transaction objects
      return listData.map((item) => Transaction.fromJson(item)).toList();
    }
    return [];
  } catch (e) {
    // This is where your current error is being caught
    print('Error fetching transactions: $e'); 
    return [];
  }
}
  Future<Map<String, dynamic>> createTransaction(Transaction transaction, {String? receiptPath}) async {
    try {
      String? responseBody;
      if (receiptPath != null && receiptPath.isNotEmpty) {
        final response = await ApiService.postMultipart(
          '/transactions/',
          transaction.toJson().map((key, value) => MapEntry(key, value.toString())),
          receiptPath,
        );
        responseBody = response.body;
        if (response.statusCode == 201) {
          return {'success': true, 'data': json.decode(response.body)};
        }
      } else {
        final response = await ApiService.post('/transactions/', transaction.toJson());
        responseBody = response.body;
        if (response.statusCode == 201) {
          return {'success': true, 'data': json.decode(response.body)};
        }
      }
      return {
        'success': false,
        'error': _extractError(
          responseBody.isNotEmpty ? json.decode(responseBody) : null,
          fallback: 'Failed to create transaction',
        )
      };
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
      return {
        'success': false,
        'error': _extractError(json.decode(response.body), fallback: 'Failed to update transaction')
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteTransaction(int id) async {
    try {
      final response = await ApiService.delete('/transactions/$id/');
      if (response.statusCode == 204) {
        return {'success': true};
      }
      return {
        'success': false,
        'error': _extractError(json.decode(response.body), fallback: 'Failed to delete transaction')
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
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