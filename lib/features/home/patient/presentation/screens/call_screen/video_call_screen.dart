// import 'package:flutter/material.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:medisafe/config/agora_config.dart';
// import 'package:agora_rtc_engine/rtc_remote_view.dart';

// class VideoCallScreen extends StatefulWidget {
//   final String channelName;

//   const VideoCallScreen({Key? key, required this.channelName}) : super(key: key);

//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   late final RtcEngine _engine;
//   int? _remoteUid;
//   bool _isJoined = false;

//   @override
//   void initState() {
//     super.initState();
//     initializeAgora();
//   }

//   Future<void> initializeAgora() async {
//     try {
//       var status = await [Permission.camera, Permission.microphone].request();

//       if (status[Permission.camera]!.isDenied ||
//           status[Permission.microphone]!.isDenied) {
//         throw Exception('Camera and Microphone permissions are required.');
//       }

//       _engine = createAgoraRtcEngine();
//       await _engine.initialize(
//         const RtcEngineContext(appId: agoraAppId),
//       );

//       _engine.registerEventHandler(
//         RtcEngineEventHandler(
//           onJoinChannelSuccess: (connection, elapsed) {
//             if (mounted) {
//               setState(() {
//                 _isJoined = true;
//               });
//             }
//           },
//           onUserJoined: (connection, remoteUid, elapsed) {
//             if (mounted) {
//               setState(() {
//                 _remoteUid = remoteUid;
//               });
//             }
//           },
//           onUserOffline: (connection, remoteUid, reason) {
//             if (mounted) {
//               setState(() {
//                 _remoteUid = null;
//               });
//             }
//           },
//         ),
//       );

//       await _engine.enableVideo();
//       await _engine.joinChannel(
//         token: agoraToken,
//         channelId: widget.channelName,
//         uid: 0,
//         options: const ChannelMediaOptions(
//           channelProfile: ChannelProfileType.channelProfileCommunication,
//           clientRoleType: ClientRoleType.clientRoleBroadcaster,
//         ),
//       );
//     } catch (e) {
//       print("Error initializing Agora: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Video Call'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.call_end),
//             onPressed: _leaveChannel,
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           Center(child: _remoteVideo()),
//           Align(
//             alignment: Alignment.topLeft,
//             child: Container(
//               width: 120,
//               height: 160,
//               margin: const EdgeInsets.all(16.0),
//               child: _isJoined
//                   ? RtcLocalView.SurfaceView()
//                   : const Center(child: CircularProgressIndicator()),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return RtcRemoteView.SurfaceView(uid: _remoteUid!);
//     } else {
//       return const Text('Waiting for a remote user to join...');
//     }
//   }

//   Future<void> _leaveChannel() async {
//     await _engine.leaveChannel();
//     setState(() {
//       _isJoined = false;
//       _remoteUid = null;
//     });
//     Navigator.pop(context);
//   }

//   @override
//   void dispose() {
//     _engine.release();
//     super.dispose();
//   }
// }
