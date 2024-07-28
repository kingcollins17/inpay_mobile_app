// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/global/auth_state.dart';
import 'package:inpay_app/handler/admin_handler.dart';
import 'package:inpay_app/widgets/loading_indicator.dart';
import 'package:inpay_app/widgets/pop_up.dart';
import 'package:provider/provider.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key, required this.account});
  final Account account;

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final textController = TextEditingController();

  // final formKey = GlobalKey<FormState>();
  //
  _Step previous = _Step.oldPin, step = _Step.oldPin;
  bool isLoading = false;
  Widget? popUp;
  //
  String? oldPin, newPin, confirmPin;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void process() {
    switch (step) {
      case _Step.oldPin:
        processOldPin();
        break;

      case _Step.newPin:
        processNewPin();
        break;

      case _Step.confirmPin:
        processConfirmation();
        break;
      default:
    }
  }

  void processOldPin() {
    if (oldPin != null && oldPin!.isNotEmpty) {
      setState(() => isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        (int.tryParse(oldPin!) ?? 1) == widget.account.pin
            ? advanceStep()
            : animatePopUp('Your Old Pin is incorrect')
                .then((value) => setState(() => isLoading = false));
      });
    }
  }

  void processNewPin() {
    if (newPin != null && newPin!.isNotEmpty) {
      setState(() => isLoading = true);
      Future.delayed(Duration(seconds: 1), () {
        newPin!.length != 4
            ? animatePopUp('Pin "$newPin" must be 4 digits')
                .then((value) => setState(() => isLoading = false))
            : advanceStep();
      });
    }
  }

  void processConfirmation() {
    confirmPin ??= textController.text;
    if (confirmPin != null && confirmPin!.isNotEmpty) {
      setState(() => isLoading = true);
      Future.delayed(Duration(seconds: 1), () {
        confirmPin!.length != 4
            ? animatePopUp('Pin must be 4 digits')
                .then((value) => setState(() => isLoading = false))
            : confirmPin != newPin
                ? animatePopUp('Pin does not match')
                    .then((value) => setState(() => isLoading = false))
                : AdminHandler.instance
                    .changePin(widget.account,
                        newPin: int.parse(confirmPin!),
                        accessKey: Provider.of<AuthenticationState>(context,
                                listen: false)
                            .accessKey!)
                    .then((value) => value
                        ? animatePopUp('Pin Changed successfully',
                                Duration(seconds: 1))
                            .then((value) => animatePopUp('Please login again'))
                            .then((value) => Navigator.pop(context, true))
                        : animatePopUp('Oops, something went wrong!').then(
                            (value) => setState(() => isLoading = false)));
      });
    }
  }

  Future<void> animatePopUp(String message,
      [Duration delay = const Duration(seconds: 4)]) async {
    _controller.duration = const Duration(milliseconds: 200);
    setState(
        () => popUp = PopUpMessage(animation: _controller, message: message));
    //reset the controller
    _controller.reset();
    await _controller.forward();

    //a delay before animation is reversed
    return Future.delayed(delay, () {
      _controller.reverse().then((value) => setState(() => popUp = null));
    });
  }

  void advanceStep() {
    setState(() {
      isLoading = false;
      previous = step;
      previous == _Step.newPin ? null : textController.clear();
      step = step == _Step.oldPin
          ? _Step.newPin
          : step == _Step.newPin
              ? _Step.confirmPin
              : step;
    });
  }

  void retractStep() {
    setState(() {
      textController.clear();
      oldPin = null;
      newPin = null;
      confirmPin = null;
      previous = step;
      step = step == _Step.confirmPin
          ? _Step.newPin
          : step == _Step.newPin
              ? _Step.oldPin
              : step;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              'Change Pin',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Quicksand',
              ),
            ),
          ),
          body: Column(
            // mainAxisAlignment: M,
            children: [
              const SizedBox(height: 20),
              PageTransitionSwitcher(
                duration: const Duration(milliseconds: 900),
                reverse: previous.index > step.index,
                transitionBuilder: (child, animation, secondaryAnimation) {
                  return SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      child: child);
                },
                child: Column(
                  key: ValueKey('$step key'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10),
                      child: TextField(
                        controller: textController,
                        enabled: (!isLoading) && (popUp == null),
                        onChanged: _onTextChanged,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          counter: SizedBox(),
                          labelText: step == _Step.oldPin
                              ? 'Old Pin'
                              : step == _Step.newPin
                                  ? 'New Pin'
                                  : 'Confirm Pin',
                          labelStyle:
                              TextStyle(fontSize: 14, fontFamily: 'Quicksand'),
                          suffixIcon: Icon(Icons.key, color: Colors.blueAccent),
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
            bottom: 15,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    step == _Step.oldPin
                        ? SizedBox()
                        : ElevatedButton.icon(
                            style: ButtonStyle(
                                foregroundColor: MaterialStatePropertyAll(
                                    Colors.blueAccent)),
                            onPressed: () {
                              retractStep();
                            },
                            icon: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 20),
                            label: Text(
                              'Previous',
                              style: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 16),
                            )),
                    FilledButton(
                      onPressed: () {
                        process();
                      },
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStatePropertyAll(Colors.white),
                          backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.secondary)),
                      child: Text(
                        step == _Step.confirmPin ? 'Confirm' : 'Next',
                        style: TextStyle(fontFamily: 'Quicksand', fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            )),
        if (isLoading) LoadingIndicator(),
        if (popUp != null)
          Positioned(
              bottom: 70,
              width: MediaQuery.of(context).size.width,
              child: Center(child: popUp))
      ],
    );
  }

  void _onTextChanged(String value) {
    switch (step) {
      case _Step.oldPin:
        oldPin = value;
        break;
      case _Step.newPin:
        newPin = value;
        break;
      case _Step.confirmPin:
        confirmPin = value;
        break;
      default:
        break;
    }
  }
}

enum _Step {
  oldPin,
  newPin,
  confirmPin,
}
