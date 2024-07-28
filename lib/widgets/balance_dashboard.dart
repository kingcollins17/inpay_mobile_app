// ignore_for_file: unused_field, prefer_const_constructors, unused_element, prefer_const_literals_to_create_immutables

// import 'dart:ui';

import 'package:currency_symbols/currency_symbols.dart';
import 'package:flutter/material.dart';
import 'package:inpay_app/widgets/copy_to_clipboard.dart';
import 'package:inpay_app/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import 'package:intl/intl.dart';

import '../global/data_state.dart';

class BalanceDashboard extends StatefulWidget {
  const BalanceDashboard({
    super.key,
    required this.account,
    this.onRefresh,
  });
  final Account account;

  final Future<dynamic> Function()? onRefresh;

  @override
  State<BalanceDashboard> createState() => _BalanceDashboardState();
}

class _BalanceDashboardState extends State<BalanceDashboard> {
  bool isVisible = true;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        // height: 140,
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 27, 52, 97),
            borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Available balance',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                              onTap: () =>
                                  setState(() => isVisible = !isVisible),
                              child: Icon(
                                  isVisible
                                      ? Icons.visibility_off
                                      : Icons.remove_red_eye,
                                  size: 20,
                                  color: Colors.grey)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/history',
                            arguments: (
                              Provider.of<DataState>(context, listen: false)
                                  .transactions,
                              widget.account
                            )),
                        child: Row(
                          children: [
                            Text('History',
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.bodySmall),
                            Icon(Icons.arrow_right_rounded,
                                color: Color(0xFFD1D1D1))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    isVisible
                        ? NumberFormat.currency(
                                locale: 'en_us', symbol: cSymbol('NGN'))
                            .format(widget.account.balance)
                        : List.generate(
                            widget.account.balance?.toInt().toString().length ??
                                5,
                            (index) => "*").join(),
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Open sans',
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 184, 184, 184),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                // const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // const SizedBox(width: 10),
                        Row(
                          children: [
                            CopyToClipboard(
                                data: widget.account.accountNumber!),
                            const SizedBox(width: 5),
                            Text(
                              widget.account.accountNumber!,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Open sans',
                                  color: Colors.grey),
                            )
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            //if widget on refresh is not null
                            if (widget.onRefresh != null) {
                              setState(() => isLoading = true);
                              widget.onRefresh!().then(
                                  (value) => setState(() => isLoading = false));
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Color.fromARGB(55, 2, 79, 212),
                                shape: BoxShape.circle),
                            child: Icon(
                              Icons.refresh_rounded,
                              size: 25,
                              color: const Color.fromARGB(255, 182, 182, 182),
                            ),
                          ),
                        ),
                        // const SizedBox(width: 5),
                      ]),
                ),
                const SizedBox(height: 5),
              ],
            ),
            if (isLoading)
              Positioned(
                bottom: 10,
                width: MediaQuery.of(context).size.width,
                child: LoadingIndicator(
                    color: Colors.white,
                    dimension: 18,
                    backgroundColor: const Color.fromARGB(255, 66, 66, 66)),
              )
          ],
        ),
      ),
    );
  }
}
