// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:currency_symbols/currency_symbols.dart';
import 'package:flutter/material.dart';
import 'package:inpay_app/widgets/copy_to_clipboard.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';

class TransactionReceiptScreen extends StatelessWidget {
  const TransactionReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)?.settings.arguments as (Transaction, Account);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
              title: Text(
            'Transaction Details',
            style: TextStyle(fontFamily: 'Quicksand', fontSize: 16),
          )),
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF161616),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      (data.$1.senderId == data.$2.id ? '- ' : '+ ') +
                          NumberFormat.currency(
                                  locale: 'en_us', symbol: cSymbol('NGN'))
                              .format(data.$1.amount),
                      style: TextStyle(
                          fontFamily: 'Open sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF161616),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction Details',
                          style:
                              TextStyle(fontSize: 14, fontFamily: 'Quicksand'),
                        ),
                        const SizedBox(height: 20),
                        _DetailTile(
                          label: data.$1.senderId == data.$2.id
                              ? 'Recipient'
                              : 'Sender',
                          value: data.$1.senderId == data.$2.id
                              ? data.$1.recipient!
                              : data.$1.sender!,
                        ),
                        const SizedBox(height: 10),
                        _DetailTile(
                          label: 'Session ID',
                          value: '${data.$1.hash!.substring(0, 10)}...',
                          trailing: CopyToClipboard(data: data.$1.hash!),
                        ),
                        const SizedBox(height: 20),
                        _DetailTile(
                            label: 'Transaction Type', value: 'InTransfer'),
                        const SizedBox(height: 20),
                        _DetailTile(label: 'Wallet', value: 'Inpay'),
                        const SizedBox(height: 20),
                        _DetailTile(
                            label: 'Date', value: data.$1.date!.toString())
                      ]),
                )
              ],
            ),
          ),
        ),
        Positioned(
            bottom: 20,
            right: 10,
            child: FilledButton(
                onPressed: () {},
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.secondary)),
                child: Text(
                  'Share Receipt',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Quicksand',
                      color: Colors.white),
                )))
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
  });
  final String label, value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 5),
            trailing ?? SizedBox()
          ],
        ),
      ],
    );
  }
}
