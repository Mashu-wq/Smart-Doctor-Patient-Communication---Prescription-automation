import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreen extends StatefulWidget {
  final bool isVideoCall;
  final String callerName;
  final String callerImageUrl;

  const CallScreen({
    super.key,
    required this.isVideoCall,
    required this.callerName,
    required this.callerImageUrl,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  int _callDuration = 0; // Call Duration
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _initializeCall();
    _startCallTimer();
  }

  Future<void> _initializeCall() async {
    await _localRenderer.initialize();
    MediaStream stream = await navigator.mediaDevices.getUserMedia({
      "audio": true,
      "video": widget.isVideoCall,
    });

    setState(() {
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
    });

    // TODO: Implement WebRTC Signaling
  }

  void _startCallTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration++;
      });
    });
  }

  @override
  void dispose() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _localRenderer.dispose();
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage(widget.callerImageUrl),
            backgroundColor: Colors.grey[800],
          ),
          const SizedBox(height: 20),
          Text(
            widget.callerName,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _formatDuration(_callDuration),
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 50),
          widget.isVideoCall
              ? Expanded(child: RTCVideoView(_localRenderer, mirror: true))
              : const SizedBox(), // Only show video if it's a video call
          const SizedBox(height: 50),
          _buildEndCallButton(),
        ],
      ),
    );
  }

  Widget _buildEndCallButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
        ),
        child: const Icon(Icons.call_end, size: 30, color: Colors.white),
      ),
    );
  }
}
