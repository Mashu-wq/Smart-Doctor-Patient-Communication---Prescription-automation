// Provide the MedicationRepository implementation
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/notification/data/data_source/medication_data_source.dart';
import 'package:medisafe/features/notification/data/repositories/medication_repository.dart';
import 'package:medisafe/features/notification/domain/usecases/fetch_medication_reminders_use_case.dart';

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return FirebaseMedicationDataSource(FirebaseFirestore.instance);
});

// Provide the FetchMedicationRemindersUseCase use case
final fetchMedicationRemindersProvider =
    Provider<FetchMedicationRemindersUseCase>((ref) {
  return FetchMedicationRemindersUseCase(
      ref.read(medicationRepositoryProvider));
});
