import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisafe/models/patient_model.dart';

class PatientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Patient> fetchPatientProfile(String patientId) async {
    try {
      final doc = await _firestore.collection('patients').doc(patientId).get();

      if (!doc.exists) {
        throw Exception("Patient not found");
      }

      return Patient.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception("Failed to fetch patient profile: $e");
    }
  }
}
