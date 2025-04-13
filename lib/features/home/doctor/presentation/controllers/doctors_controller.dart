import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/home/doctor/domain/usecases/fetch_doctor_usecases.dart';

import 'package:medisafe/providers.dart';
import 'package:medisafe/models/doctor_model.dart';

final doctorsControllerProvider = StreamProvider<List<Doctor>>((ref) {
  final fetchDoctorsUseCase = ref.read(fetchDoctorsUseCaseProvider);
  return fetchDoctorsUseCase.execute();
});

class DoctorsController extends StateNotifier<AsyncValue<List<Doctor>>> {
  final FetchDoctorsUseCase fetchDoctorsUseCase;

  DoctorsController(this.fetchDoctorsUseCase)
      : super(const AsyncValue.loading()) {
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    state = const AsyncValue.loading();
    try {
      final doctors = fetchDoctorsUseCase.execute();
      state = AsyncValue.data(doctors as List<Doctor>);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
