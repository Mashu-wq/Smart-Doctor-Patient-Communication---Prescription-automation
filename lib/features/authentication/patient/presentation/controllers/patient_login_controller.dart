// Controller for Doctor Login
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/authentication/patient/domain/usecases/patient_login_usecase.dart';
import 'package:medisafe/features/authentication/patient/domain/usecases/use_case_providers.dart';

final patientLoginControllerProvider =
    StateNotifierProvider<PatientLoginController, AsyncValue<void>>(
  (ref) => PatientLoginController(ref.read(patientLoginUseCaseProvider)),
);

class PatientLoginController extends StateNotifier<AsyncValue<void>> {
  final PatientLoginUseCase loginUseCase;

  PatientLoginController(this.loginUseCase)
      : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await loginUseCase.execute(email, password);
      state = const AsyncValue.data(null); // Login successful
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // Login failed
    }
  }

  // Utility method to check if login was successful
  bool isLoginSuccessful() {
    return state is AsyncData && (state as AsyncData).value == null;
  }
}
