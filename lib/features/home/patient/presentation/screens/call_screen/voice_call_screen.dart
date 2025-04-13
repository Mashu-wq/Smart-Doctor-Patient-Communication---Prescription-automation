import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medisafe/models/doctor_model.dart';

class VoiceCallScreen extends StatefulWidget {
  final Doctor doctor;

   // Pass the Doctor object directly

  const VoiceCallScreen({
    super.key,
    required this.doctor, required String patientId,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool isMuted = false;
  bool isSpeakerOn = false;
  Timer? callTimer;
  Duration callDuration = Duration.zero; // Tracks call duration

  @override
  void initState() {
    super.initState();
    startCallTimer();
  }

  void startCallTimer() {
    callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        callDuration += const Duration(seconds: 1);
      });
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? "$minutes:$seconds" : "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    callTimer?.cancel(); // Stop the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent,
        title: const Text("Voice Call"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Exit the call
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Doctor's Profile Picture
          CircleAvatar(
            backgroundImage: NetworkImage(widget.doctor.profileImageUrl),
            radius: 70,
          ),
          const SizedBox(height: 20),

          // Doctor's Name
          Text(
            "Dr. ${widget.doctor.name}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 10),

          // Call Duration
          Text(
            formatDuration(callDuration),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),

          const Spacer(),

          // Call Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mute Button
              IconButton(
                icon: Icon(
                  isMuted ? Icons.mic_off : Icons.mic,
                  color: isMuted ? Colors.red : Colors.black,
                ),
                iconSize: 40,
                onPressed: () {
                  setState(() {
                    isMuted = !isMuted;
                  });
                },
              ),

              // End Call Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: () {
                  Navigator.pop(context); // Exit the call
                },
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              // Speaker Button
              IconButton(
                icon: Icon(
                  isSpeakerOn ? Icons.volume_up : Icons.hearing,
                  color: isSpeakerOn ? Colors.blue : Colors.black,
                ),
                iconSize: 40,
                onPressed: () {
                  setState(() {
                    isSpeakerOn = !isSpeakerOn;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
