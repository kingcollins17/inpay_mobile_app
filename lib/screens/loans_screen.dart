// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_const_declarations, unused_local_variable

import 'package:currency_symbols/currency_symbols.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/global/data_state.dart';
import 'package:inpay_app/screens/add_loan.dart';
import 'package:inpay_app/util.dart';
import 'package:provider/provider.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  double? amount;
  @override
  Widget build(BuildContext context) {
    final factor = 100000.00;
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Loans',
                      style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Get Access to Instant Loans',
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Quicksand',
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Enjoy interest rates at 0.1% with up to '
                    '${cSymbol("NGN")}5,000,000.00 on your first loan',
                    style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/loans');
                      },
                      child: Text('See your Loans')),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Center(
                      child: Consumer<DataState>(
                        builder: (context, value, child) {
                          var account = value.accounts.first;
                          var maxDebt = value.loans.isEmpty
                              ? 0
                              : calculateTotalDebt(value.loans);
                          final creditLimit =
                              ((account.level! * factor) - maxDebt);
                          return _CreditScore(
                            account: account,
                            amount: amount ??
                                (creditLimit > 0 && creditLimit > 50000
                                    ? creditLimit
                                    : 0),
                            onSlide: (value) => setState(() => amount = value),
                            max: creditLimit,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 15,
              child: FilledButton(
                onPressed: () {
                  if (amount != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddLoan(maxAmount: amount!),
                        ));
                  }
                },
                style: ButtonStyle(
                    fixedSize: MaterialStatePropertyAll(
                        Size(MediaQuery.of(context).size.width * 0.7, 45)),
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                    backgroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.secondary)),
                child: Text(
                  'Apply for Loan',
                  style: TextStyle(fontSize: 16, fontFamily: 'Quicksand'),
                ),
              ))
        ],
      ),
    );
  }
}

class _CreditScore extends StatelessWidget {
  const _CreditScore({
    super.key,
    required this.account,
    this.onSlide,
    required this.amount,
    required this.max,
  });
  final Account account;
  final void Function(double)? onSlide;
  final double amount, max;

  @override
  Widget build(BuildContext context) {
    final double factor = 100000, min = 50000;
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 180,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 31, 31, 31),
          borderRadius: BorderRadius.circular(5)),
      child: Column(
        children: [
          Text('Credit Limit', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          Text(
            NumberFormat.currency(locale: 'en_us', symbol: cSymbol('NGN'))
                .format(amount),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 35,
                fontFamily: 'Open sans',
                decoration: TextDecoration.none,
                color: Colors.greenAccent,
                fontWeight: FontWeight.w600),
          ),
          Slider.adaptive(
            value: amount,
            min: (min <= max) ? min : 0,
            max: max > min ? max : 0,
            divisions: 10,
            onChanged: onSlide,
          ),
          Expanded(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'You can borrow up to ${NumberFormat.currency(locale: "en_us", symbol: cSymbol("NGN")).format(amount)}',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Open sans',
                        fontWeight: FontWeight.w300,
                        decoration: TextDecoration.none,
                        color: Colors.grey),
                  )))
        ],
      ),
    );
  }
}
