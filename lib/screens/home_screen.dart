// ignore_for_file: unused_field, prefer_const_constructors, unused_element, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:inpay_app/global/auth_state.dart';
import 'package:inpay_app/global/data_state.dart';
import 'package:inpay_app/util.dart';
import 'package:provider/provider.dart';

import '../widgets/balance_dashboard.dart';
import '../widgets/copy_right.dart';
import '../widgets/transaction_histories.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authState,
  });

  final AuthenticationState authState;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentAccountIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Material(
          color: Colors.transparent,
          child: Column(children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
              child: Row(
                children: [
                  Ink(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(40, 54, 117, 226),
                    ),
                    child: Text(
                      widget.authState.user?.name[0].toUpperCase() ?? 'U',
                      style: TextStyle(fontSize: 24, color: Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    'Hi, ${widget.authState.user?.name.split(" ")[0] ?? "Stranger"}',
                    style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 18,
                        color: Color(0xFFCCCCCC)),
                  )
                ],
              ),
            ),
            Consumer<DataState>(
              builder: (context, state, child) => state.accounts.isEmpty
                  ? SizedBox.shrink()
                  : SizedBox(
                      height: 150,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.accounts.length,
                        itemBuilder: (BuildContext context, int index) =>
                            BalanceDashboard(
                          account: state.accounts[index],
                          onRefresh: () =>
                              state.refresh(widget.authState.accessKey!),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const SizedBox(width: 15),
                _Action(
                  label: 'Transfer',
                  onPress: () => Navigator.pushNamed(context, "/transfer"),
                  iconBackgroundColor: Color.fromARGB(99, 228, 31, 17),
                  icon: Icons.arrow_upward_rounded,
                ),
                const SizedBox(width: 5),
                _Action(
                  label: 'Deposit',
                  onPress: () => showSnackBar(
                      'This is a simulation, do not deposit actual funds',
                      context),
                  iconBackgroundColor: Color.fromARGB(101, 6, 226, 120),
                  icon: Icons.arrow_downward_rounded,
                ),
                const SizedBox(width: 15),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text('Quick Shortcuts',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Shortcut(
                  label: 'Airtime',
                  iconColor: Colors.yellowAccent,
                  backgroundColor: Color.fromARGB(29, 255, 255, 0),
                  icon: Icons.phone,
                  onPress: () =>
                      showSnackBar('Airtime feature is coming soon', context),
                ),
                _Shortcut(
                  label: 'Internet',
                  iconColor: Color(0xFFE040FB),
                  backgroundColor: Color(0x2CBF08DF),
                  icon: Icons.wifi,
                  onPress: () => showSnackBar(
                      'Consider buying internet from your bank app', context),
                ),
                _Shortcut(
                  label: 'Tv',
                  iconColor: Colors.redAccent,
                  backgroundColor: const Color.fromARGB(26, 255, 82, 82),
                  icon: Icons.tv_rounded,
                  onPress: () =>
                      showSnackBar('Tv subscriptions is coming soon', context),
                ),
                _Shortcut(
                  label: 'Electricity',
                  iconColor: Colors.greenAccent,
                  backgroundColor: const Color.fromARGB(31, 105, 240, 175),
                  icon: Icons.power,
                  onPress: () => showSnackBar(
                      'Likewise, this is also coming soon', context),
                )
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        final data =
                            Provider.of<DataState>(context, listen: false);
                        Navigator.pushNamed(context, '/history', arguments: (
                          data.transactions,
                          data.accounts.first
                        ));
                      },
                      child: Row(
                        children: [
                          Text('View all  ',
                              style: Theme.of(context).textTheme.bodySmall),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 8, color: Colors.grey)
                        ],
                      ))
                ],
              ),
            ),
            const SizedBox(height: 10),
            Consumer<DataState>(
              builder: (context, state, child) => state.transactions.isEmpty
                  ? SizedBox()
                  : TransactionHistories(
                      transactions: state.transactions,
                      account: state.accounts[currentAccountIndex],
                    ),
            ),
            const SizedBox(height: 20),
            CopyRight(),
            const SizedBox(height: 10)
          ]),
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    super.key,
    this.onPress,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
    required this.icon,
  });
  final VoidCallback? onPress;
  final String label;
  final IconData icon;
  final Color iconColor, backgroundColor;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: onPress,
            child: Ink(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Quicksand',
                  color: const Color.fromARGB(255, 202, 202, 202),
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none))
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    super.key,
    required this.label,
    required this.onPress,
    required this.icon,
    required this.iconBackgroundColor,
  });
  final String label;
  final VoidCallback onPress;
  final IconData icon;
  final Color iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onPress,
        overlayColor:
            MaterialStatePropertyAll(const Color.fromARGB(255, 34, 34, 34)),
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 24, 24, 24),
              borderRadius: BorderRadius.circular(5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBackgroundColor,
                ),
                child: Icon(
                  icon,
                  color: const Color.fromARGB(255, 194, 194, 194),
                  size: 15,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Quicksand',
                  color: const Color.fromARGB(255, 204, 204, 204),
                  decoration: TextDecoration.none,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
