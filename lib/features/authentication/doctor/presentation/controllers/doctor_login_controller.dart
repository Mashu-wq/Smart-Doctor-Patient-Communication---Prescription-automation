import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/authentication/doctor/domain/usecases/doctor_login_usecase.dart';
import 'package:medisafe/features/authentication/doctor/domain/usecases/use_case_providers.dart';

// Controller for Doctor Login
final doctorLoginController =
    StateNotifierProvider<DoctorLoginController, AsyncValue<void>>(
  (ref) => DoctorLoginController(ref.read(doctorLoginUseCaseProvider)),
);

class DoctorLoginController extends StateNotifier<AsyncValue<void>> {
  final DoctorLoginUseCase loginUseCase;

  DoctorLoginController(this.loginUseCase) : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await loginUseCase.execute(email, password);
      state = const AsyncValue.data(null); // Login successful
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // Login failed
    }
  }

  // Method to check if login is successful
  bool isLoginSuccessful() {
    return state is AsyncData<void>;
  }
}
