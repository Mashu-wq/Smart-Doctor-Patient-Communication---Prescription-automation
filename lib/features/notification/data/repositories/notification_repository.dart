import 'package:medisafe/features/notification/domain/entity/notification_entity.dart';

abstract class NotificationRepository {
  Future<void> sendNotification(NotificationEntity notification);
}
