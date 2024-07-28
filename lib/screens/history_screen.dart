// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/util.dart';
import 'package:inpay_app/widgets/transaction_history.dart';

import '../widgets/history_sub_section.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)?.settings.arguments as (
      List<Transaction>,
      Account
    );
    final months = data.$1.isNotEmpty ? separateMonths(data.$1) : null;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Transactions',
            style: TextStyle(fontFamily: 'Quicksand', fontSize: 16),
          ),
        ),
        if (data.$1.isEmpty)
          SliverToBoxAdapter(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Icon(
                Icons.info_outline_rounded,
                size: 65,
                color: Colors.blueAccent,
              ),
              SizedBox(height: 10),
              Text(
                'Nothing to show!',
                style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    color: const Color.fromARGB(255, 197, 197, 197),
                    fontFamily: 'Quicksand'),
              )
            ],
          )),
        if (data.$1.isNotEmpty)
          ...List.generate(months!.length, (index) {
            return SliverToBoxAdapter(
              key: ValueKey(index),
              child: HistorySubSection(
                histories: data.$1
                    .where((element) =>
                        element.date!.month ==
                            months[months.length - (index + 1)].$1 &&
                        (element.date!.year ==
                            months[months.length - (index + 1)].$2))
                    .toList()
                  ..sort((a, b) => b.date!.compareTo(a.date!)),
                account: data.$2,
              ),
            );
          }),
      ],
    );
  }
}

List<Transaction> list = [
  Transaction(
    id: 1,
    senderId: 21,
    recipientId: 22,
    amount: 250000,
    sender: 'Sender',
    recipient: 'Receiver',
    date: DateTime.now().subtract(Duration(days: 34)),
  ),
  Transaction(
      id: 2,
      senderId: 21,
      recipientId: 21,
      amount: 55000,
      sender: 'Sender',
      recipient: 'Receiver',
      date: DateTime.now().subtract(Duration(days: 74))),
  Transaction(
      id: 3,
      senderId: 22,
      recipientId: 21,
      amount: 120000,
      sender: 'Sender',
      recipient: 'Receiver',
      date: DateTime.now().subtract(Duration(days: 124)))
];
