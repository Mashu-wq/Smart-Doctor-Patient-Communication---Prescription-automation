import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationEntity {
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationEntity({
    required this.title,
    required this.body,
    required this.timestamp,
  });

  // Method to convert NotificationEntity to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp,
    };
  }

  // Method to create a NotificationEntity from a Map (for Firestore)
  static NotificationEntity fromMap(Map<String, dynamic> map) {
    return NotificationEntity(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
