import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';
import 'package:medisafe/features/home/patient/presentation/screens/doctor_profile_history_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'visited_appointment':
        return Icons.health_and_safety; // 🩺 More medical feel
      case 'new_message':
        return Icons.chat_bubble_outline; // ✉️ Looks like a real chat
      case 'reminder':
        return Icons.schedule; // ⏰ Reminder clock
      default:
        return Icons
            .notifications_active_outlined; // 🔔 Better notification icon
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'visited_appointment':
        return Colors.green;
      case 'new_message':
        return Colors.blueAccent;
      case 'reminder':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Pacifico(text: "Notifications", size: 28.0),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final message = data['message'] ?? '';
              final type = data['type'] ?? '';
              final doctorId = data['doctorId'];
              final patientId = data['userId'];
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

              return GestureDetector(
                onTap: () {
                  if (doctorId != null && patientId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorProfileWithHistoryScreen(
                          doctorId: doctorId,
                          patientId: patientId,
                        ),
                      ),
                    );
                  } else {
                    debugPrint(
                        "⚠️ doctorId or patientId missing in notification.");
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 5,
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: _getIconColor(type).withOpacity(0.1),
                      child: Icon(
                        _getNotificationIcon(type),
                        color: _getIconColor(type),
                        size: 30,
                      ),
                    ),
                    title: Text(
                      message,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: timestamp != null
                        ? Text(
                            DateFormat('EEE, MMM d • hh:mm a')
                                .format(timestamp),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          )
                        : null,
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 18, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
