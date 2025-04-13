import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/home/patient/domain/usecases/search_doctors_usecase.dart';
import 'package:medisafe/models/doctor_model.dart';
import 'package:medisafe/models/search_filter_model.dart';
import 'package:medisafe/providers.dart';

final searchDoctorControllerProvider =
    StateNotifierProvider<SearchDoctorController, AsyncValue<List<Doctor>>>(
        (ref) {
  final useCase = ref.read(searchDoctorsUseCaseProvider);
  return SearchDoctorController(useCase);
});

class SearchDoctorController extends StateNotifier<AsyncValue<List<Doctor>>> {
  final SearchDoctorsUseCase searchDoctorsUseCase;

  SearchDoctorController(this.searchDoctorsUseCase)
      : super(const AsyncValue.data([]));

  Future<void> searchDoctors(SearchFilter filter) async {
    state = const AsyncValue.loading();
    try {
      final doctors = await searchDoctorsUseCase.execute(filter);
      state = AsyncValue.data(doctors);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
