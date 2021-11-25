import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_blueraycargo/utilities/exceptions/general_exception.dart';
import 'package:test_blueraycargo/utilities/exceptions/google_sign_in_exception.dart';

class FirebaseAuthService {
  final _auth = FirebaseAuth.instance;

  FirebaseAuthService._privateConstructor();
  static final FirebaseAuthService _instance = FirebaseAuthService._privateConstructor();
  static FirebaseAuthService get instance => _instance; // singleton access

  User? get currentUser => _auth.currentUser;

  String _interpretError(FirebaseAuthException error) {
    switch (error.code) {
      case "too-many-requests":
        return "Terlalu sering request, coba lagi nanti.";
      case "wrong-password":
        return "email atau password anda salah.";
      case "invalid-email":
        return "Email anda tidak valid.";
      case "user-disabled":
        return "Saat ini anda sedang tidak bisa mengakses data";
      case "user-not-found":
        return "User tidak ditemukan.";
      case "network-request-failed":
        return "Gagal tersambung, periksa koneksi internet anda.";
      case "email-already-in-use":
        return "Email ini sudah pernah digunakan mendaftar.";
      default:
        return "${error.message}";
    }
  }

  Future<UserCredential> signInUsingGmail() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw GoogleSignInException("Gagal mendapatkan Google user data");
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, get UserCredential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      final errorMessage = _interpretError(e);
      throw GeneralException(errorMessage);
    } on GoogleSignInException {
      throw GoogleSignInException("Gagal mendapatkan Google user data");
    } catch (e) {
      throw GeneralException(e.toString());
    }
  }

  Future<void> logOut() async {
    await _auth.signOut();
  }
}
