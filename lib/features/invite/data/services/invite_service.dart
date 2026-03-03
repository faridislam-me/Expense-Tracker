import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/invite_model.dart';

class InviteService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference _invitesRef(String accountId) => _firestore
      .collection(FirestorePaths.accounts)
      .doc(accountId)
      .collection(FirestorePaths.invites);

  Future<void> sendInvite(String accountId, InviteModel invite) async {
    await _invitesRef(accountId).add(invite.toMap());
  }

  Future<List<InviteModel>> getInvitesForAccount(String accountId) async {
    final snapshot = await _invitesRef(accountId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) =>
            InviteModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<InviteModel>> getPendingInvitesForEmail(String email) async {
    // Query across all accounts for pending invites for this email
    final snapshot = await _firestore
        .collectionGroup(FirestorePaths.invites)
        .where('email', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs
        .map((doc) =>
            InviteModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateInviteStatus(
      String accountId, String inviteId, String status) async {
    await _invitesRef(accountId).doc(inviteId).update({'status': status});
  }
}
