import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medisafe/features/home/patient/presentation/screens/call_screen/call_screen.dart';

class IncomingCallListener extends StatefulWidget {
  final Widget child;
  final String patientId;
  final String patientName;
  const IncomingCallListener({
    super.key,
    required this.child,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<IncomingCallListener> createState() => _IncomingCallListenerState();
}

class _IncomingCallListenerState extends State<IncomingCallListener> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final call = data['incoming_call'] as Map<String, dynamic>?;

        // Show call prompt if there's an incoming call and a dialog isn't already shown
        if (call != null && !_dialogShown) {
          _dialogShown = true;
          final callId = call['call_id'] as String? ?? '';
          final doctorName = call['from_doctor_name'] as String? ?? 'Doctor';
          final type = (call['call_type'] as String? ?? 'video').toLowerCase();
          final isVideo = type == 'video';

          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: Text("$doctorName is calling you"),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      _dialogShown = false;
                      // Clean up signaling (decline)
                      await FirebaseFirestore.instance
                          .collection('patients')
                          .doc(widget.patientId)
                          .update({'incoming_call': FieldValue.delete()});
                    },
                    child: const Text("Decline"),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      _dialogShown = false;
                      // Remove signaling and launch call screen
                      await FirebaseFirestore.instance
                          .collection('patients')
                          .doc(widget.patientId)
                          .update({'incoming_call': FieldValue.delete()});

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CallScreen(
                            userId: widget.patientId,
                            userName: widget.patientName,
                            callId: callId,
                            isVideoCall: isVideo,
                          ),
                        ),
                      );
                    },
                    child: const Text("Accept"),
                  ),
                ],
              ),
            );
          });
        } else if (call == null) {
          // Ready to show new dialog when a new call comes in
          _dialogShown = false;
        }
        return widget.child;
      },
    );
  }
}
