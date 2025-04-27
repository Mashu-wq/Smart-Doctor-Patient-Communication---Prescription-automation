import 'package:medisafe/features/notification/domain/entity/notification_entity.dart';
import 'package:medisafe/features/notification/data/repositories/notification_repository.dart';

class SendNotificationUseCase {
  final NotificationRepository repository;

  // Initialize the repository via the constructor
  SendNotificationUseCase(this.repository);

  Future<void> execute(NotificationEntity notification) {
    return repository.sendNotification(notification);
  }
}
