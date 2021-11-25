import 'package:connectivity/connectivity.dart';

mixin ConnectivityChecker {
  Future<bool> hasConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }
}
