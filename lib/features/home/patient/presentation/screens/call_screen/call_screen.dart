import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:permission_handler/permission_handler.dart';

class CallScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String callId;
  final bool isVideoCall;

  static const int appID = 1203045682;
  static const String appSign =
      "e139fcd21655478e0f2ffd91fe8452bdcf1ecaf60e5e68bfed21b325892bbab5";

  const CallScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.callId,
    required this.isVideoCall,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  void dispose() {
    // Clean Firestore signaling if needed
    FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.userId) // or patientId
        .update({'incoming_call': FieldValue.delete()});
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    // Request microphone and camera permissions if needed
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      if (widget.isVideoCall) Permission.camera,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      // Show dialog if permissions are denied
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
              'Camera and microphone permissions are required to make a video call. Please enable them in system settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      Navigator.pop(context);
      return;
    }

    setState(() {
      _permissionsGranted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    late final ZegoUIKitPrebuiltCallConfig config;

    if (widget.isVideoCall) {
      config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        ..turnOnCameraWhenJoining = true
        ..turnOnMicrophoneWhenJoining = true;
    } else {
      config = ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
        ..turnOnMicrophoneWhenJoining = true;
    }

    return Scaffold(
      body: ZegoUIKitPrebuiltCall(
        appID: CallScreen.appID,
        appSign: CallScreen.appSign,
        userID: widget.userId,
        userName: widget.userName,
        callID: widget.callId,
        config: config,
      ),
    );
  }
}
