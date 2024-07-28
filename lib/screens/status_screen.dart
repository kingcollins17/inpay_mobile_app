// ignore_for_file: prefer_const_constructors

import 'package:currency_symbols/currency_symbols.dart';
import 'package:flutter/material.dart';
import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/global/auth_state.dart';
import 'package:inpay_app/global/data_state.dart';
import 'package:inpay_app/handler/account_handler.dart';
import 'package:inpay_app/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class TransactionStatusScreen extends StatefulWidget {
  const TransactionStatusScreen({super.key, required this.transaction});
  final Transaction transaction;

  @override
  State<TransactionStatusScreen> createState() =>
      _TransactionStatusScreenState();
}

class _TransactionStatusScreenState extends State<TransactionStatusScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.transparent,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: const SizedBox()),
                Ink(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 14, 150, 84),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Transfer of ${cSymbol("NGN")}${widget.transaction.amount}0 '
                    'to ${widget.transaction.recipient} successful',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(child: SizedBox()),
                Align(
                    child: OutlinedButton(
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStatePropertyAll(Colors.greenAccent),
                            side: MaterialStatePropertyAll(
                                BorderSide(color: Colors.greenAccent))),
                        //
                        onPressed: () {
                          setState(() => isLoading = true);
                          final auth = Provider.of<AuthenticationState>(context,
                              listen: false);
                          final data =
                              Provider.of<DataState>(context, listen: false);
                          data.refreshWith(auth.accessKey!, () async {
                            await AccountHandler.instance
                                .refreshAccounts(auth.accessKey!);
                            await AccountHandler.instance
                                .refreshTransactionHistory(data.accounts.first,
                                    outgoing: true, accessKey: auth.accessKey!);
                            //
                          }).then((value) {
                            setState(() => isLoading = false);
                            return Navigator.popAndPushNamed(
                                context, '/receipt',
                                arguments: (
                                  data.transactions.firstWhere((element) =>
                                      element.recipientId ==
                                          widget.transaction.recipientId &&
                                      element.amount ==
                                          widget.transaction.amount &&
                                      element.date!.day == DateTime.now().day),
                                  data.accounts.first
                                ));
                          });
                        },
                        child: Text('View Receipt'))),
                const SizedBox(height: 15)
              ],
            )),
        if (isLoading) LoadingIndicator(color: Colors.greenAccent)
      ],
    );
  }
}
