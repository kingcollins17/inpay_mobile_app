// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:inpay_app/routes.dart';
// import 'package:inpay_app/state/auth_state.dart';
// import 'package:inpay_app/state/data.dart';
import 'package:inpay_app/theme.dart';
import 'package:provider/provider.dart';

import 'global/auth_state.dart';
import 'global/data_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthenticationState()),
      ChangeNotifierProvider(create: (context) => DataState())
    ],
    child: MaterialApp(
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
      onGenerateRoute: InpayRouter.onGenerateRoute,
      theme: InpayTheme.dark,
    ),
  ));
}
