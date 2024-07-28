// ignore_for_file: unused_import

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/screens/add_loan.dart';
import 'package:inpay_app/screens/add_savings.dart';
import 'package:inpay_app/screens/history_screen.dart';
import 'package:inpay_app/screens/index.dart';
import 'package:inpay_app/screens/loans_list.dart';
import 'package:inpay_app/screens/status_screen.dart';
import 'package:inpay_app/screens/transfer.dart';
import 'package:provider/provider.dart';
import 'package:inpay_app/screens/test_api_screen.dart';
import 'package:inpay_app/screens/test_handler_screen.dart';
import 'package:inpay_app/screens/auth.dart';
// import 'package:inpay_app/state/auth_state.dart';

import 'global/auth_state.dart';
import 'screens/test_sql.dart';
import 'screens/transaction_receipt.dart';

class InpayRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    Widget page = const SizedBox();
    switch (settings.name) {
      case "/":
        page = Consumer<AuthenticationState>(builder: (context, state, child) {
          return PageTransitionSwitcher(
              duration: const Duration(milliseconds: 600),
              reverse: !state.isAuthenticated,
              transitionBuilder:
                  (child, primaryAnimation, secondaryAnimation) =>
                      SharedAxisTransition(
                          animation: primaryAnimation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.scaled,
                          child: SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: child)),
              child: state.isAuthenticated
                  ? NavigationScreen(authState: state)
                  : AuthenticationScreen(authState: state));
        });
        break;

      case '/auth':
        page = Consumer<AuthenticationState>(builder: (context, state, child) {
          return PageTransitionSwitcher(
              duration: const Duration(milliseconds: 600),
              reverse: !state.isAuthenticated,
              transitionBuilder:
                  (child, primaryAnimation, secondaryAnimation) =>
                      SharedAxisTransition(
                          animation: primaryAnimation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.scaled,
                          child: SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: child)),
              child: state.isAuthenticated
                  ? NavigationScreen(authState: state)
                  : AuthenticationScreen(authState: state));
        });
        break;

      case '/transfer':
        page = const TransferScreen();
        break;

      case '/status':
        page = TransactionStatusScreen(
            transaction: settings.arguments as Transaction);
        break;

      case '/loans':
        page = const LoanListScreen();
        break;

      case '/receipt':
        page = const TransactionReceiptScreen();
        break;

      case '/save':
        page = const AddSavings();
        break;

      case '/history':
        page = const HistoryScreen();
        break;

      case '/test/sql':
        page = const TestSQLStorage();
        break;

      case '/test/api':
        page = const TestScreen();
        break;

      case "/test/handler":
        page = const TestHandlerScreen();
        break;

      default:
        break;
    }
    return MaterialPageRoute(builder: (context) => page, settings: settings);
  }
}
