import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PrescriptionFormScreen extends StatefulWidget {
  final String patientId;

  const PrescriptionFormScreen({
    super.key,
    required this.patientId,
  });

  @override
  _PrescriptionFormScreenState createState() => _PrescriptionFormScreenState();
}

class _PrescriptionFormScreenState extends State<PrescriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the "current" medicine entry.
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _adviceController = TextEditingController();

  // List to store added medicine entries.
  final List<Map<String, dynamic>> _medicines = [];

  // Available time options.
  final List<String> _timeOptions = ['Morning', 'Afternoon', 'Evening'];

  // Map to track which times are selected for the current entry.
  Map<String, bool> _selectedTimes = {
    'Morning': false,
    'Afternoon': false,
    'Evening': false,
  };

  @override
  void dispose() {
    _medicineController.dispose();
    _dosageController.dispose();
    _adviceController.dispose();
    super.dispose();
  }

  // Add a medicine entry to the list.
  void _addMedicine() {
    if (_formKey.currentState!.validate()) {
      // Get selected times as a list.
      List<String> selectedTimeList = _selectedTimes.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (selectedTimeList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one time')),
        );
        return;
      }

      setState(() {
        _medicines.add({
          'medicine': _medicineController.text.trim(),
          'dosage': _dosageController.text.trim(),
          'times': selectedTimeList,
          'advice': _adviceController.text.trim(),
        });
      });

      // Clear the input fields and reset time selections.
      _medicineController.clear();
      _dosageController.clear();
      _adviceController.clear();
      _selectedTimes = {
        for (var time in _timeOptions) time: false,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine added!')),
      );
    }
  }

  // Save the prescription to Firestore.
  Future<void> _savePrescription() async {
    if (_medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medicine')),
      );
      return;
    }

    try {
      // Create a new document in the patient's "prescriptions" subcollection.
      final docRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('prescriptions')
          .doc();

      await docRef.set({
        'timestamp': FieldValue.serverTimestamp(),
        'medicines': _medicines,
      });

      // Clear the local medicine list after saving.
      setState(() {
        _medicines.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving prescription: $e')),
      );
    }
  }

  // Build the multi-select time selection using FilterChips.
  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Medicine Times:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 10,
          children: _timeOptions.map((time) {
            return FilterChip(
              label: Text(time),
              selected: _selectedTimes[time]!,
              onSelected: (selected) {
                setState(() {
                  _selectedTimes[time] = selected;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Build the list of added medicine entries.
  Widget _buildMedicineList() {
    if (_medicines.isEmpty) {
      return const Text('No medicines added yet.');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _medicines.length,
      itemBuilder: (context, index) {
        final medicine = _medicines[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(medicine['medicine'] ?? ''),
            subtitle: Text(
              'Dosage: ${medicine['dosage']}\n'
              'Times: ${(medicine['times'] as List).join(', ')}\n'
              'Advice: ${medicine['advice']}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _medicines.removeAt(index);
                });
              },
            ),
          ),
        );
      },
    );
  }

  // Build the main UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescribe Medicine'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Medicine Name
              TextFormField(
                controller: _medicineController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  prefixIcon: Icon(Icons.medical_services),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the medicine name' : null,
              ),
              const SizedBox(height: 16),

              // Dosage
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  prefixIcon: Icon(Icons.local_pharmacy),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the dosage' : null,
              ),
              const SizedBox(height: 16),

              // Multi-select Time using FilterChips
              _buildTimeSelection(),
              const SizedBox(height: 16),

              // Advice (Optional)
              TextFormField(
                controller: _adviceController,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Add Medicine Button
              ElevatedButton(
                onPressed: _addMedicine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text('Add Medicine'),
              ),
              const SizedBox(height: 20),

              // Display the list of added medicines.
              _buildMedicineList(),
              const SizedBox(height: 20),

              // Save Prescription Button
              ElevatedButton(
                onPressed: _savePrescription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text('Save Prescription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
