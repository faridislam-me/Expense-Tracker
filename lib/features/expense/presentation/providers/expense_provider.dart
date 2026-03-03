import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/month_key_helper.dart';
import '../../data/models/expense_model.dart';
import '../../data/services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<ExpenseModel?> addExpense({
    required String accountId,
    required double amount,
    required String category,
    required String description,
    required DateTime date,
    required String addedBy,
    String? receiptUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final expense = ExpenseModel(
        id: '',
        amount: amount,
        category: category,
        description: description,
        date: date,
        addedBy: addedBy,
        monthKey: MonthKeyHelper.fromDate(date),
        receiptUrl: receiptUrl,
        createdAt: DateTime.now(),
      );

      final created = await _expenseService.addExpense(accountId, expense);
      _isLoading = false;
      notifyListeners();
      return created;
    } catch (e) {
      _error = 'Failed to add expense';
      _isLoading = false;
      notifyListeners();
      debugPrint('[EXPENSE] addExpense error: $e');
      return null;
    }
  }

  Future<bool> updateExpense({
    required String accountId,
    required String expenseId,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? receiptUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{};
      if (amount != null) data['amount'] = amount;
      if (category != null) data['category'] = category;
      if (description != null) data['description'] = description;
      if (date != null) {
        data['date'] = Timestamp.fromDate(date);
        data['monthKey'] = MonthKeyHelper.fromDate(date);
      }
      if (receiptUrl != null) data['receiptUrl'] = receiptUrl;

      await _expenseService.updateExpense(accountId, expenseId, data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update expense';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(String accountId, String expenseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _expenseService.deleteExpense(accountId, expenseId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete expense';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
