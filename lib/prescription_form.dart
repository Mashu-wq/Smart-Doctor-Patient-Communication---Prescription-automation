import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisafe/models/prescription_model.dart';

class AddPrescriptionForm extends StatefulWidget {
  final String patientId;
  final String patientName;
  final int patientAge;
  final String appointmentId; // <-- passed from visit

  const AddPrescriptionForm({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.appointmentId,
  });

  @override
  State<AddPrescriptionForm> createState() => _AddPrescriptionFormState();
}

class _AddPrescriptionFormState extends State<AddPrescriptionForm> {
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _medicineTimeController = TextEditingController();
  final TextEditingController _medicineDoseController = TextEditingController();
  final TextEditingController _nextConsultancyDateController =
      TextEditingController();

  List<Medicine> medicines = [];

  void _addMedicine() {
    final medicine = Medicine(
      name: _medicineNameController.text,
      time: _medicineTimeController.text,
      dose: _medicineDoseController.text,
    );
    setState(() {
      medicines.add(medicine);
    });
    _medicineNameController.clear();
    _medicineTimeController.clear();
    _medicineDoseController.clear();
  }

  Future<void> _savePrescription() async {
    final prescription = Prescription(
      id: FirebaseFirestore.instance.collection('prescriptions').doc().id,
      patientId: widget.patientId,
      patientName: widget.patientName,
      patientAge: widget.patientAge,
      medicines: medicines,
      nextConsultancyDate: DateTime.parse(_nextConsultancyDateController.text),
    );

    try {
      // Save prescription to Firestore
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('prescriptions')
          .doc(prescription.id)
          .set(prescription.toMap());

      // Mark appointment as visited
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({'status': 'Visited'});

      // Create notification for the patient
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'visited_appointment',
        'userId': widget.patientId,
        'doctorName': prescription.patientName,
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'You have visited by Dr. ${prescription.patientName}',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Prescription saved and visit completed!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  //   await FirebaseFirestore.instance
  //       .collection('prescriptions')
  //       .doc(prescription.id)
  //       .set(prescription.toMap());

  //   // ✅ Mark appointment as visited
  //   await FirebaseFirestore.instance
  //       .collection('appointments')
  //       .doc(widget.appointmentId)
  //       .update({'status': 'Visited'});

  //   // ✅ Create notification
  //   await FirebaseFirestore.instance.collection('notifications').add({
  //     'type': 'visited_appointment',
  //     'userId': widget.patientId,
  //     'doctorName':
  //         prescription.patientName, // or use your actual doctor name source
  //     'timestamp': FieldValue.serverTimestamp(),
  //     'message': 'You have visited Dr. ${prescription.patientName}',
  //   });

  //   // ✅ Confirm and go back
  //   if (context.mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //           content: Text("Prescription saved and visit completed!")),
  //     );
  //     Navigator.pop(context);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add Medicine"),
          TextField(
            controller: _medicineNameController,
            decoration: const InputDecoration(labelText: "Medicine Name"),
          ),
          TextField(
            controller: _medicineTimeController,
            decoration: const InputDecoration(labelText: "Medicine Time"),
          ),
          TextField(
            controller: _medicineDoseController,
            decoration: const InputDecoration(labelText: "Dose"),
          ),
          ElevatedButton(
            onPressed: _addMedicine,
            child: const Text("Add Medicine"),
          ),
          const SizedBox(height: 20),
          const Text("Next Consultancy Date"),
          TextField(
            controller: _nextConsultancyDateController,
            decoration: const InputDecoration(labelText: "YYYY-MM-DD"),
          ),
          ElevatedButton(
            onPressed: _savePrescription,
            child: const Text("Save Prescription"),
          ),
          const SizedBox(height: 20),
          const Text("Medicines"),
          ...medicines.map((medicine) {
            return ListTile(
              title: Text(medicine.name),
              subtitle: Text("${medicine.dose}, ${medicine.time}"),
            );
          }),
        ],
      ),
    );
  }
}
