import 'package:http/http.dart' as http;

import './config.dart' as config;
import '../data/models.dart';

Future<bool> deleteUser({required String accessKey}) async {
  try {
    final response = await http.delete(Uri.parse('${config.ip}/admin/user'),
        headers: {'Authorization': 'Bearer $accessKey'});
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteAccount(Account account, {required String accessKey}) async {
  try {
    final response = await http.delete(
      Uri.parse('${config.ip}/admin/account?account=${account.id}'),
      headers: {'Authorization': 'Bearer $accessKey'},
    );
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<bool> changeUserPassword(String newPassword,
    {required String accessKey}) async {
  try {
    final response = await http.put(
      Uri.parse('${config.ip}/admin/password?password=$newPassword'),
      headers: {'Authorization': 'Bearer $accessKey'},
    );
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<bool> changeAccountPin(Account account,
    {required int newPin, required String accessKey}) async {
  try {
    final response = await http.put(
      Uri.parse('${config.ip}/admin/pin?account=${account.id}&pin=$newPin'),
      headers: {'Authorization': 'Bearer $accessKey'},
    );
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
