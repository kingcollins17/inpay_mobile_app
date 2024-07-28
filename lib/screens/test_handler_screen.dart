// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/handler/access_key.dart';
import 'package:inpay_app/handler/account_handler.dart';
import 'package:inpay_app/handler/admin_handler.dart';
import 'package:inpay_app/handler/auth_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestHandlerScreen extends StatefulWidget {
  const TestHandlerScreen({super.key});

  @override
  State<TestHandlerScreen> createState() => _TestHandlerScreenState();
}

class _TestHandlerScreenState extends State<TestHandlerScreen> {
  String? response;
  bool isLoading = false;

  AccessKey? accessKey;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    response ?? "No response yet",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                      onPressed: () {
                        setState(() => isLoading = true);
                        AuthenticationHandler.instance
                            .login(User(
                                name: '',
                                email: 'gunna@gmail.com',
                                password: 'gunnapass'))
                            .then((value) {
                          setState(() {
                            isLoading = false;
                            accessKey = value;
                            response = value.toString();
                          });
                        });
                      },
                      child: Text('Test AUTH Handler')),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {
                        AccountHandler.instance
                            .transferFunds(
                                Transaction(
                                    senderId: 6,
                                    recipientId: 9,
                                    amount: 145000),
                                accessKey: accessKey!)
                            .then((value) {
                          AccountHandler.instance
                              .refreshTransactionHistory(
                                  Account(name: '', userId: 0, id: 9),
                                  outgoing: false,
                                  accessKey: accessKey!)
                              .then((value) {
                            setState(() {
                              isLoading = false;
                              response = value.toString();
                            });
                          });
                        });
                      },
                      child: Text('Test account handler')),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                        });
                        AdminHandler.instance
                            .deleteUser(accessKey!)
                            .then((value) {
                          setState(() {
                            isLoading = false;
                            response = value.toString();
                          });
                        });
                      },
                      child: Text('Test Admin Handler')),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {
                        setState(() => isLoading = true);
                        SharedPreferences.getInstance().then((value) {
                          value.clear().then((value) => setState(() {
                                isLoading = false;
                                response = value
                                    ? 'Preferences cleared'
                                    : 'Not cleared';
                              }));
                        });
                      },
                      child: Text('Clear preferences'))
                ],
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: SizedBox.square(
                dimension: 34,
                child: CircularProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Color.fromARGB(255, 37, 37, 37)),
              ),
            )
        ],
      ),
    );
  }
}
