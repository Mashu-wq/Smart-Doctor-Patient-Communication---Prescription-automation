import 'package:firebase_auth/firebase_auth.dart';

class DoctorAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? get doctorId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No authenticated user found");
    }
    return user.uid;
  }

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
