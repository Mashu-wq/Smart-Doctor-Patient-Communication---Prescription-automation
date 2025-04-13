import 'package:flutter/material.dart';

class WritePrescriptionScreen extends StatelessWidget {
  final String patientId;
  final String patientName;
  final String doctorId;

  const WritePrescriptionScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription for $patientName'),
      ),
      body: const Center(
        child: Text('Prescription writing interface will go here'),
      ),
    );
  }
}
