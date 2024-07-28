// ignore_for_file: unused_element, unused_import

import 'package:inpay_app/errors/base.dart';
import 'package:inpay_app/handler/base.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/auth.dart' as api;
import '../data/models.dart';
import 'access_key.dart';

///[Handler] for the authentication api
@Tested("Class")
abstract interface class AuthenticationHandler extends Handler {
  static AuthenticationHandler? _instance;

  ///The [accessKey] when authenticated
  AccessKey? accessKey;

  ///Throws a [SingletonError] if an instance already exists, hence, do
  ///not call this constructor directly, user the instance getter to
  ///access the sole instance of this object
  AuthenticationHandler() {
    if (_instance != null) {
      throw SingletonError();
    }
    AuthenticationHandler._instance = this;
    //else :instantiate empty object
  }

  ///Checks if instance already exists, hence returns it
  static AuthenticationHandler get instance {
    _instance ??= _AuthenticationHandlerImpl();
    return _instance!;
  }

  Future<bool> register(User user);
  Future<AccessKey?> login(User user);
  Future<bool> isTokenValid(AccessKey key);
  Future<AccessKey?> loadTokenFromDevice();
  Future<bool> removedStoredToken();
  Future<bool> storeAccessKey(AccessKey key);
}

///Default implementation of the AuthenticationHandler
class _AuthenticationHandlerImpl implements AuthenticationHandler {
  ///Registers a user and returns true if successfuly
  @override
  Future<bool> register(User user) async {
    return await api.registerUser(user);
  }

  ///Tries to login a user. If login is successful, an [AccessKey] is returned
  @override
  Future<AccessKey?> login(User user) async {
    final key = await api.loginUser(user);
    if (key != null) {
      accessKey = AccessKey(key);
      await storeAccessKey(accessKey ?? AccessKey(key));
      return accessKey;
    }
    return null;
  }

  @override
  Future<bool> isTokenValid(AccessKey key) async {
    return key.isValid;
  }

  @override
  Future<AccessKey?> loadTokenFromDevice() async {
    final storage = await SharedPreferences.getInstance();
    try {
      final key = storage.getString('accessKey');
      return AccessKey(key!);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> removedStoredToken() async {
    return (await SharedPreferences.getInstance()).remove('accessKey');
  }

  @override
  Future<bool> storeAccessKey(AccessKey key) async {
    final storage = await SharedPreferences.getInstance();
    try {
      return storage.setString('accessKey', '$key');
    } catch (e) {
      return false;
    }
  }

  @override
  AccessKey? accessKey;
}
