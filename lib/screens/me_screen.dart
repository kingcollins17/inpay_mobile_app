// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:inpay_app/global/auth_state.dart';
import 'package:inpay_app/global/data_state.dart';
import 'package:inpay_app/screens/account_information.dart';
import 'package:inpay_app/screens/change_password.dart';
import 'package:inpay_app/screens/change_pin.dart';
import 'package:inpay_app/widgets/copy_right.dart';
import 'package:inpay_app/widgets/copy_to_clipboard.dart';
import 'package:provider/provider.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Consumer<DataState>(
        builder: (context, data, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(24, 16, 63, 143),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                      child: Text(
                    data.accounts.first.name[0],
                    style: TextStyle(fontSize: 25, color: Colors.blueAccent),
                  )),
                ),
                const SizedBox(height: 10),
                Text(
                  data.accounts.first.name,
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${data.accounts.first.accountNumber}',
                      style: TextStyle(
                          fontFamily: 'Open sans',
                          fontSize: 14,
                          color: Color(0xFFC9C9C9)),
                    ),
                    const SizedBox(width: 8),
                    CopyToClipboard(
                      data: data.accounts.first.accountNumber!,
                    )
                  ],
                ),
                const SizedBox(height: 30),
                if (child != null) child,
                _SubSection(
                  header: 'Actions',
                  sections: [
                    (
                      icon: Icons.history_toggle_off_rounded,
                      title: 'Transaction History',
                      subtitle: 'View all transaction histories',
                      onTap: () => Navigator.pushNamed(context, '/history',
                          arguments: (data.transactions, data.accounts.first))
                    ),
                    (
                      icon: Icons.book_online_rounded,
                      title: 'Account Information',
                      subtitle: 'Details about your account',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InformationScreen(data: data),
                          ))
                    ),
                  ],
                ),
                _SubSection(header: 'Security', sections: [
                  (
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Change your user login password',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordScreen(),
                        ))
                  ),
                  (
                    icon: Icons.key,
                    title: 'Change Pin',
                    subtitle: 'Change your account pin',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePinScreen(
                            account: data.accounts.first,
                          ),
                        ))
                  ),
                  (
                    icon: Icons.logout_rounded,
                    title: 'Log out',
                    subtitle: 'Log out from our app',
                    onTap: () {
                      showModal<bool>(
                              context: context,
                              builder: (context) => _LogOutConfirmation())
                          .then((value) => value == true
                              ? Provider.of<AuthenticationState>(context,
                                      listen: false)
                                  .logOut()
                              : null);
                    }
                  ),
                ]),
                const SizedBox(height: 10),
                CopyRight(),
                const SizedBox(height: 5)
              ],
            ),
          );
        },
        child: Column(children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                child: _Header(
                  icon: Icons.security_rounded,
                  label: 'Security',
                ),
              ),
              Expanded(
                child: _Header(
                  icon: Icons.person_2_outlined,
                  label: 'Profile',
                ),
              ),
              Expanded(
                  child: _Header(
                      icon: Icons.lock_outline_rounded, label: 'Privacy'))
            ]),
          ),
          const SizedBox(height: 30),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

class _LogOutConfirmation extends StatelessWidget {
  const _LogOutConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: Color(0xFF141414),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to log out?',
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 16,
                      decoration: TextDecoration.none,
                      color: Colors.white,
                      fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FilledButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.secondary),
                          foregroundColor: MaterialStatePropertyAll(
                              const Color.fromARGB(255, 224, 224, 224))),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Yes'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: ButtonStyle(
                            foregroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.secondary)),
                        child: Text('No'))
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubSection extends StatelessWidget {
  const _SubSection({
    super.key,
    required this.header,
    required this.sections,
  });
  final String header;
  final List<_SectionData> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Ink(
          width: MediaQuery.of(context).size.width,
          decoration:
              BoxDecoration(color: const Color.fromARGB(255, 46, 46, 46)),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Text(
            header,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
            ),
          ),
        ),
        ...List.generate(
            sections.length,
            (index) => _PrimarySection(
                  data: sections[index],
                  isLast: index == sections.length - 1,
                )),
      ],
    );
  }
}

typedef _SectionData = ({
  IconData icon,
  String title,
  String subtitle,
  VoidCallback onTap
});

class _PrimarySection extends StatelessWidget {
  const _PrimarySection({
    super.key,
    required this.data,
    this.isLast = false,
  });
  final _SectionData data;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ListTile(
          onTap: data.onTap,
          leading: Icon(data.icon, color: Colors.blueAccent, size: 30),
          trailing: Icon(Icons.arrow_forward_ios_rounded,
              size: 10, color: Colors.grey),
          title: Text(
            data.title,
            style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white),
          ),
          subtitle: Text(
            data.subtitle,
            style: TextStyle(
                fontFamily: 'Quicksand', fontSize: 12, color: Colors.grey),
          ),
          dense: true,
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Divider(color: Color.fromARGB(255, 87, 87, 87)),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 30,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueAccent,
              fontFamily: 'Quicksand',
            ),
          )
        ],
      ),
    );
  }
}
