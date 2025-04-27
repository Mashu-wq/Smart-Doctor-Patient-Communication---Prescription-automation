import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/notification/domain/entity/notification_entity.dart';
import 'package:medisafe/features/notification/domain/usecases/send_notification_use_case.dart';

class NotificationsController extends StateNotifier<List<NotificationEntity>> {
  final SendNotificationUseCase _sendNotificationUseCase;

  NotificationsController(this._sendNotificationUseCase) : super([]);

  Future<void> sendNotification(NotificationEntity notification) async {
    await _sendNotificationUseCase.execute(notification);
    state = [...state, notification]; // Add notification to state
  }
}
