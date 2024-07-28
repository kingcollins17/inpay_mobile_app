// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element, unused_field

import 'package:currency_symbols/currency_symbols.dart';
import 'package:flutter/material.dart';
import 'package:inpay_app/global/auth_state.dart';
import 'package:inpay_app/global/data_state.dart';
import 'package:inpay_app/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../widgets/pop_up.dart';

class AddSavings extends StatefulWidget {
  const AddSavings({super.key});

  @override
  State<AddSavings> createState() => _AddSavingsState();
}

class _AddSavingsState extends State<AddSavings>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  String? amount;
  bool isLoading = false;
  bool? isSuccessful;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _animatePopUp({Duration duration = const Duration(milliseconds: 320)}) {
    _animationController.duration = duration;
    _animationController.reset();
    _animationController.forward().then((value) => Future.delayed(
        const Duration(seconds: 3),
        () => _animationController.reverse().then((value) => setState(
              () {
                isLoading = false;
                isSuccessful = null;
              },
            ))));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
              title: Text(
            'Add to InSavings',
            style: TextStyle(fontFamily: 'Quicksand', fontSize: 18),
          )),
          body: Column(
            children: [
              const SizedBox(height: 20),
              Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 10),
                      //   child: Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text('Amount',
                      //         style: Theme.of(context).textTheme.bodyMedium),
                      //   ),
                      // ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: TextFormField(
                          controller: _textController,
                          onChanged: (value) {
                            amount = value;
                          },
                          onEditingComplete: () {
                            _textController.text =
                                '${double.tryParse(amount ?? "0.0")?.toInt() ?? "0"}.00';
                            //unfocus keyboard from textinput
                            FocusScope.of(context).unfocus();
                          },
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          enabled: !isLoading,
                          validator: (value) {
                            return value == null || value.isEmpty
                                ? "Amount is required!"
                                : (double.tryParse(value) ?? 0.0) < 5000.0
                                    ? "You cannot save less than ${cSymbol('NGN')}5000.00"
                                    : null;
                          },
                          decoration: InputDecoration(
                            prefixText: '${cSymbol("NGN")} ',
                            labelText: 'Amount',
                            hintText: "5000.00 - 1000000.00",
                            labelStyle: TextStyle(fontFamily: 'Quicksand'),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  )),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: FilledButton.icon(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Theme.of(context).colorScheme.secondary),
                        foregroundColor: MaterialStatePropertyAll(
                            Color.fromARGB(255, 211, 211, 211)),
                        fixedSize: MaterialStatePropertyAll(
                            Size(MediaQuery.of(context).size.width * 0.8, 50))),
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        setState(() => isLoading = true);
                        final accessKey = Provider.of<AuthenticationState>(
                                context,
                                listen: false)
                            .accessKey;
                        final data =
                            Provider.of<DataState>(context, listen: false);
                        if (accessKey != null) {
                          data.handler
                              .saveFunds(data.accounts.first,
                                  amount: double.parse(amount!),
                                  accessKey: accessKey)
                              .then((saved) {
                            Future.delayed(
                                Duration(seconds: 2),
                                () => setState(() {
                                      isLoading = false;
                                      isSuccessful = saved;
                                      _animatePopUp();
                                    }));
                          });
                        }
                      }
                    },
                    icon: Icon(Icons.lock_outline_rounded),
                    label: Text(
                      'Lock',
                      style: TextStyle(fontFamily: 'Quicksand', fontSize: 16),
                    )),
              )),
              const SizedBox(height: 15)
            ],
          ),
        ),
        if (isSuccessful != null)
          Positioned(
            width: MediaQuery.of(context).size.width,
            bottom: 80,
            child: Center(
              child: PopUpMessage(
                  animation: _animationController,
                  message: isSuccessful == true
                      ? "${cSymbol('NGN')}$amount added to your InSavings"
                      : "Unable to save ${cSymbol('NGN')}$amount at this time"),
            ),
          ),
        if (isLoading) LoadingIndicator()
      ],
    );
  }
}
