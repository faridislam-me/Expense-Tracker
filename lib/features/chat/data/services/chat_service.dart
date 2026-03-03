import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference _chatsRef(String accountId) => _firestore
      .collection(FirestorePaths.accounts)
      .doc(accountId)
      .collection(FirestorePaths.chats);

  Stream<List<ChatMessageModel>> getMessagesStream(String accountId) {
    return _chatsRef(accountId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> sendMessage(
      String accountId, ChatMessageModel message) async {
    await _chatsRef(accountId).add(message.toMap());
  }
}
