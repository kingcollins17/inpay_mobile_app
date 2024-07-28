import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/errors/base.dart';
import 'package:inpay_app/handler/access_key.dart';

import '../api/admin.dart' as api;
import './base.dart';

@Tested('class')
abstract class AdminHandler extends Handler {
  static AdminHandler? _instance;

  AdminHandler() {
    if (_instance != null) {
      throw SingletonError();
    }
    AdminHandler._instance ??= this;
  }

  ///
  static AdminHandler get instance {
    return AdminHandler._instance ??= AdminHandlerImpl();
  }

  //
  @tested
  Future<dynamic> deleteAccount(Account account,
      {required AccessKey accessKey});
  //
  @tested
  Future<bool> changePin(Account account,
      {required int newPin, required AccessKey accessKey});
  //
  @tested
  Future<bool> changePassword(String password, {required AccessKey accessKey});
  //
  Future<dynamic> deleteUser(AccessKey accessKey);
}

@Tested('class')
class AdminHandlerImpl extends AdminHandler {
  AccessKey? _accessKey;

  AccessKey? get accessKey => _accessKey;

  @override
  Future<dynamic> deleteAccount(Account account,
      {required AccessKey accessKey}) async {
    _accessKey = accessKey;
    return api.deleteAccount(account, accessKey: accessKey.toString());
  }

  @override
  Future<bool> changePin(Account account,
      {required int newPin, required AccessKey accessKey}) async {
    return api.changeAccountPin(account,
        newPin: newPin, accessKey: accessKey.toString());
  }

  @override
  Future<bool> changePassword(String password,
      {required AccessKey accessKey}) async {
    return api.changeUserPassword(password, accessKey: accessKey.toString());
  }

  @override
  Future<dynamic> deleteUser(AccessKey accessKey) async {
    return api.deleteUser(accessKey: accessKey.toString());
  }
}
