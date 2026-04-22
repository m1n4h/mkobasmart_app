// lib/providers/debt_provider.dart
import 'package:flutter/material.dart';
import '../models/debt_model.dart';
import '../services/debt_service.dart';

class DebtProvider extends ChangeNotifier {
  final DebtService _debtService = DebtService();
  
  List<Debt> _debts = [];
  bool _isLoading = false;
  String? _error;

  List<Debt> get debts => _debts;
  List<Debt> get debtsOwedToMe => _debts.where((d) => d.isOwedToMe).toList();
  List<Debt> get debtsIOwe => _debts.where((d) => !d.isOwedToMe).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  double get totalOwedToMe => debtsOwedToMe.fold(0, (sum, d) => sum + d.remainingAmount);
  double get totalIOwe => debtsIOwe.fold(0, (sum, d) => sum + d.remainingAmount);
  int get activeDebtsOwed => debtsOwedToMe.where((d) => d.status != 'paid').length;
  int get activeDebtsToPay => debtsIOwe.where((d) => d.status != 'paid').length;

  Future<void> fetchDebts() async {
    _setLoading(true);
    try {
      _debts = await _debtService.getDebts();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> addDebt(Debt debt) async {
    _setLoading(true);
    try {
      final result = await _debtService.createDebt(debt);
      if (result['success']) {
        await fetchDebts();
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

  Future<bool> makePayment(int debtId, double amount) async {
    _setLoading(true);
    try {
      final result = await _debtService.makePayment(debtId, amount);
      if (result['success']) {
        await fetchDebts();
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

  Future<bool> deleteDebt(int id) async {
    _setLoading(true);
    try {
      final result = await _debtService.deleteDebt(id);
      if (result['success'] == true) {
        await fetchDebts();
        _setLoading(false);
        return true;
      } else {
        _error = result['error']?.toString() ?? 'Failed to delete debt';
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