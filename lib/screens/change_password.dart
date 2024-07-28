// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:inpay_app/global/auth_state.dart';
import 'package:inpay_app/handler/admin_handler.dart';
import 'package:inpay_app/widgets/loading_indicator.dart';
import 'package:inpay_app/widgets/pop_up.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final formKey = GlobalKey<FormState>();
  //
  var isLoading = false;
  Widget? popUp;

  String? newPassword, confirmPassword;
  bool obscureText = false;

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

  void handleSubmit() {
    setState(() => isLoading = true);
    AdminHandler.instance
        .changePassword(newPassword!,
            accessKey: Provider.of<AuthenticationState>(context, listen: false)
                .accessKey!)
        .then((changed) {
      setState(() => isLoading = false);
      showPopup(changed
              ? "Password changed successfully"
              : "Unable to change password")
          .then((value) => Navigator.pop(context, changed));
    });
  }

  Future<void> showPopup(String message,
      [Duration delay = const Duration(seconds: 4)]) async {
    _controller.duration = const Duration(milliseconds: 200);
    _controller.reset();

    setState(
        () => popUp = PopUpMessage(animation: _controller, message: message));

    await _controller.forward();
    return Future.delayed(delay, () {
      _controller.reverse().then((value) => setState(() => popUp = null));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              'Change Password',
              style: TextStyle(fontSize: 16, fontFamily: 'Quicksand'),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 25),
                Text(
                  'Reset your Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Enter you old and new pasword to reset your password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Quicksand',
                        color: Colors.grey,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          TextFormField(
                            enabled: (!isLoading) && (popUp == null),
                            obscureText: obscureText,
                            validator: (value) => value == null || value.isEmpty
                                ? "Please enter your old password"
                                : null,
                            decoration: InputDecoration(
                              isDense: true,
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                              suffixIcon: GestureDetector(
                                onTap: () =>
                                    setState(() => obscureText = !obscureText),
                                child: Icon(obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                              labelText: 'Old Password',
                              labelStyle: TextStyle(
                                  fontSize: 14, fontFamily: 'Quicksand'),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            enabled: (!isLoading) && (popUp == null),
                            obscureText: obscureText,
                            onChanged: (value) => newPassword = value,
                            validator: (value) => value == null || value.isEmpty
                                ? "Please enter a new password here"
                                : value.length < 8
                                    ? "Password cannot be less than 8 characters"
                                    : null,
                            decoration: InputDecoration(
                              isDense: true,
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                              suffixIcon: GestureDetector(
                                onTap: () =>
                                    setState(() => obscureText = !obscureText),
                                child: Icon(obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                              labelText: 'New Password',
                              labelStyle: TextStyle(
                                  fontSize: 14, fontFamily: 'Quicksand'),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            enabled: (!isLoading) && (popUp == null),
                            obscureText: obscureText,
                            onChanged: (value) => confirmPassword = value,
                            validator: (value) => value == null || value.isEmpty
                                ? "Please retype password here"
                                : value != newPassword
                                    ? "Passwords do not match"
                                    : null,
                            decoration: InputDecoration(
                              isDense: true,
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                              suffixIcon: GestureDetector(
                                onTap: () =>
                                    setState(() => obscureText = !obscureText),
                                child: Icon(obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                              labelText: 'Confirm Password',
                              labelStyle: TextStyle(
                                  fontSize: 14, fontFamily: 'Quicksand'),
                              border: OutlineInputBorder(),
                            ),
                          )
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ),
        Positioned(
            bottom: 20,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: FilledButton(
                  onPressed: () {
                    // showPopup('Hi');
                    if (formKey.currentState?.validate() ?? false) {
                      handleSubmit();
                    }
                  },
                  style: ButtonStyle(
                      fixedSize: MaterialStatePropertyAll(
                          Size(MediaQuery.of(context).size.width * 0.85, 45)),
                      backgroundColor: MaterialStatePropertyAll(
                          Theme.of(context).colorScheme.secondary),
                      foregroundColor:
                          MaterialStatePropertyAll(Color(0xFFDDDDDD))),
                  child: Text(
                    'Reset password',
                    style: TextStyle(fontSize: 16, fontFamily: 'Quicksand'),
                  )),
            )),
        if (isLoading) LoadingIndicator(),
        if (popUp != null)
          Positioned(
            bottom: 80,
            width: MediaQuery.of(context).size.width,
            child: Center(child: popUp),
          )
        // Positioned(child: FilledButton)
      ],
    );
  }
}
