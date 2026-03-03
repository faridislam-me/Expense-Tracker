import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference _expensesRef(String accountId) => _firestore
      .collection(FirestorePaths.accounts)
      .doc(accountId)
      .collection(FirestorePaths.expenses);

  Future<ExpenseModel> addExpense(
      String accountId, ExpenseModel expense) async {
    final doc = await _expensesRef(accountId).add(expense.toMap());
    return ExpenseModel(
      id: doc.id,
      amount: expense.amount,
      category: expense.category,
      description: expense.description,
      date: expense.date,
      addedBy: expense.addedBy,
      monthKey: expense.monthKey,
      receiptUrl: expense.receiptUrl,
      createdAt: expense.createdAt,
    );
  }

  Future<List<ExpenseModel>> getExpenses(String accountId) async {
    final snapshot = await _expensesRef(accountId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) =>
            ExpenseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<ExpenseModel>> getExpensesByMonth(
      String accountId, String monthKey) async {
    final snapshot = await _expensesRef(accountId)
        .where('monthKey', isEqualTo: monthKey)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) =>
            ExpenseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<ExpenseModel?> getExpense(String accountId, String expenseId) async {
    final doc = await _expensesRef(accountId).doc(expenseId).get();
    if (!doc.exists) return null;
    return ExpenseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> updateExpense(
      String accountId, String expenseId, Map<String, dynamic> data) async {
    await _expensesRef(accountId).doc(expenseId).update(data);
  }

  Future<void> deleteExpense(String accountId, String expenseId) async {
    await _expensesRef(accountId).doc(expenseId).delete();
  }
}
