import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisafe/features/notification/data/repositories/notification_repository.dart';
import 'package:medisafe/features/notification/domain/entity/notification_entity.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  final FirebaseFirestore _firestore;

  FirebaseNotificationRepository(this._firestore);

  @override
  Future<void> sendNotification(NotificationEntity notification) async {
    try {
      // Save notification to Firestore
      await _firestore.collection('notifications').add(notification.toMap());
    } catch (e) {
      throw Exception("Error sending notification: $e");
    }
  }

  @override
  Future<List<NotificationEntity>> fetchNotifications(String patientId) async {
    try {
      final querySnapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationEntity.fromMap(
              doc.data())) // using NotificationEntity
          .toList();
    } catch (e) {
      throw Exception("Error fetching notifications: $e");
    }
  }
}
