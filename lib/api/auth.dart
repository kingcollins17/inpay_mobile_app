import 'dart:convert';

import 'package:http/http.dart' as http;

import './config.dart' as config;
import '../data/models.dart';

///This returns null if user for the associated [accessKey] is not found in the
///backend
Future<User?> fetchUser(String accessKey) async {
  try {
    final response = await http.get(Uri.parse('${config.ip}/'),
        headers: {'Authorization': 'Bearer $accessKey'});
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    }
    return null;
  } catch (e) {
    return null;
  }
}

Future<bool> registerUser(User user) async {
  try {
    final response = await http.post(Uri.parse('${config.ip}/auth/register'),
        body: json.encode(user.registerMap),
        headers: {'Content-Type': 'application/json'});
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

///Returns the authorization token as a string if login is successful
Future<String?> loginUser(User user) async {
  try {
    final response = await http.post(Uri.parse('${config.ip}/auth/login'),
        body: json.encode(user.loginMap),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return json.decode(response.body)['token'];
    }
    return null;
  } catch (e) {
    return null;
  }
}
