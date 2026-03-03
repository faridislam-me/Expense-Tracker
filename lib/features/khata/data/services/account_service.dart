import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/account_model.dart';

class AccountService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference get _accountsRef =>
      _firestore.collection(FirestorePaths.accounts);

  Future<AccountModel> createAccount(AccountModel account) async {
    final doc = await _accountsRef.add(account.toMap());
    return AccountModel(
      id: doc.id,
      name: account.name,
      trackingType: account.trackingType,
      totalBudget: account.totalBudget,
      createdBy: account.createdBy,
      createdAt: account.createdAt,
    );
  }

  Future<AccountModel?> getAccount(String accountId) async {
    final doc = await _accountsRef.doc(accountId).get();
    if (!doc.exists) return null;
    return AccountModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> updateAccount(
      String accountId, Map<String, dynamic> data) async {
    await _accountsRef.doc(accountId).update(data);
  }

  Future<void> deleteAccount(String accountId) async {
    await _accountsRef.doc(accountId).delete();
  }
}
