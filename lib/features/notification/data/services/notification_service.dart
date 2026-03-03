import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference _notificationsRef(String userId) => _firestore
      .collection(FirestorePaths.notifications)
      .doc(userId)
      .collection(FirestorePaths.items);

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final snapshot = await _notificationsRef(userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => NotificationModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _notificationsRef(userId)
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notificationsRef(userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> addNotification(
      String userId, NotificationModel notification) async {
    await _notificationsRef(userId).add(notification.toMap());
  }
}
