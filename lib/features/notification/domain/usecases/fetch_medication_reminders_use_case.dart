import 'package:medisafe/features/notification/data/repositories/medication_repository.dart';
import 'package:medisafe/models/medicine_reminder.dart';

class FetchMedicationRemindersUseCase {
  final MedicationRepository repository;

  FetchMedicationRemindersUseCase(this.repository);

  Future<List<MedicationReminder>> execute(String patientId) {
    return repository.fetchMedicationReminders(patientId);
  }
}
