// lib/providers/transaction_provider.dart
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = false;
  String? _error;
  double _totalIncome = 0;
  double _totalExpenses = 0;
  String _currentFilter = 'All';

  List<Transaction> get transactions => _transactions;
  List<Transaction> get filteredTransactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;
  double get netSavings => _totalIncome - _totalExpenses;

  Future<void> fetchTransactions() async {
    _setLoading(true);
    try {
      _transactions = await _transactionService.getTransactions();
      _filteredTransactions = List.from(_transactions);
      _calculateTotals();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> addTransaction(Transaction transaction, {String? receiptPath}) async {
    _setLoading(true);
    try {
      final result = await _transactionService.createTransaction(transaction, receiptPath: receiptPath);
      if (result['success']) {
        await fetchTransactions();
        _setLoading(false);
        return true;
      } else {
        _error = result['error'];
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    _setLoading(true);
    try {
      final result = await _transactionService.updateTransaction(transaction.id, transaction);
      if (result['success']) {
        await fetchTransactions();
        _setLoading(false);
        return true;
      } else {
        _error = result['error'];
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    _setLoading(true);
    try {
      final success = await _transactionService.deleteTransaction(id);
      if (success) {
        await fetchTransactions();
        _setLoading(false);
        return true;
      } else {
        _error = 'Failed to delete transaction';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void filterByType(String type) {
    if (type == 'All') {
      _filteredTransactions = List.from(_transactions);
    } else {
      _filteredTransactions = _transactions
          .where((t) => t.transactionType.toLowerCase() == type.toLowerCase())
          .toList();
    }
    _currentFilter = type;
    _calculateTotals();
    notifyListeners();
  }

  void filterByPeriod(String period) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (period) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        _filteredTransactions = List.from(_transactions);
        _calculateTotals();
        notifyListeners();
        return;
    }
    
    _filteredTransactions = _transactions
        .where((t) => t.date.isAfter(startDate))
        .toList();
    _calculateTotals();
    notifyListeners();
  }

  void searchTransactions(String query) {
    if (query.isEmpty) {
      _filteredTransactions = List.from(_transactions);
    } else {
      _filteredTransactions = _transactions
          .where((t) => t.description.toLowerCase().contains(query.toLowerCase()) ||
              (t.categoryName?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    }
    notifyListeners();
  }

  void _calculateTotals() {
    _totalIncome = _filteredTransactions
        .where((t) => t.transactionType == 'income')
        .fold(0, (sum, t) => sum + t.amount);
    
    _totalExpenses = _filteredTransactions
        .where((t) => t.transactionType == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
