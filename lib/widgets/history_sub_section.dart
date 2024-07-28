// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/util.dart';
import 'package:inpay_app/widgets/transaction_history.dart';

class HistorySubSection extends StatelessWidget {
  const HistorySubSection(
      {super.key, required this.histories, required this.account});
  // final DateTime date;
  final List<Transaction> histories;
  final Account account;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            decoration:
                BoxDecoration(color: const Color.fromARGB(255, 41, 41, 41)),
            child: Text(
              '${parseMonth(histories.first.date!.month)} ${histories.first.date!.year}',
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Quicksand',
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ),
          ...List.generate(
              histories.length,
              // list.length,
              (index) => TransactionHistory(
                    transaction: histories[index],
                    onPress: () => Navigator.pushNamed(context, '/receipt',
                        arguments: (histories[index], account)),
                    isOutgoing: histories[index].senderId == account.id,
                  ))
        ],
      ),
    );
  }
}
