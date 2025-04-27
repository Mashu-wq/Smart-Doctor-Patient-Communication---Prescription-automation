import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisafe/features/notification/data/repositories/medication_repository.dart';
import 'package:medisafe/models/medicine_reminder.dart';

class FirebaseMedicationDataSource implements MedicationRepository {
  final FirebaseFirestore _firestore;

  FirebaseMedicationDataSource(this._firestore);

  @override
  Future<List<MedicationReminder>> fetchMedicationReminders(
      String patientId) async {
    final querySnapshot = await _firestore
        .collection('patients')
        .doc(patientId)
        .collection('medications')
        .get();

    return querySnapshot.docs
        .map((doc) => MedicationReminder.fromMap(doc.data()))
        .toList();
  }
}
