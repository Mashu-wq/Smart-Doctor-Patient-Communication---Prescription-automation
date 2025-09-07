import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'call_screen.dart';

class DoctorCallWaitScreen extends StatelessWidget {
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String callId;
  final bool isVideoCall;

  const DoctorCallWaitScreen({
    super.key,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.callId,
    required this.isVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final call = data?['incoming_call'] as Map<String, dynamic>?;

        if (call == null) {
          // Call ended or declined
          Future.microtask(() {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Call ended or declined.')),
            );
          });
          return const SizedBox.shrink();
        }

        final callStatus = call['call_status'] ?? 'ringing';

        if (callStatus == 'accepted') {
          Future.microtask(() {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => CallScreen(
                  userId: doctorId,
                  userName: doctorName,
                  callId: callId,
                  isVideoCall: isVideoCall,
                ),
              ),
            );
          });
        }

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(callStatus == 'ringing'
                    ? 'Waiting for patient to accept...'
                    : 'Connecting...'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // End call if doctor gives up waiting
                    await FirebaseFirestore.instance
                        .collection('patients')
                        .doc(patientId)
                        .update({'incoming_call': FieldValue.delete()});
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
