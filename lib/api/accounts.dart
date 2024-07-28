import 'package:http/http.dart' as http;
import 'dart:convert';

import 'config.dart' as config;
import '../data/models.dart';

Future<List<Account>> fetchAccounts(String accessKey) async {
  try {
    final response = await http.get(Uri.parse('${config.ip}/accounts'),
        headers: {'Authorization': 'Bearer $accessKey'});
    return Account.fromList(json.decode(response.body));
  } catch (e) {
    return [];
  }
}

Future<Account?> findAccount(String account,
    {required String accessKey}) async {
  try {
    final response = await http.get(
        Uri.parse('${config.ip}/accounts/find?account=$account'),
        headers: {'Authorization': 'Bearer $accessKey'});

    if (response.statusCode != 200) return null;
    return Account.fromJson(json.decode(response.body));
  } catch (e) {
    return null;
  }
}

///name, pin and userId must be provided
Future<bool> createAccount(Account account, {required String accessKey}) async {
  try {
    final response = await http.post(Uri.parse('${config.ip}/accounts/create'),
        body: json.encode({
          'name': account.name,
          'pin': account.pin,
          'user_id': account.userId
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessKey'
        });

    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<bool> depositFunds(Account account,
    {required double amount, required String accessKey}) async {
  try {
    final response = await http.get(
        Uri.parse(
            '${config.ip}/accounts/deposit?id=${account.id}&amount=$amount'),
        headers: {'Authorization': 'Bearer $accessKey'});

    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<bool> withdrawFunds(Account account,
    {required double amount, required String accessKey}) async {
  try {
    final response = await http.get(
        Uri.parse(
            '${config.ip}/accounts/withdraw?id=${account.id}&amount=$amount'),
        headers: {'Authorization': 'Bearer $accessKey'});
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

///amount, senderId and recipientId must never be null, else TypeError is thrown
Future<bool> transferFunds(Transaction transaction,
    {required String accessKey}) async {
  try {
    final response = await http.post(
        Uri.parse('${config.ip}/accounts/transfer'),
        body: json.encode(transaction.transferMap),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessKey'
        });
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<List<Transaction>> fetchTransactionHistory(Account account,
    {required bool outgoing, required String accessKey}) async {
  try {
    final response = await http.get(
        Uri.parse(
            '${config.ip}/accounts/history?id=${account.id}&out=$outgoing'),
        headers: {'Authorization': 'Bearer $accessKey'});

    var decoded = json.decode(response.body) as List;
    if (response.statusCode == 200 && decoded.isNotEmpty) {
      return Transaction.fromHistoryList(decoded,
          outgoing: outgoing, account: account);
    }
    return [];
    // return json.decode(response.body)[0];
  } catch (e) {
    return [];
  }
}

Future<bool> lockSaveFunds(Account account,
    {required double amount, required String accessKey}) async {
  try {
    if (account.balance! <= amount) throw Exception('Insufficient balance');
    final response = await http.get(
        Uri.parse('${config.ip}/accounts/save?id=${account.id}&amount=$amount'),
        headers: {'Authorization': 'Bearer $accessKey'});

    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<dynamic> fetchSavedFunds(Account account,
    {required String accessKey}) async {
  try {
    final response = await http.get(
        Uri.parse('${config.ip}/accounts/save/all?account=${account.id}'),
        headers: {'Authorization': 'Bearer $accessKey'});
    if (response.statusCode == 200) {
      var decoded = json.decode(response.body) as List;
      return Savings.fromJsonList(decoded);
    }
  } catch (_) {
    return [];
  }
}

Future<bool> unlockSavedFunds(Savings savings,
    {required String accessKey}) async {
  try {
    final response = await http.get(
        Uri.parse('${config.ip}/accounts/unlock?id=${savings.id}'),
        headers: {'Authorization': 'Bearer $accessKey'});
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<List<Loan>> fetchLoans(Account account,
    {required String accessKey}) async {
  try {
    final response = await http.get(
      Uri.parse('${config.ip}/accounts/loan?account=${account.id}'),
      headers: {'Authorization': 'Bearer $accessKey'},
    );
    if (response.statusCode == 200) {
      var decoded = json.decode(response.body);
      return Loan.fromJsonList(decoded);
    }
    return [];
  } catch (e) {
    return [];
  }
}

Future<bool> requestLoan(Account account,
    {required double amount, required String accessKey}) async {
  try {
    if (amount > (account.level! * 1000000)) {
      throw Exception("Not Eligible for this loan amount");
    }
    final response = await http.post(
        Uri.parse(
            '${config.ip}/accounts/loan?account=${account.id}&amount=$amount'),
        headers: {'Authorization': 'Bearer $accessKey'});

    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<bool> repayLoan(Loan loan, {required String accessKey}) async {
  try {
    final response = await http.get(
        Uri.parse('${config.ip}/accounts/loan/repay?loan=${loan.id}'),
        headers: {'Authorization': 'Bearer $accessKey'});
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
