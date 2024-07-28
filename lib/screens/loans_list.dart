// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:animations/animations.dart';
import 'package:currency_symbols/currency_symbols.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/global/auth_state.dart';
import 'package:inpay_app/global/data_state.dart';
import 'package:inpay_app/handler/account_handler.dart';
import 'package:inpay_app/util.dart';
import 'package:inpay_app/widgets/loading_indicator.dart';
import 'package:inpay_app/widgets/pop_up.dart';
import 'package:provider/provider.dart';

class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  Widget? popUp;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
  }

  void showPopUp(String message,
      [Duration duration = const Duration(seconds: 4)]) async {
    controller.duration = const Duration(milliseconds: 200);
    setState(() {
      popUp = PopUpMessage(animation: controller, message: message);
    });
    controller.forward().then((value) => Future.delayed(duration, () {
          controller.reverse().then((value) => setState(() {
                popUp = null;
                isLoading = false;
              }));
        }));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void resetState() => setState(() {
        isLoading = false;
        popUp = null;
      });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
                title: Text(
              'Inpay Loans',
              style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none),
            )),
            body: Consumer<DataState>(builder: (context, value, child) {
              final loans = value.loans;
              return ListView.builder(
                itemCount: loans.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: _LoanPocket(
                        loan: loans[index],
                        onPressPayback: (loan) {
                          showModal<bool?>(
                            context: context,
                            builder: (context) => PayBackModal(
                                account: value.accounts.first, loan: loan),
                          ).then((value) {
                            setState(() => isLoading = true);
                            value == null
                                ? showPopUp('Operation aborted by user')
                                : value == true
                                    ? AccountHandler.instance
                                        .paybackLoan(loan,
                                            accessKey: Provider.of<
                                                        AuthenticationState>(
                                                    context,
                                                    listen: false)
                                                .accessKey!)
                                        .then((paid) {
                                        setState(() => isLoading = false);
                                        showPopUp(paid
                                            ? "Loan payed successfully"
                                            : "Unable to pay back loan");
                                      })
                                    : showPopUp('Something went wrong');
                          });
                        },
                      ));
                },
              );
            })),
        if (popUp != null)
          Positioned(
              width: MediaQuery.of(context).size.width,
              bottom: 40,
              child: Padding(
                padding: EdgeInsets.symmetric(),
                child: Center(child: popUp),
              )),
        if (isLoading) LoadingIndicator()
      ],
    );
  }
}

class PayBackModal extends StatelessWidget {
  const PayBackModal({super.key, required this.account, required this.loan});
  final Account account;
  final Loan loan;

  // bool first = true, second = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 280,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 29, 29, 29),
              borderRadius: BorderRadius.circular(10)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 20),
            Text(
              'Are you sure you want to payback this Loan now',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 16,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Text('Balance: '),
                const SizedBox(width: 8),
                Text(
                  NumberFormat.currency(locale: 'en_us', symbol: cSymbol('NGN'))
                      .format(account.balance),
                  style: TextStyle(
                      fontFamily: 'Open sans',
                      fontWeight: FontWeight.normal,
                      color: (account.balance! > loan.amount)
                          ? Colors.greenAccent
                          : Color(0xFFD11E1E)),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              Text('Loan Amount: '),
              const SizedBox(width: 8),
              Text(
                NumberFormat.currency(locale: 'en_us', symbol: cSymbol('NGN'))
                    .format(loan.amount),
                style: TextStyle(
                    fontFamily: 'Open sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              )
            ]),
            const SizedBox(height: 10),
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Interest accrued'),
                const SizedBox(width: 8),
                Text(
                  // ignore: prefer_interpolation_to_compose_strings
                  '- ' +
                      NumberFormat.currency(
                              locale: 'en_us', symbol: cSymbol('NGN'))
                          .format(calculateInterest(
                              amount: loan.amount, startDate: loan.date!)),
                  style: TextStyle(color: Colors.redAccent),
                )
              ],
            ),
            Expanded(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          Theme.of(context).colorScheme.secondary),
                      foregroundColor: MaterialStatePropertyAll(
                          const Color.fromARGB(255, 221, 221, 221))),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Yes and continue',
                    style: TextStyle(fontFamily: 'Quicksand'),
                  )),
            ))
          ]),
        ),
      ),
    );
  }
}

class _LoanPocket extends StatelessWidget {
  const _LoanPocket({super.key, required this.loan, this.onPressPayback});
  final Loan loan;

  final void Function(Loan)? onPressPayback;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loan Pocket ${loan.id}',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                  color: const Color.fromARGB(255, 196, 196, 196),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                NumberFormat.currency(locale: 'en_us', symbol: cSymbol('NGN'))
                    .format(loan.amount),
                style: TextStyle(
                  fontFamily: 'Open sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  color: const Color.fromARGB(255, 218, 218, 218),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Interest',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 8),
                  Text(
                    '+ ${cSymbol("NGN")}${calculateInterest(amount: loan.amount, startDate: loan.date!)}',
                    style: TextStyle(
                        fontFamily: 'Open sans',
                        fontSize: 14,
                        color: Color(0xFFCA2222),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                  )
                ],
              )
            ],
          ),
          FilledButton.icon(
              onPressed: () =>
                  onPressPayback == null ? null : onPressPayback!(loan),
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Color(0xFF163A77)),
                  foregroundColor: MaterialStatePropertyAll(
                      const Color.fromARGB(255, 224, 224, 224))),
              icon: Icon(Icons.payment_rounded, size: 20),
              label: Text(
                'Payback',
              ))
        ],
      ),
    );
  }
}
