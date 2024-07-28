// ignore_for_file: unused_element, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:inpay_app/api/accounts.dart';
import 'package:inpay_app/api/auth.dart';
import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/handler/access_key.dart';

import '../api/admin.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String? response;
  bool isLoading = false;
  String? token;

  Future<dynamic> _testAccessKey() async {
    return AccessKey(token!);
  }

  Future<dynamic> _testChangePassword() async {
    return changeUserPassword('NewPassword', accessKey: token!);
  }

  Future<dynamic> _testChangePin() async {
    return changeAccountPin(Account(id: 2, name: '', userId: 4),
        newPin: 4561, accessKey: token!);
  }

  Future<dynamic> _testDeleteAccount() async {
    return deleteAccount(Account(id: 4, name: '', userId: 1),
        accessKey: token!);
  }

  Future<dynamic> _testDeleteUser() async {
    return deleteUser(accessKey: token!);
  }

  Future<dynamic> _testFetchUser() async {
    return fetchUser(token!);
  }

  Future<dynamic> _testRepayLoan() async {
    return repayLoan(Loan(id: 9, accountId: 1, amount: 1), accessKey: token!);
  }

  Future<dynamic> _testRequestLoan() async {
    return requestLoan(Account(id: 7, name: '', userId: 5),
        amount: 11200, accessKey: token!);
  }

  Future<dynamic> _testFetchLoans() async {
    return fetchLoans(Account(id: 13, name: '', userId: 5), accessKey: token!);
  }

  Future<dynamic> _testUnlock() async {
    return unlockSavedFunds(Savings(id: 3, accountId: 1, amount: 10),
        accessKey: token!);
  }

  Future<dynamic> _testFetchSave() async {
    return fetchSavedFunds(Account(id: 8, balance: 10000, name: '', userId: 1),
        accessKey: token!);
  }

  Future<dynamic> _testSave() async {
    return lockSaveFunds(Account(id: 8, balance: 10000, name: '', userId: 1),
        amount: 2000, accessKey: token!);
  }

  Future<dynamic> _testHistory() async {
    return fetchTransactionHistory(Account(id: 14, name: 'Anna', userId: 1),
        outgoing: false, accessKey: token!);
  }

  Future<dynamic> _testTransfer() async {
    return transferFunds(
        Transaction(senderId: 13, recipientId: 14, amount: 1500),
        accessKey: token!);
  }

  Future<dynamic> _testCreateAccount() async {
    return createAccount(
        Account(name: "Jonny's Bakeries", userId: 2, pin: 3294),
        accessKey: token!);
  }

  Future<dynamic> _testWithdraw() async {
    return withdrawFunds(Account(id: 3, name: '', userId: 1),
        amount: 1000, accessKey: token!);
  }

  Future<dynamic> _testDeposit() async {
    return depositFunds(Account(id: 14, name: '', userId: 1),
        amount: 254600, accessKey: token!);
  }

  Future<dynamic> _testFind() async {
    return findAccount('3107833516', accessKey: token!);
  }

  Future<dynamic> _testFetchAccount() async {
    return fetchAccounts(token!);
  }

  Future<dynamic> _testAuth() async {
    return loginUser(User(
        name: 'Osuofia', email: 'axle@gmail.com', password: 'NewPassword'));
  }

  Future<dynamic> _testRegister() async {
    return registerUser(User(
        name: 'Mary Billie',
        email: 'billie@gmail.com',
        password: 'billiepass'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  response ?? 'Test Screen',
                  style: TextStyle(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 223, 223, 223),
                      decoration: TextDecoration.none),
                ),
              )),
              SizedBox(height: 15),
              ElevatedButton(
                  onPressed: () {
                    setState(() => isLoading = true);
                    // _testRegister().then((value) => setState(() {
                    //       isLoading = false;
                    //       response = value.toString();
                    //     }));
                    _testAuth().then((value) {
                      setState(() {
                        token = value.toString();
                        response = token;
                        // isLoading = false;
                      });
                      _testHistory().then((value) {
                        setState(() {
                          isLoading = false;
                          response = value.toString();
                        });
                      });
                    });
                  },
                  child: Text('Test API'))
            ],
          ),
        ),
        if (isLoading)
          Center(
            child: SizedBox.square(
              dimension: 30,
              child: CircularProgressIndicator(
                backgroundColor: const Color.fromARGB(255, 61, 61, 61),
                color: Colors.white,
              ),
            ),
          )
      ],
    ));
  }
}
