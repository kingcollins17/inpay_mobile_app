import '../api/auth.dart' as api;
import '../data/models.dart';

base class AccessKey {
  String value;
  User? _user;
  AccessKey(this.value);

  Future<bool> get isValid async {
    _user = await api.fetchUser(value);
    return _user != null;
  }

  Future<User?> get user async {
    if (_user == null && await isValid) {}
    return _user;
  }

  @override
  String toString() {
    return value;
  }
}
