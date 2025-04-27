import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:medisafe/features/notification/data/repositories/notification_repository.dart';
import 'package:medisafe/features/notification/domain/entity/notification_entity.dart';

class FirebaseNotificationDataSource implements NotificationRepository {
  final FirebaseMessaging _firebaseMessaging;

  FirebaseNotificationDataSource(this._firebaseMessaging);

  @override
  Future<void> sendNotification(NotificationEntity notification) async {
    try {
      // Send push notification using FCM (subscribe to topic)
      await _firebaseMessaging.subscribeToTopic(notification.title);
      // Logic to send message, e.g., you can send the notification details to Firebase
      // Send message using FCM here
    } catch (e) {
      throw Exception("Error sending notification: $e");
    }
  }
}
