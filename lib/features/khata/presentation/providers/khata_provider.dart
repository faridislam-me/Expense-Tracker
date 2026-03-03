import 'package:flutter/material.dart';
import '../../../../core/utils/month_key_helper.dart';
import '../../../expense/data/models/expense_model.dart';
import '../../../expense/data/services/expense_service.dart';
import '../../data/models/account_model.dart';
import '../../data/models/member_model.dart';
import '../../data/services/account_service.dart';
import '../../data/services/member_service.dart';
import '../../../auth/data/services/user_service.dart';

class KhataProvider extends ChangeNotifier {
  final AccountService _accountService = AccountService();
  final MemberService _memberService = MemberService();
  final ExpenseService _expenseService = ExpenseService();
  final UserService _userService = UserService();

  AccountModel? _account;
  List<ExpenseModel> _expenses = [];
  List<MemberModel> _members = [];
  bool _isLoading = false;
  String? _error;
  String _selectedMonthKey = MonthKeyHelper.current();

  AccountModel? get account => _account;
  List<ExpenseModel> get expenses => _expenses;
  List<MemberModel> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedMonthKey => _selectedMonthKey;

  double get totalExpenses =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get remainingBudget =>
      (_account?.totalBudget ?? 0) - totalExpenses;

  double get budgetProgress {
    final budget = _account?.totalBudget ?? 0;
    if (budget <= 0) return 0;
    return (totalExpenses / budget).clamp(0.0, 1.0);
  }

  Map<String, double> get categoryTotals {
    final map = <String, double>{};
    for (final expense in _expenses) {
      map[expense.category] = (map[expense.category] ?? 0) + expense.amount;
    }
    return map;
  }

  Future<void> loadKhata(String accountId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _account = await _accountService.getAccount(accountId);
      _members = await _memberService.getMembers(accountId);
      await loadExpenses(accountId);
    } catch (e) {
      _error = 'Failed to load khata';
      debugPrint('[KHATA] loadKhata error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadExpenses(String accountId, {String? monthKey}) async {
    try {
      if (monthKey != null) _selectedMonthKey = monthKey;

      if (_account?.trackingType == 'monthly') {
        _expenses = await _expenseService.getExpensesByMonth(
          accountId,
          _selectedMonthKey,
        );
      } else {
        _expenses = await _expenseService.getExpenses(accountId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[KHATA] loadExpenses error: $e');
    }
  }

  Future<String> createKhata({
    required String name,
    required String trackingType,
    required double totalBudget,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final account = AccountModel(
        id: '',
        name: name,
        trackingType: trackingType,
        totalBudget: totalBudget,
        createdBy: userId,
        createdAt: DateTime.now(),
      );

      final created = await _accountService.createAccount(account);

      // Add creator as owner member
      final member = MemberModel(
        userId: userId,
        name: userName,
        email: userEmail,
        role: 'owner',
        joinedAt: DateTime.now(),
      );
      await _memberService.addMember(created.id, member);

      // Add accountId to user's list
      await _userService.addAccountToUser(userId, created.id);

      _isLoading = false;
      notifyListeners();
      return created.id;
    } catch (e) {
      _error = 'Failed to create khata';
      _isLoading = false;
      notifyListeners();
      debugPrint('[KHATA] createKhata error: $e');
      rethrow;
    }
  }

  Future<void> updateKhata({
    required String accountId,
    String? name,
    double? totalBudget,
    String? trackingType,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (totalBudget != null) data['totalBudget'] = totalBudget;
      if (trackingType != null) data['trackingType'] = trackingType;

      await _accountService.updateAccount(accountId, data);
      _account = _account?.copyWith(
        name: name,
        totalBudget: totalBudget,
        trackingType: trackingType,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update khata';
      notifyListeners();
    }
  }

  void setMonthKey(String monthKey) {
    _selectedMonthKey = monthKey;
    if (_account != null) {
      loadExpenses(_account!.id, monthKey: monthKey);
    }
  }

  void clear() {
    _account = null;
    _expenses = [];
    _members = [];
    _error = null;
    notifyListeners();
  }
}
