import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:medisafe/features/notification/domain/entity/notification_entity.dart';
import 'package:medisafe/features/notification/data/repositories/notification_repository.dart';

class FirebaseNotificationDataSource implements NotificationRepository {
  final FirebaseMessaging _firebaseMessaging;

  FirebaseNotificationDataSource(this._firebaseMessaging);

  @override
  Future<void> sendNotification(NotificationEntity notification) async {
    // Send push notification using FCM
    await _firebaseMessaging.subscribeToTopic(notification.title);

    // Send message with notification (you can customize this part)
    await _firebaseMessaging.sendMessage(
      to: notification.title,
      messageId: notification.body,
    );
  }
}
