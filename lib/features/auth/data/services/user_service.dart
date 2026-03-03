import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/user_model.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersRef =>
      _firestore.collection(FirestorePaths.users);

  Future<UserModel?> getUser(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> createUser(UserModel user) async {
    await _usersRef.doc(user.id).set(user.toMap());
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _usersRef.doc(userId).update(data);
  }

  Future<void> addAccountToUser(String userId, String accountId) async {
    await _usersRef.doc(userId).update({
      'accountIds': FieldValue.arrayUnion([accountId]),
    });
  }

  Future<void> removeAccountFromUser(String userId, String accountId) async {
    await _usersRef.doc(userId).update({
      'accountIds': FieldValue.arrayRemove([accountId]),
    });
  }

  Future<void> updateFcmToken(String userId, String token) async {
    await _usersRef.doc(userId).update({'fcmToken': token});
  }
}
