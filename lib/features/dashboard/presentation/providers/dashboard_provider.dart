import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../khata/data/models/account_model.dart';

class DashboardProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<AccountModel> _accounts = [];
  bool _isLoading = false;
  String? _error;

  List<AccountModel> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBudget =>
      _accounts.fold(0.0, (s, a) => s + a.totalBudget);

  Future<void> loadAccounts(List<String> accountIds) async {
    if (accountIds.isEmpty) {
      _accounts = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<AccountModel> loaded = [];
      // Firestore whereIn limited to 30 items
      for (var i = 0; i < accountIds.length; i += 30) {
        final batch = accountIds.sublist(
          i,
          i + 30 > accountIds.length ? accountIds.length : i + 30,
        );
        final snapshot = await _firestore
            .collection(FirestorePaths.accounts)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        loaded.addAll(
          snapshot.docs.map(
            (doc) =>
                AccountModel.fromMap(doc.data(), doc.id),
          ),
        );
      }
      _accounts = loaded;
    } catch (e) {
      _error = 'Failed to load accounts';
      debugPrint('[DASHBOARD] loadAccounts error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _accounts = [];
    notifyListeners();
  }
}
