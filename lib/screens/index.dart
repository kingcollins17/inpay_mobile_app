// ignore_for_file: unused_field, prefer_const_constructors, unused_element, prefer_const_literals_to_create_immutables

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:inpay_app/screens/loans_screen.dart';
import 'package:inpay_app/screens/me_screen.dart';
import 'package:inpay_app/screens/savings_screen.dart';
// import 'package:inpay_app/state/auth_state.dart';

import '../global/auth_state.dart';
import 'home_screen.dart';
// import 'package:path/path.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key, required this.authState});
  final AuthenticationState authState;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  _Destination destination = _Destination.home;
  int previous = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 12, 12, 12),
        body: PageTransitionSwitcher(
          reverse: previous > destination.index,
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return SharedAxisTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child);
          },
          child: [
            HomeScreen(authState: widget.authState),
            SavingsScreen(),
            LoansScreen(),
            MeScreen()
          ][destination.index],
        ),
        bottomNavigationBar: NavigationBar(
            backgroundColor: Color.fromARGB(255, 12, 12, 12),
            elevation: 0,
            height: 75,
            destinations: [
              _DestinationWidget(
                value: _Destination.home,
                groupValue: destination,
                icon: Icons.home_filled,
                onNavigate: (value) {
                  setState(() {
                    previous = destination.index;
                    destination = value;
                  });
                },
                label: 'Home',
              ),
              _DestinationWidget(
                value: _Destination.savings,
                groupValue: destination,
                icon: Icons.payment_rounded,
                onNavigate: (value) {
                  setState(() {
                    previous = destination.index;
                    destination = value;
                  });
                },
                label: 'Savings',
              ),
              _DestinationWidget(
                value: _Destination.loans,
                groupValue: destination,
                icon: Icons.monetization_on_rounded,
                onNavigate: (value) {
                  setState(() {
                    previous = destination.index;
                    destination = value;
                  });
                },
                label: 'Loans',
              ),
              _DestinationWidget(
                value: _Destination.profile,
                groupValue: destination,
                icon: Icons.person_2,
                onNavigate: (value) {
                  setState(() {
                    previous = destination.index;
                    destination = value;
                  });
                },
                label: 'Me',
              )
            ]),
      ),
    );
  }
}

class _DestinationWidget extends StatelessWidget {
  const _DestinationWidget({
    super.key,
    required this.value,
    required this.groupValue,
    required this.icon,
    this.onNavigate,
    required this.label,
  });
  final String label;
  final _Destination value;
  final _Destination groupValue;
  final IconData icon;
  final void Function(_Destination value)? onNavigate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        // radius: 50,
        // overlayColor:
        // MaterialStatePropertyAll(Color.fromARGB(74, 119, 119, 119)),
        // borderRadius: BorderRadius.circular(50),
        onTap: () => onNavigate == null ? null : onNavigate!(value),
        child: AnimatedContainer(
            // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            width: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value == groupValue
                    ? const Color.fromARGB(47, 158, 158, 158)
                    : Colors.transparent),
            duration: const Duration(milliseconds: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: value == groupValue ? 1.2 : 1,
                  child: Icon(
                    icon,
                    size: 24,
                    color: value == groupValue
                        ? Theme.of(context).colorScheme.secondary
                        : Color.fromARGB(255, 167, 167, 167),
                  ),
                ),
                const SizedBox(height: 5),
                Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Quicksand',
                        fontSize: 11))
              ],
            )),
      ),
    );
  }
}

enum _Destination { home, savings, loans, profile }

_Destination _resolveIndex(int currentIndex) => currentIndex == 0
    ? _Destination.home
    : currentIndex == 1
        ? _Destination.savings
        : currentIndex == 2
            ? _Destination.loans
            : currentIndex == 3
                ? _Destination.profile
                : _Destination.home;

int _resolveDestination(_Destination destination) {
  var res = 0;
  switch (destination) {
    case _Destination.home:
      res = 0;
      break;
    case _Destination.savings:
      res = 1;
      break;
    case _Destination.loans:
      res = 2;
      break;
    case _Destination.profile:
      res = 3;
      break;
    default:
      break;
  }
  return res;
}
