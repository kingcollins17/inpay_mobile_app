// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:currency_symbols/currency_symbols.dart';
import 'package:flutter/material.dart';
import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/global/auth_state.dart';
import 'package:inpay_app/global/data_state.dart';
import 'package:inpay_app/handler/access_key.dart';
import 'package:inpay_app/handler/account_handler.dart';
import 'package:inpay_app/util.dart';
import 'package:inpay_app/widgets/loading_indicator.dart';
import 'package:inpay_app/widgets/pop_up.dart';
import 'package:provider/provider.dart';

class AddLoan extends StatefulWidget {
  const AddLoan({super.key, required this.maxAmount});
  final double maxAmount;

  @override
  State<AddLoan> createState() => _AddLoanState();
}

class _AddLoanState extends State<AddLoan> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController();
  Widget? popUpMessage;
  late AnimationController animationController;

  bool isLoading = false;

  //form inputs
  String? loanAmount, description;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    animationController.dispose();
    textController.dispose();
    super.dispose();
  }

  Future<void> showPopUpMessage(
    String message, [
    Duration delay = const Duration(seconds: 3),
  ]) async {
    animationController.duration = const Duration(milliseconds: 200);
    animationController.reset();
    //
    setState(() => popUpMessage =
        PopUpMessage(animation: animationController, message: message));
    //
    await Future.delayed(Duration(milliseconds: 600), () {
      animationController.forward();
    });
    return Future.delayed(delay, () {
      animationController.reverse().then((value) => setState(() {
            // isLoading = false;
            popUpMessage = null;
          }));
    });
  }

  Future<void> applyLoan(
      {required Account account,
      required double amount,
      required AccessKey accessKey}) async {
    await showPopUpMessage('Loan application Processing');
    return AccountHandler.instance
        .requestLoan(account, amount: amount, accessKey: accessKey)
        .then((value) {
      showPopUpMessage(value.message)
          .then((_) => value.status ? Navigator.pop(context) : null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apply for Loan',
          style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none),
        ),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Color(0x0E4489FF), shape: BoxShape.circle),
                padding: EdgeInsets.all(20),
                child: Icon(Icons.account_balance_rounded,
                    color: Colors.blueAccent, size: 50),
              ),
              Text(
                'Inpay Loan application',
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFDADADA),
                    decoration: TextDecoration.none),
              ),
              const SizedBox(height: 50),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loan amount',
                        style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: textController,
                        onChanged: (value) => loanAmount = value,
                        validator: (value) => value == null || value.isEmpty
                            ? "This field is required"
                            : (double.tryParse(value) ?? 0.00) < 50000.00
                                ? "Loan amount cannot be less than ${cSymbol('NGN')}50000.00"
                                : null,
                        onEditingComplete: () {
                          textController.text =
                              '${(double.tryParse(loanAmount ?? '50000.00')?.toInt().toString() ?? 50000)}'
                              '.00';
                          loanAmount = textController.text;
                          //unfocus keyboard
                          FocusScope.of(context).unfocus();
                        },
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                            prefixText: '${cSymbol('NGN')} ',
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText:
                                '50000.00 - ${widget.maxAmount.toInt()}.00'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Description',
                        style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        onChanged: (value) => description = description,
                        validator: (value) => value == null || value.isEmpty
                            ? "Please tell us why you want this loan"
                            : null,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Why are you taking out this loan',
                            hintStyle: TextStyle(fontFamily: 'Quicksand')),
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.center,
                        child: FilledButton(
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                setState(() => isLoading = true);
                                const factor = 100000;
                                var data = Provider.of<DataState>(context,
                                    listen: false);
                                var accessKey =
                                    Provider.of<AuthenticationState>(context,
                                            listen: false)
                                        .accessKey;
                                var totalDebt = calculateTotalDebt(data.loans);
                                var loanLimit =
                                    data.accounts.first.level! * factor;
                                (widget.maxAmount <
                                        double.tryParse(loanAmount!)!)
                                    ? showPopUpMessage('Amount is too big')
                                        .then((value) =>
                                            setState(() => isLoading = false))
                                    : (loanLimit - totalDebt) <
                                            double.tryParse(loanAmount!)!
                                        ? showPopUpMessage(
                                                'Pay up outstanding debts first')
                                            .then((value) => setState(
                                                () => isLoading = false))
                                        : applyLoan(
                                                account: data.accounts.first,
                                                amount: double.tryParse(
                                                    loanAmount!)!,
                                                accessKey: accessKey!)
                                            .then((value) {
                                            setState(() => isLoading = false);
                                          });
                              }
                            },
                            style: ButtonStyle(
                                fixedSize: MaterialStatePropertyAll(Size(
                                    MediaQuery.of(context).size.width * 0.85,
                                    45)),
                                foregroundColor:
                                    MaterialStatePropertyAll(Colors.white),
                                backgroundColor: MaterialStatePropertyAll(
                                    Theme.of(context).colorScheme.secondary)),
                            child: Text(
                              'Apply',
                              style: TextStyle(fontFamily: 'Quicksand'),
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (popUpMessage != null)
          Positioned(
              width: MediaQuery.of(context).size.width,
              top: 30,
              child: Center(
                child: popUpMessage,
              )),
        if (isLoading) LoadingIndicator()
      ]),
    );
  }
}
