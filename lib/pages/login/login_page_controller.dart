import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_blueraycargo/services/firebase_authentication/firebase_auth_service.dart';
import 'package:test_blueraycargo/utilities/exceptions/google_sign_in_exception.dart';
import 'package:test_blueraycargo/utilities/mixins/connectivity_checker.dart';

final loginPageControllerProvider = ChangeNotifierProvider.autoDispose<LoginPageController>((ref) {
  return LoginPageController();
});

class LoginPageController with ChangeNotifier, ConnectivityChecker {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  /// return true if it has successfully logged in
  Future<bool> signInWithGoogle() async {
    if (_isLoading) return false;

    _startLoading();

    try {
      await FirebaseAuthService.instance.signInUsingGmail();
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool("hasLoggedIn", true);
      return true;
    } on GoogleSignInException {
      _errorMessage = null;
      return false;
    } catch (error) {
      debugPrint(error.toString());
      _errorMessage = error.toString();
      return false;
    } finally {
      _stopLoading();
    }
  }
}
