// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures, unused_element

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:inpay_app/api/accounts.dart';
import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/handler/access_key.dart';
// import 'package:inpay_app/handler/account_handler.dart';
import 'package:inpay_app/handler/auth_handler.dart';
// import 'package:inpay_app/state/auth_state.dart';
import 'package:provider/provider.dart';

// import '../state/data.dart';
import '../global/auth_state.dart';
import '../global/data_state.dart';
import '../widgets/copy_right.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/shaded_icon.dart';

enum FormType { signIn, signUp }

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key, required this.authState});
  final AuthenticationState authState;

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  var formType = FormType.signIn;
  var isLoading = false;
  String? fullname, email, password;
  bool hidePassword = true;
  String? error;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _handlePress() {
    if (formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final user =
          User(name: fullname ?? '', email: email!, password: password);
      if (formType == FormType.signIn)
        _login(user);
      else {
        _register(user);
      }
    }
  }

  void _login(User user) {
    AuthenticationHandler.instance.login(user).then((value) {
      _authenticate(value);
    });
  }

  void _authenticate(AccessKey? accessKey, {bool signUp = false}) {
    if (accessKey == null) {
      setState(() {
        isLoading = false;
        error =
            "We are unable to ${signUp ? 'sign you up' : 'log you in'} at this moment";
        _animateErrorMessage()
            .then((_) => Future.delayed(const Duration(seconds: 4), () {
                  _controller
                      .reverse()
                      .then((value) => setState(() => error = null));
                }));
      });
    } //else authenticate user
    else
      Provider.of<DataState>(context, listen: false)
          .refresh(accessKey)
          .then((value) {
        setState(() => isLoading = false);
        Future.delayed(const Duration(milliseconds: 600),
            () => widget.authState.authenticate(accessKey));
      });
  }

  Future<dynamic> _animateErrorMessage() {
    return Future.delayed(
        const Duration(milliseconds: 1500), () => _controller.forward());
  }

  void _register(User user) async {
    //try to register user
    if (await AuthenticationHandler.instance.register(user)) {
      final token = await AuthenticationHandler.instance.login(user);
      if (token != null) {
        //create account if login was successful
        createAccount(
                Account(
                  name: user.name,
                  userId: (await token.user)!.id!,
                ),
                accessKey: token.toString())
            .then((value) => value
                ? _authenticate(token)
                : setState(
                    () {
                      //if unable to create an account
                      isLoading = false;
                      error = 'We are unable to create an'
                          ' account for you at this moment';
                      _animateErrorMessage();
                    },
                  ));
        return;
      }
    }
    //else if not [registered]
    setState(() {
      isLoading = false;
      error = 'Something went wrong and we are '
          "unable to register you at the moment";
      _animateErrorMessage();
    });
    // return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 70),
              ShadedIcon(),
              const SizedBox(height: 15),
              Text(
                  formType == FormType.signIn
                      ? 'Sign In to your Inpay Account'
                      : 'Create an Inpay Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Quicksand',
                      color: Color.fromARGB(239, 228, 228, 228),
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Text(
                formType == FormType.signIn
                    ? 'Enter your login details'
                    : 'Fill in your your details',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Colors.grey, fontFamily: 'Quicksand'),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        if (formType == FormType.signUp)
                          TextFormField(
                            enabled: (!isLoading) && (error == null),
                            onChanged: (value) => fullname = value,
                            validator: (value) {
                              return value == null || value.isEmpty
                                  ? "Enter your full name"
                                  : null;
                            },
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                                isDense: true,
                                labelText: 'Fullname',
                                labelStyle: TextStyle(
                                    fontFamily: 'Quicksand', fontSize: 14),
                                hintText: 'eg. Mike Ross',
                                border: OutlineInputBorder()),
                          ),
                        const SizedBox(height: 15),
                        TextFormField(
                          key: ValueKey('$formType emailKey'),
                          enabled: (!isLoading) && (error == null),
                          onChanged: (value) => email = value,
                          validator: (value) {
                            return value == null || value.isEmpty
                                ? "Email is required"
                                : value.contains("@") == false ||
                                        value
                                                .split("@")
                                                .last
                                                .contains(".com") ==
                                            false
                                    ? "Email is not valid"
                                    : null;
                            // : value.split("@").toString()
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 14),
                              hintText: 'mikeross@gmail.com',
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          key: ValueKey('$formType passwordKey'),
                          onChanged: (value) => password = value,
                          enabled: (!isLoading) && (error == null),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: hidePassword,
                          validator: (value) {
                            return value == null || value.isEmpty
                                ? "password is required"
                                : value.length < 8
                                    ? "password cannot be less than 8 characters"
                                    : null;
                          },
                          decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 14),
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                    () => hidePassword = !hidePassword),
                                child: Icon(
                                    hidePassword
                                        ? Icons.visibility_off
                                        : Icons.remove_red_eye_rounded,
                                    color: const Color.fromARGB(
                                        255, 209, 209, 209)),
                              ),
                              hintText: 'Password',
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 45),
                        CustomButton(
                          enabled: (!isLoading) && (error == null),
                          height: 45,
                          label:
                              formType == FormType.signIn ? 'Login' : 'Sign Up',
                          onPress: _handlePress,
                        ),
                        const SizedBox(height: 5),
                        TextButton(
                            onPressed: () {
                              setState(() => isLoading = true);
                              Future.delayed(
                                  const Duration(seconds: 2),
                                  () => setState(() {
                                        isLoading = false;
                                        formType = formType == FormType.signIn
                                            ? FormType.signUp
                                            : FormType.signIn;
                                      }));
                            },
                            child: Text(
                              formType == FormType.signIn
                                  ? "Don't have an account?"
                                  : 'Already have an account?',
                              style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  color: Color.fromARGB(255, 240, 240, 240)),
                            )),
                        const SizedBox(height: 50),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: CopyRight()),
                      ],
                    )),
              )
            ]),
          ),
          if (isLoading) LoadingIndicator(),
          if (error != null)
            Center(
                // child: BackdropFilter(
                // filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: GestureDetector(
              onTap: () => _controller.reverse().then((value) {
                setState(() {
                  error = null;
                });
              }),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeScaleTransition(
                      animation: _controller, child: child);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 200,
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromARGB(255, 20, 20, 20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShadedIcon(
                        icon: Icon(
                          Icons.info_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        error ??
                            "An error has occurred, pls check your details",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color.fromARGB(255, 233, 233, 233),
                            fontFamily: 'Quicksand',
                            fontSize: 16),
                      )
                    ],
                  ),
                ),
              ),
              // ),
            )),
        ],
      ),
    );
  }
}
