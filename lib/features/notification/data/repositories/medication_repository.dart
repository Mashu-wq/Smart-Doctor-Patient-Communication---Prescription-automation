import 'package:medisafe/models/medicine_reminder.dart';

abstract class MedicationRepository {
  Future<List<MedicationReminder>> fetchMedicationReminders(String patientId);
}
