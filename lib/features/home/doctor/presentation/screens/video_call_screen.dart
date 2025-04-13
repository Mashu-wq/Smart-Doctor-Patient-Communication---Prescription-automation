import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisafe/models/doctor_model.dart';

class VideoCallScreen extends StatefulWidget {
  final Doctor doctor;
  final String patientId; // The ID of the patient (James)

  const VideoCallScreen({
    super.key,
    required this.doctor,
    required this.patientId,
  });

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  bool isMuted = false;
  bool isSpeakerOn = false;

  Timer? callTimer;
  Duration callDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeCall();
    _startCallTimer();
  }

  Future<void> _initializeCall() async {
    // 1. Initialize Renderers
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // 2. Get Local Media (Audio + Video)
    _localStream = await navigator.mediaDevices.getUserMedia({
      "audio": true,
      "video": true,
    });
    _localRenderer.srcObject = _localStream;

    // 3. Create Peer Connection
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    });

    // 4. Add Local Stream
    _peerConnection?.addStream(_localStream!);

    // 5. Listen for Remote Stream
    _peerConnection?.onAddStream = (stream) {
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    };

    // 6. Create Offer & Set Local Description
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    // 7. Save Offer in Firestore (calls/{patientId})
    await FirebaseFirestore.instance.collection('calls').doc(widget.patientId).set({
      'doctorName': widget.doctor.name,
      'doctorImage': widget.doctor.profileImageUrl,
      'patientId': widget.patientId,
      'offer': offer.toMap(),
    });

    // 8. Listen for Answer from Patient
    FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.patientId)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists && snapshot.data()?['answer'] != null) {
        final answerData = snapshot.data()?['answer'];
        RTCSessionDescription answer = RTCSessionDescription(
          answerData['sdp'],
          answerData['type'],
        );
        await _peerConnection!.setRemoteDescription(answer);
      }
    });

    // 9. Send ICE Candidates
    _peerConnection?.onIceCandidate = (candidate) {
      FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.patientId)
          .update({'candidate': candidate.toMap()});
        };

    // 10. Listen for Remote ICE Candidates
    FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.patientId)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists && snapshot.data()?['candidate'] != null) {
        final candData = snapshot.data()?['candidate'];
        RTCIceCandidate candidate = RTCIceCandidate(
          candData['candidate'],
          candData['sdpMid'],
          candData['sdpMLineIndex'],
        );
        await _peerConnection!.addCandidate(candidate);
      }
    });
  }

  void _startCallTimer() {
    callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        callDuration += const Duration(seconds: 1);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? "$minutes:$seconds" : "$hours:$minutes:$seconds";
  }

  void _endCall() {
    // 1. Delete the doc from Firestore (calls/{patientId})
    FirebaseFirestore.instance.collection('calls').doc(widget.patientId).delete();

    // 2. Close Peer Connection & Streams
    _peerConnection?.close();
    _localStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();

    // 3. Cancel Timer & Pop
    callTimer?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _endCall(); // End call if user closes screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent,
        title: const Text("Video Call"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _endCall,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Doctor's Profile Picture
          CircleAvatar(
            backgroundImage: NetworkImage(widget.doctor.profileImageUrl),
            radius: 50,
          ),
          const SizedBox(height: 10),

          // Doctor's Name
          Text(
            "Dr. ${widget.doctor.name}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),

          // Call Duration
          Text(
            _formatDuration(callDuration),
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),

          // Remote Video
          Expanded(
            child: Stack(
              children: [
                RTCVideoView(
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: SizedBox(
                    width: 100,
                    height: 150,
                    child: RTCVideoView(_localRenderer, mirror: true),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Call Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  isMuted ? Icons.mic_off : Icons.mic,
                  color: isMuted ? Colors.red : Colors.white,
                ),
                iconSize: 40,
                onPressed: () {
                  setState(() {
                    isMuted = !isMuted;
                    // TODO: Mute logic
                  });
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: _endCall,
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              IconButton(
                icon: Icon(
                  isSpeakerOn ? Icons.volume_up : Icons.hearing,
                  color: isSpeakerOn ? Colors.blue : Colors.white,
                ),
                iconSize: 40,
                onPressed: () {
                  setState(() {
                    isSpeakerOn = !isSpeakerOn;
                    // TODO: Speaker logic
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
