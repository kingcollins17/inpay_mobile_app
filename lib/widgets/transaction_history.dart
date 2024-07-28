// ignore_for_file: unused_field, prefer_const_constructors, unused_element, prefer_const_literals_to_create_immutables

import 'package:currency_symbols/currency_symbols.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';

class TransactionHistory extends StatelessWidget {
  const TransactionHistory({
    super.key,
    required this.transaction,
    required this.onPress,
    this.isOutgoing = true,
  });
  final Transaction transaction;
  final VoidCallback onPress;
  final bool isOutgoing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      overlayColor: MaterialStatePropertyAll(Color.fromARGB(85, 29, 29, 29)),
      child: Ink(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: const Color.fromARGB(255, 10, 10, 10)),
        child: Row(children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: isOutgoing
                    ? Color.fromARGB(36, 218, 0, 0)
                    : Color.fromARGB(26, 35, 224, 133),
                shape: BoxShape.circle),
            child: Icon(Icons.account_balance_rounded,
                size: 20,
                color: isOutgoing ? Colors.redAccent : Colors.greenAccent),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isOutgoing ? transaction.recipient! : transaction.sender!,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white)),
              Text(
                  '${transaction.date!.hour}:'
                  '${transaction.date!.minute < 10 && transaction.date!.minute > 0 ? '0' : ''}'
                  '${transaction.date!.minute}'
                  '${transaction.date!.minute % 10 == 0 ? 0 : ''}'
                  ' ${transaction.date!.hour > 12 ? "pm" : "am"}',
                  style: Theme.of(context).textTheme.bodySmall)
            ],
          ),
          const Expanded(child: SizedBox()),
          Row(
            children: [
              Text(isOutgoing ? '- ' : '+ '),
              Text(
                NumberFormat.currency(locale: 'en_us', symbol: cSymbol('NGN'))
                    .format(transaction.amount),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Open sans',
                    color: isOutgoing ? Colors.redAccent : Colors.greenAccent),
              )
            ],
          )
        ]),
      ),
    );
  }
}
