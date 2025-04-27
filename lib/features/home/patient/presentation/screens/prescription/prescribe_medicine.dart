import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';

class PrescriptionFormScreen extends StatefulWidget {
  final String patientId;
  final String appointmentId;
  final String doctorId; // <-- add doctorId for appointment update
  final String doctorName; // <-- add doctorName for notification

  const PrescriptionFormScreen({
    super.key,
    required this.patientId,
    required this.appointmentId,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<PrescriptionFormScreen> createState() => _PrescriptionFormScreenState();
}

class _PrescriptionFormScreenState extends State<PrescriptionFormScreen> {
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _adviceController = TextEditingController();

  final List<Map<String, dynamic>> _medicines = [];

  final _timeOptions = ['Morning', 'Afternoon', 'Evening'];
  final Map<String, bool> _selectedTimes = {
    'Morning': false,
    'Afternoon': false,
    'Evening': false,
  };

  Future<void> _savePrescription() async {
    if (_medicines.isEmpty) return;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('prescriptions')
          .doc();

      await docRef.set({
        'timestamp': FieldValue.serverTimestamp(),
        'medicines': _medicines,
        'doctorId': widget.doctorId, // ✅ add this line
        'doctorName': widget.doctorName, // ✅ add this line
      });

      // ✅ Mark appointment as visited
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({'status': 'Visited'});

      // ✅ Create notification with doctorId
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'visited_appointment',
        'userId': widget.patientId,
        'doctorId': widget.doctorId,
        'doctorName': widget.doctorName,
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'You have visited Dr. ${widget.doctorName}',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription saved & Visit recorded!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColor,
      appBar: AppBar(
        title: Pacifico(text: "Prescribe Medicine", size: 25.0),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              controller: _medicineController,
              labelText: 'Medicine Name',
              icon: Icons.medical_services,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _dosageController,
              labelText: 'Dosage',
              icon: Icons.local_pharmacy,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _adviceController,
              labelText: 'Advice',
              icon: Icons.note_add,
            ),
            const SizedBox(height: 20),
            _buildTimeSelection(),
            const SizedBox(height: 20),
            _buildAddMedicineButton(),
            const SizedBox(height: 20),
            _buildMedicineList(),
            const SizedBox(height: 20),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Wrap(
      spacing: 8,
      children: _timeOptions
          .map((t) => ChoiceChip(
                label: Text(t),
                selected: _selectedTimes[t]!,
                onSelected: (selected) {
                  setState(() {
                    _selectedTimes[t] = selected;
                  });
                },
                backgroundColor: Colors.grey[300],
                selectedColor: AppColors.primaryColor,
                labelStyle: TextStyle(
                    color: _selectedTimes[t]! ? Colors.white : Colors.black),
              ))
          .toList(),
    );
  }

  Widget _buildAddMedicineButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          backgroundColor: AppColors.buttonColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          List<String> times = _selectedTimes.entries
              .where((e) => e.value)
              .map((e) => e.key)
              .toList();
          if (_medicineController.text.isNotEmpty && times.isNotEmpty) {
            setState(() {
              _medicines.add({
                'medicine': _medicineController.text,
                'dosage': _dosageController.text,
                'advice': _adviceController.text,
                'times': times,
              });
              _medicineController.clear();
              _dosageController.clear();
              _adviceController.clear();
              _selectedTimes.updateAll((key, value) => false);
            });
          }
        },
        child: Pacifico(
          text: "Add Medicine",
          size: 20.0,
          color: AppColors.appColor,
        ),
      ),
    );
  }

  Widget _buildMedicineList() {
    return Column(
      children: _medicines
          .map((m) => Card(
                color: Colors.white,
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(m['medicine']),
                  subtitle: Text(
                      'Dosage: ${m['dosage']}\nTimes: ${(m['times'] as List).join(', ')}\nAdvice: ${m['advice']}'),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _savePrescription,
        child: Pacifico(
          text: "Save Prescription",
          size: 20.0,
          color: AppColors.appColor,
        ),
      ),
    );
  }
}
