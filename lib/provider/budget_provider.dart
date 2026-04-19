// lib/providers/budget_provider.dart
import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _budgetService = BudgetService();
  
  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  double get totalBudget => _budgets.fold(0, (sum, b) => sum + b.amount);
  double get totalSpent => _budgets.fold(0, (sum, b) => sum + b.spentAmount);
  double get totalRemaining => totalBudget - totalSpent;

  Future<void> fetchBudgets() async {
    _setLoading(true);
    try {
      _budgets = await _budgetService.getBudgets();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> addBudget(Budget budget) async {
    _setLoading(true);
    try {
      final result = await _budgetService.createBudget(budget);
      if (result['success']) {
        await fetchBudgets();
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

  Future<bool> deleteBudget(int id) async {
    _setLoading(true);
    try {
      final success = await _budgetService.deleteBudget(id);
      if (success) {
        await fetchBudgets();
        _setLoading(false);
        return true;
      } else {
        _error = 'Failed to delete budget';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
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