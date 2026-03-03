import 'package:flutter/material.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  Stream<List<ChatMessageModel>> getMessagesStream(String accountId) {
    return _chatService.getMessagesStream(accountId);
  }

  Future<void> sendMessage({
    required String accountId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    try {
      final chatMessage = ChatMessageModel(
        id: '',
        senderId: senderId,
        senderName: senderName,
        message: message,
        createdAt: DateTime.now(),
      );
      await _chatService.sendMessage(accountId, chatMessage);
    } catch (e) {
      debugPrint('[CHAT] sendMessage error: $e');
    }
  }
}
