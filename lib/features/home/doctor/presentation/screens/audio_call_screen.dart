import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key});

  @override
  _AudioCallScreenState createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    _initializeAudioCall();
  }

  Future<void> _initializeAudioCall() async {
    MediaStream stream = await navigator.mediaDevices.getUserMedia({
      "audio": true,
      "video": false, // Disable video for audio calls
    });

    setState(() {
      _localStream = stream;
    });

    // TODO: Implement signaling (Firebase, WebSocket, or any signaling server)
  }

  @override
  void dispose() {
    _localStream?.getTracks().forEach((track) => track.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Call")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // TODO: Implement Call End Logic
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("End Call"),
        ),
      ),
    );
  }
}
