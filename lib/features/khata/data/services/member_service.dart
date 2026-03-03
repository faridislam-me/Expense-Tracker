import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/member_model.dart';

class MemberService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference _membersRef(String accountId) => _firestore
      .collection(FirestorePaths.accounts)
      .doc(accountId)
      .collection(FirestorePaths.members);

  Future<void> addMember(String accountId, MemberModel member) async {
    await _membersRef(accountId).doc(member.userId).set(member.toMap());
  }

  Future<List<MemberModel>> getMembers(String accountId) async {
    final snapshot = await _membersRef(accountId).get();
    return snapshot.docs
        .map((doc) =>
            MemberModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<MemberModel?> getMember(String accountId, String userId) async {
    final doc = await _membersRef(accountId).doc(userId).get();
    if (!doc.exists) return null;
    return MemberModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> updateMemberRole(
      String accountId, String userId, String role) async {
    await _membersRef(accountId).doc(userId).update({'role': role});
  }

  Future<void> removeMember(String accountId, String userId) async {
    await _membersRef(accountId).doc(userId).delete();
  }
}
