import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisafe/models/prescription_model.dart';

class AddPrescriptionForm extends StatefulWidget {
  final String patientId;
  final String patientName;
  final int patientAge;

  const AddPrescriptionForm({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
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

    await FirebaseFirestore.instance
        .collection('prescriptions')
        .doc(prescription.id)
        .set(prescription.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Prescription saved successfully!")),
    );
  }

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
