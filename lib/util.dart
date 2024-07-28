// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:inpay_app/data/models.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    String message, BuildContext context) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: const Duration(milliseconds: 1500),
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              color: Colors.grey, borderRadius: BorderRadius.circular(40)),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontFamily: 'Quicksand'),
          ),
        ),
      ],
    ),
    elevation: 0,
    backgroundColor: Colors.transparent,
  ));
}

List<(int month, int year)> separateMonths(List<Transaction> transactions) {
  var months = [
    (transactions.first.date!.month, transactions.first.date!.year)
  ];
  for (var e in transactions) {
    //if month integer is not in list already
    if (!months.contains((e.date!.month, e.date!.year))) {
      months.add((e.date!.month, e.date!.year));
    }
  }

  return months;
}

String parseMonth(int month) => [
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
    ][month - 1];

double calculateInterest(
    {required double amount,
    required DateTime startDate,
    double rate = 0.00005}) {
  if (rate > 0.9) rate = 0.9;
  final duration = DateTime.now().difference(startDate);
  return (rate * duration.inDays) * amount;
}

double calculateTotalDebt(List<Loan> loans) {
  return loans.isEmpty
      ? 0.0
      : loans
          .reduce((value, element) => Loan(
              id: value.id,
              accountId: value.accountId,
              amount: value.amount + element.amount,
              date: value.date))
          .amount;
}
