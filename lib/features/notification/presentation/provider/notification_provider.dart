import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/notification/data/repositories/firebase_notification_repository.dart';
import 'package:medisafe/features/notification/data/repositories/notification_repository.dart';
import 'package:medisafe/features/notification/domain/entity/notification_entity.dart';

import 'package:medisafe/features/notification/domain/usecases/send_notification_use_case.dart';
import 'package:medisafe/features/notification/presentation/controller/notifications_controller.dart';

// Provide the repository implementation
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return FirebaseNotificationRepository(FirebaseFirestore.instance);
});

// Provide the SendNotificationUseCase use case
final sendNotificationProvider = Provider<SendNotificationUseCase>((ref) {
  return SendNotificationUseCase(ref.read(notificationRepositoryProvider));
});

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, List<NotificationEntity>>(
        (ref) {
  return NotificationsController(ref.read(sendNotificationProvider));
});
