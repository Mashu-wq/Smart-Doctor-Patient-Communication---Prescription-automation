import 'package:firebase_auth/firebase_auth.dart';

class PatientAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw FirebaseAuthException(
        message: e.toString(),
        code: e.hashCode.toString(),
      );
    }
  }

  Future<UserCredential?> registerWithEmail(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw FirebaseAuthException(
        message: e.toString(),
        code: e.hashCode.toString(),
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw FirebaseAuthException(
        message: e.toString(),
        code: e.hashCode.toString(),
      );
    }
  }
}
