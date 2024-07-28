// ignore_for_file: unused_field, prefer_const_constructors, unused_element, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/util.dart';
import 'package:inpay_app/widgets/transaction_history.dart';

import 'history_sub_section.dart';

class TransactionHistories extends StatelessWidget {
  const TransactionHistories({
    super.key,
    required this.transactions,
    required this.account,
  });
  final List<Transaction> transactions;
  final Account account;

  @override
  Widget build(BuildContext context) {
    // "gh".length.compareTo(8);
    var months = separateMonths(transactions);
    final sublist = transactions.length > 6
        ? transactions.reversed.toList().sublist(0, 6)
        : transactions;
    return Column(children: [
      ...List.generate(months.length, (index) {
        return HistorySubSection(
          histories: sublist
              .where((element) =>
                  element.date!.month ==
                      months[months.length - (index + 1)].$1 &&
                  (element.date!.year ==
                      months[months.length - (index + 1)].$2))
              .toList()
            ..sort((a, b) => b.date!.compareTo(a.date!)),
          account: account,
        );
      }),
    ]);
  }
}

String _parseMonth(int month) {
  return [
    'Jan',
    'Feb',
    'Mar',
    'April',
    'May',
    'June',
    'July',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec'
  ][month];
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    super.key,
    required this.transactions,
    required this.account,
  });
  final List<Transaction> transactions;
  final Account account;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (transactions.isNotEmpty)
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration:
              BoxDecoration(color: const Color.fromARGB(255, 36, 36, 36)),
          child: Text(
            '${_parseMonth(transactions[0].date!.month - 1)} ${transactions[0].date!.year}',
            style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
        ),
      Column(
          children: List.generate(
              transactions.length,
              (index) => TransactionHistory(
                  isOutgoing: account.id == transactions[index].senderId,
                  transaction: transactions[index],
                  onPress: () {}))),
    ]);
  }
}
