import 'package:flutter/foundation.dart';
import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/handler/access_key.dart';
import 'package:inpay_app/handler/auth_handler.dart';

class AuthenticationState with ChangeNotifier, DiagnosticableTreeMixin {
  final handler = AuthenticationHandler.instance;
  AccessKey? accessKey;
  User? user;

  var isAuthenticated = false;
  var isLoading = false;

  Future<void> authenticate(AccessKey accessKey) async {
    this.accessKey = accessKey;
    isAuthenticated = true;
    isLoading = false;
    user = await accessKey.user;
    notifyListeners();
  }

  void logOut() {
    isLoading = false;
    user = null;
    accessKey = null;
    isAuthenticated = false;
    notifyListeners();
  }
}
