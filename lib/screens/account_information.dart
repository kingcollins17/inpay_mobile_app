// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:inpay_app/global/data_state.dart';
import 'package:inpay_app/widgets/copy_right.dart';

import '../widgets/copy_to_clipboard.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key, required this.data});
  final DataState data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Account Information',
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Quicksand',
        ),
      )),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration:
                  BoxDecoration(color: const Color.fromARGB(255, 29, 29, 29)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Information(
                    title: 'Inpay Account Number',
                    value: data.accounts.first.accountNumber!,
                    trailing: CopyToClipboard(
                      data: data.accounts.first.accountNumber!,
                    ),
                  ),
                  _Information(
                    title: 'Bank',
                    value: 'Inpay',
                  ),
                  const SizedBox(height: 10),
                  _Information(
                      title: 'Account Name', value: data.accounts.first.name)
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration:
                  BoxDecoration(color: const Color.fromARGB(255, 29, 29, 29)),
              child: Column(
                children: [
                  _Information(
                    title: 'Account pin',
                    value: data.accounts.first.pin.toString(),
                    trailing: Icon(Icons.key_rounded, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
                child: Align(
                    alignment: Alignment.bottomCenter, child: CopyRight())),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}

class _Information extends StatelessWidget {
  const _Information({
    super.key,
    required this.title,
    required this.value,
    this.trailing,
  });
  final String title, value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
              fontSize: 14, fontFamily: 'Quicksand', color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(value), trailing ?? SizedBox()],
        ),
      ],
    );
  }
}
