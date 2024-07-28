// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element

import 'package:animations/animations.dart';
import 'package:currency_symbols/currency_symbols.dart';
import 'package:flutter/material.dart';
import 'package:inpay_app/widgets/pop_up.dart';
import 'package:intl/intl.dart';
import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/global/auth_state.dart';
import 'package:inpay_app/global/data_state.dart';
import 'package:inpay_app/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../util.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  // final List<Savings> savings;

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  Widget? popUp;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> showPopUp(String message,
      [Duration delay = const Duration(seconds: 3)]) async {
    _controller.duration = const Duration(milliseconds: 200);
    _controller.reset();
    setState(() {
      popUp = PopUpMessage(animation: _controller, message: message);
    });
    await _controller.forward();
    return Future.delayed(delay, () {
      _controller.reverse().then((value) => setState(() => popUp = null));
    });
  }

  @override
  Widget build(BuildContext context) {
    var accessKey =
        Provider.of<AuthenticationState>(context, listen: false).accessKey;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
              child: Text(
                'Insave Pockets',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Expanded(
              child: Consumer<DataState>(
                builder: (context, state, child) {
                  final savings = state.getSavings(accessKey!)
                    ..sort((a, b) => b.date!.compareTo(a.date!));
                  return savings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline_rounded,
                                  size: 55, color: Color(0xFFDFDFDF)),
                              Text('You haven\'t saved any money yet',
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 5),
                                child: _Safe(
                                  savings: savings[index],
                                  onPressUnlock: (p0) {
                                    showModal(
                                        configuration:
                                            FadeScaleTransitionConfiguration(
                                                transitionDuration:
                                                    const Duration(
                                                        milliseconds: 350)),
                                        context: context,
                                        builder: (context) =>
                                            UnlockConfirmation(
                                                savings: p0)).then((value) {
                                      if (value == true) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        return state
                                            .unlockSavings(p0, accessKey,
                                                interest: calculateInterest(
                                                    amount: p0.amount,
                                                    startDate: p0.date!))
                                            .then((value) {
                                          showPopUp(
                                              'Savings unlocked successfully');
                                          setState(() => isLoading = false);
                                        });
                                      }
                                      showPopUp('Operation aborted by user');
                                    });
                                  },
                                ));
                          },
                          itemCount: savings.length,
                        );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, "/save"),
            backgroundColor: const Color.fromARGB(255, 20, 131, 77),
            shape: CircleBorder(),
            child: Icon(Icons.add, color: Color.fromARGB(255, 226, 226, 226)),
          ),
        ),
        if (true)
          Positioned(
              width: MediaQuery.of(context).size.width,
              bottom: 20,
              child: Center(child: popUp)),
        if (isLoading) LoadingIndicator()
      ],
    );
  }
}

class UnlockConfirmation extends StatelessWidget {
  const UnlockConfirmation({super.key, required this.savings});
  final Savings savings;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Ink(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 22, 22, 22),
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Ink(
                          padding: EdgeInsets.all(5),
                          // color: Colors.white,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color.fromARGB(255, 230, 230, 230)),
                          child: Icon(
                            Icons.close,
                            size: 25,
                            color: const Color.fromARGB(255, 12, 12, 12),
                          )),
                    )),
                const SizedBox(height: 10),
                Text(
                  'Press Confirm Unlock to unlock savings',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    // mainAxisSize: MainAxisSize.max,
                    children: [
                      // const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Amount: ',
                              style: Theme.of(context).textTheme.bodySmall),
                          Text(
                            NumberFormat.currency(
                                    locale: 'en_us', symbol: cSymbol('NGN'))
                                .format(savings.amount),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Open sans',
                                color: const Color.fromARGB(255, 219, 219, 219),
                                fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Interest: ',
                              style: Theme.of(context).textTheme.bodySmall),
                          Text(
                            '+'
                            '${NumberFormat.currency(locale: 'en_us', symbol: cSymbol('NGN')).format(calculateInterest(amount: savings.amount, startDate: savings.date!))}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.greenAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context, true),
                        icon: Icon(Icons.lock_open_rounded),
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStatePropertyAll(Colors.blueAccent)),
                        label: Text(
                          'Confirm Unlock',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 14,
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Safe extends StatelessWidget {
  const _Safe({super.key, required this.savings, this.onPressUnlock});
  final Savings savings;
  final void Function(Savings)? onPressUnlock;

  @override
  Widget build(BuildContext context) {
    return Ink(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 29, 29, 29),
          borderRadius: BorderRadius.circular(5),
          // border: Border.all(color: Color.fromARGB(255, 44, 44, 44)),
          boxShadow: [
            // BoxShadow(color: Colors.grey, blurRadius: 0.5, spreadRadius: 1.5),
            BoxShadow(
              color: Color.fromARGB(255, 29, 29, 29),
              blurRadius: 1.5,
              spreadRadius: 0.5,
            ),
            // BoxShadow(color: Colors.grey, blurRadius: 0.5),
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Pocket ${savings.id}',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 209, 209, 209)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                    NumberFormat.currency(
                            locale: 'en_us', symbol: cSymbol('NGN'))
                        .format(savings.amount),
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(255, 219, 219, 219),
                        fontFamily: 'Open sans')),
                const SizedBox(width: 8),
                Icon(Icons.visibility, size: 20)
              ],
            ),
            Ink(
              child: Row(
                children: [
                  Text('Interest: ',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    '+${NumberFormat.currency(locale: 'en_us', symbol: cSymbol('NGN')).format(calculateInterest(amount: savings.amount, startDate: savings.date!))}',
                    style: TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'Open sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  )
                ],
              ),
            ),
          ]),
          ElevatedButton(
              style: ButtonStyle(
                  iconColor: MaterialStatePropertyAll(Colors.blueAccent),
                  foregroundColor: MaterialStatePropertyAll(Colors.blueAccent),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)))),
              onPressed: () =>
                  onPressUnlock == null ? null : onPressUnlock!(savings),
              child: Text(
                'Unlock',
                style: TextStyle(fontFamily: 'Quicksand'),
              ))
        ],
      ),
    );
  }
}
