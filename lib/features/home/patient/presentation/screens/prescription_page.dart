// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class PrescriptionPage extends StatefulWidget {
//   final String patientId;
//   final Function(String) onPrescriptionSaved;

//   const PrescriptionPage({
//     super.key,
//     required this.patientId,
//     required this.onPrescriptionSaved,
//   });

//   @override
//   _PrescriptionPageState createState() => _PrescriptionPageState();
// }

// class _PrescriptionPageState extends State<PrescriptionPage> {
//   final TextEditingController _prescriptionController = TextEditingController();
//   final TextRecognizer _textRecognizer = TextRecognizer();
//   File? _selectedImage;
//   final List<MedicineSchedule> _schedules = [];
//   final _formKey = GlobalKey<FormState>();

//   Future<void> _processOCR() async {
//     if (_selectedImage == null) return;

//     final inputImage = InputImage.fromFile(_selectedImage!);
//     final recognizedText = await _textRecognizer.processImage(inputImage);
    
//     setState(() {
//       _prescriptionController.text = recognizedText.text;
//       _parsePrescriptionText(recognizedText.text);
//     });
//   }

//   void _parsePrescriptionText(String text) {
//     // Implement your custom parsing logic here
//     final regex = RegExp(r'(\w+)\s+(\d+mg?)\s+(\d+)\s+times\s+(\w+)\s+for\s+(\d+)\s+days', caseSensitive: false);
//     final matches = regex.allMatches(text);

//     _schedules.clear();
//     for (final match in matches) {
//       _schedules.add(MedicineSchedule(
//         name: match.group(1)!,
//         dosage: match.group(2)!,
//         timesPerDay: int.parse(match.group(3)!),
//         duration: int.parse(match.group(5)!),
//       ));
//     }
//   }

//   Future<void> _savePrescription() async {
//     if (_formKey.currentState!.validate()) {
//       await widget.onPrescriptionSaved(_prescriptionController.text);
//       Navigator.pop(context);
//     }
//   }

//   Future<void> _pickImage() async {
//     final image = await ImagePicker().pickImage(source: ImageSource.camera);
//     if (image != null) {
//       setState(() => _selectedImage = File(image.path));
//       await _processOCR();
//     }
//   }

//   @override
//   void dispose() {
//     _textRecognizer.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Write Prescription')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 ElevatedButton(
//                   onPressed: _pickImage,
//                   child: const Text('Scan Handwritten Prescription'),
//                 ),
//                 if (_selectedImage != null)
//                   Image.file(_selectedImage!, height: 200),
//                 TextFormField(
//                   controller: _prescriptionController,
//                   maxLines: 10,
//                   decoration: const InputDecoration(
//                     labelText: 'Prescription Text',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value?.isEmpty ?? true) return 'Please enter prescription';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('Medicine Schedule', style: TextStyle(fontSize: 18)),
//                 ..._schedules.map((schedule) => ListTile(
//                   title: Text('${schedule.name} - ${schedule.dosage}'),
//                   subtitle: Text('${schedule.timesPerDay} times/day for ${schedule.duration} days'),
//                 )),
//                 ElevatedButton(
//                   onPressed: _savePrescription,
//                   child: const Text('Save Prescription'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MedicineSchedule {
//   final String name;
//   final String dosage;
//   final int timesPerDay;
//   final int duration;

//   MedicineSchedule({
//     required this.name,
//     required this.dosage,
//     required this.timesPerDay,
//     required this.duration,
//   });
// }