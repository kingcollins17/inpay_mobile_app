// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element, avoid_unnecessary_containers, curly_braces_in_flow_control_structures, no_leading_underscores_for_local_identifiers

import 'package:animations/animations.dart';
import 'package:currency_symbols/currency_symbols.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inpay_app/api/accounts.dart';
import 'package:inpay_app/handler/account_handler.dart';
// import 'package:inpay_app/state/auth_state.dart';
// import 'package:inpay_app/state/data.dart';
import 'package:inpay_app/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../global/auth_state.dart';
import '../global/data_state.dart';
import '../handler/access_key.dart';
import '../util.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  bool isLoading = false;
  final controller = TextEditingController();
  String? accountNumber;
  Account? recipientAccount;
  bool? notFound; //when account is not found
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('Transfer to Inpay wallet',
            style: TextStyle(
                fontSize: 16, color: Colors.white, fontFamily: 'Quicksand')),
      ),
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Text(
                            'Recipient Account',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 230, 230, 230),
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Quicksand',
                                decoration: TextDecoration.none),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 10),
                          child: TextField(
                            controller: controller,
                            maxLength: 10,
                            enabled: !isLoading,
                            onChanged: (value) {
                              accountNumber = value;
                              if (accountNumber!.length >= 10) {
                                setState(() => isLoading = true);
                                findAccount(accountNumber!,
                                        accessKey:
                                            Provider.of<AuthenticationState>(
                                                    context,
                                                    listen: false)
                                                .accessKey!
                                                .toString())
                                    .then((account) {
                                  setState(() {
                                    isLoading = false;
                                    notFound = account == null;
                                    recipientAccount = account;
                                  });
                                });
                              } else {
                                setState(
                                  () {
                                    recipientAccount = null;
                                    notFound = null;
                                  },
                                );
                              }
                            },
                            keyboardType: TextInputType.number,
                            cursorColor:
                                const Color.fromARGB(255, 223, 223, 223),
                            decoration: InputDecoration(
                                // label: Text('account number'),
                                counter: const SizedBox.shrink(),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.greenAccent)),
                                isDense: true),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity:
                                recipientAccount == null && notFound == null
                                    ? 0
                                    : 1,
                            child: _AccountDetail(
                                account: recipientAccount, notFound: notFound),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Material(
                            color: Colors.transparent,
                            child: Center(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: recipientAccount == null
                                    ? null
                                    : () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                          builder: (context) {
                                            return TransferDetailScreen(
                                                recipientAccount:
                                                    recipientAccount!);
                                          },
                                        ));
                                      },
                                overlayColor:
                                    MaterialStatePropertyAll(Colors.blueAccent),
                                child: Ink(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: recipientAccount != null
                                          ? const Color.fromARGB(
                                              255, 6, 67, 172)
                                          : Color.fromARGB(255, 63, 63, 63)),
                                  child: Text(
                                    'Next',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ))
                      ]),
                  const SizedBox(height: 20),
                  Align(
                    child: Consumer<DataState>(
                      builder: (context, data, child) => _RecentTransactions(
                          transactions: recents(
                              data.transactions, data.accounts.first.id!)),
                    ),
                  )
                ],
              ),
            ),
          ),
          if (isLoading) LoadingIndicator()
        ],
      ),
    );
  }
}

List<Transaction> recents(List<Transaction> collection, int accountId) {
  final res = <Transaction>[];
  Set<String> _set = {};
  //
  for (var element
      in collection.where((e) => e.senderId == accountId).toList()) {
    if (_set.add(element.recipient!)) {
      res.add(element);
    }
  }
  return res..sort((a, b) => b.date!.compareTo(a.date!));
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({super.key, required this.transactions});
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recents',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Quicksand'),
            ),
            const SizedBox(height: 20),
            ...List.generate(
                transactions.length > 10 ? 10 : transactions.length, (index) {
              final e = transactions[index];
              return ListTile(
                dense: true,
                leading: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.blueAccent, shape: BoxShape.circle),
                  child: Text(transactions[index].recipient![0]),
                ),
                title: Text(transactions[index].recipient!),
                subtitle: Text(
                  '${e.date!.day} ${parseMonth(e.date!.month)}, ${e.date!.year} ',
                  style: TextStyle(fontSize: 12, fontFamily: 'Quicksand'),
                ),
                trailing:
                    Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
              );
            }),
            const SizedBox(height: 10)
          ],
        ),
      ),
    ));
  }
}

class _AccountDetail extends StatelessWidget {
  const _AccountDetail({
    // super.key,
    this.account,
    this.notFound,
  });

  final Account? account;
  final bool? notFound;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: notFound == true
            ? Color.fromARGB(26, 219, 39, 39)
            : Color.fromARGB(31, 23, 194, 111),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            notFound == true
                ? 'Account not found'
                : account?.name ?? 'Account not found',
            style: TextStyle(
                color: notFound == true ? Colors.redAccent : Colors.greenAccent,
                fontFamily: 'Quicksand',
                fontSize: 14),
          ),
          Icon(
            notFound == true
                ? Icons.close_rounded
                : Icons.check_circle_outline_rounded,
            size: 20,
            color: notFound == true
                ? const Color.fromARGB(255, 211, 8, 8)
                : Colors.greenAccent,
          )
        ],
      ),
    );
  }
}

class TransferDetailScreen extends StatefulWidget {
  const TransferDetailScreen({super.key, required this.recipientAccount});

  final Account recipientAccount;

  @override
  State<TransferDetailScreen> createState() => _TransferDetailScreenState();
}

class _TransferDetailScreenState extends State<TransferDetailScreen>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  String? amount, description;
  bool isLoading = false;
  String? error;
  //
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    // _animationController.duration = Duration(seconds: 4);
  }

  void _animateErrorMessage(String message, [int seconds = 5]) {
    setState(() {
      error = message;
      isLoading = false;
    });
    _animationController.duration = const Duration(milliseconds: 300);
    _animationController
        .forward()
        .then((value) => Future.delayed(Duration(seconds: seconds), () {
              _animationController.reverse().then((value) => _resetState());
            }));
  }

  @override
  Widget build(BuildContext context) {
    //animations
    final slide = Tween(begin: Offset(0, 50), end: Offset.zero).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.decelerate));
    final scale =
        Tween<double>(begin: 0.90, end: 1).animate(_animationController);
    final opacity = Tween<double>(begin: 0.0, end: 1).animate(CurvedAnimation(
        parent: _animationController, curve: Interval(0.5, 1.0)));
    //
    return Stack(
      children: [
        Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
              title: Text('Transfer to ${widget.recipientAccount.name}',
                  style: Theme.of(context).textTheme.bodyMedium)),
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                const SizedBox(height: 30),
                Ink(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(38, 2, 172, 90),
                        shape: BoxShape.circle),
                    child: Icon(Icons.account_balance,
                        color: Colors.greenAccent, size: 25)),
                const SizedBox(height: 15),
                Text(
                  widget.recipientAccount.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 5),
                Text('Inpay wallet (${widget.recipientAccount.accountNumber})',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 30),
                Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Amount',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _controller,
                              onChanged: (value) => amount = value,
                              validator: (value) {
                                return value == null || value.isEmpty
                                    ? "Amount is required"
                                    : double.parse(value) < 100.00
                                        ? "Amount cannot be less than ${cSymbol('NGN')}100.00"
                                        : value.contains(",")
                                            ? "Remove any ',' or '-' "
                                            : null;
                              },
                              onEditingComplete: () {
                                _controller.text =
                                    '${amount == null || amount!.isEmpty ? 0 : double.tryParse(amount!)?.toInt() ?? 0}.00';

                                FocusScope.of(context).unfocus();
                              },
                              enabled: (!isLoading) && (error == null),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true, signed: false),
                              decoration: InputDecoration(
                                  prefix: Text('${cSymbol('NGN')} ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.greenAccent))),
                            ),
                            const SizedBox(height: 10),
                            Text('Description',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 10),
                            TextFormField(
                              enabled: (!isLoading) && (error == null),
                              validator: (value) {
                                return value == null || value.isEmpty
                                    ? "Description is required"
                                    : value.contains("crypto")
                                        ? "Remove the word 'Crypto'"
                                        : null;
                              },
                              onChanged: (value) => description = value,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  hintText: "What is this for?",
                                  hintStyle:
                                      Theme.of(context).textTheme.bodySmall,
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.greenAccent)),
                                  isDense: true),
                            ),
                            const SizedBox(height: 25),
                            Consumer2<AuthenticationState, DataState>(
                              builder:
                                  (context, authState, accountState, child) =>
                                      Center(
                                child: InkWell(
                                  onTap: () {
                                    _processTransfer(
                                        dataState: accountState,
                                        accessKey: authState.accessKey!);
                                  },
                                  // onTap: () => _animateErrorMessage(
                                  //     "Unable to transfer funds"),
                                  borderRadius: BorderRadius.circular(30),
                                  overlayColor: MaterialStatePropertyAll(
                                      const Color.fromARGB(255, 25, 122, 76)),
                                  child: Ink(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 15),
                                    decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 18, 148, 85),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Text('Transfer',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium),
                                  ),
                                ),
                              ),
                            )
                          ]),
                    ))
              ]),
            ),
          ),
        ),
        if (isLoading) LoadingIndicator(),
        if (error != null)
          Positioned(
            top: 50,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: slide.value,
                      child: Transform.scale(
                        scale: scale.value,
                        child: Opacity(
                          opacity: opacity.value,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 20),
                              decoration:
                                  BoxDecoration(color: Color(0xFF272727)),
                              child: Text(error!,
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium)),
                        ),
                      ),
                    );
                  }),
            ),
          ),
      ],
    );
  }

  ///Processes the transaction
  void _processTransfer(
      {required DataState dataState, required AccessKey accessKey}) {
    if (formKey.currentState?.validate() ?? false) {
      showModal<Transaction?>(
          // showDragHandle: true,
          context: context,
          builder: (context) {
            return SingleChildScrollView(
              child: ConfirmTransfer(
                sender: dataState.accounts[0],
                recipient: widget.recipientAccount,
                amount: double.tryParse(amount!) ?? 0.00,
              ),
            );
          }).then((transaction) {
        setState(() => isLoading = transaction != null);
        if (transaction != null) {
          AccountHandler.instance
              .transferFunds(transaction, accessKey: accessKey)
              .then((transfered) {
            if (transfered) {
              setState(() => isLoading = false);
              Navigator.popAndPushNamed(
                context,
                "/status",
                arguments: transaction
                  ..recipient = widget.recipientAccount.name
                  ..sender = dataState.accounts[0].name,
              );
            } else
              Future.delayed(const Duration(milliseconds: 1500), () {
                _animateErrorMessage('An error occurred while '
                    'transfering funds to ${widget.recipientAccount.name}');
              });
          });
        }
      });
    }
  }

  void _resetState() => setState(() {
        isLoading = false;
        error = null;
      });
}

class ConfirmTransfer extends StatefulWidget {
  const ConfirmTransfer(
      {super.key,
      required this.sender,
      required this.recipient,
      required this.amount});

  final Account sender, recipient;
  final double amount;

  @override
  State<ConfirmTransfer> createState() => _ConfirmTransferState();
}

class _ConfirmTransferState extends State<ConfirmTransfer> {
  String? pin;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.95,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            const SizedBox(height: 15),
            Text(
              NumberFormat.currency(locale: 'en_us', symbol: cSymbol('NGN'))
                  .format(widget.amount),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 30,
                fontFamily: 'Open sans',
                color: const Color.fromARGB(255, 223, 223, 223),
              ),
            ),
            const SizedBox(height: 35),
            _Tile(tileKey: 'Bank', value: Text('Inpay Wallet')),
            _Tile(
              tileKey: 'Account Number',
              value: Text(widget.recipient.accountNumber ?? 'Null'),
            ),
            _Tile(tileKey: 'Receiver', value: Text(widget.recipient.name)),
            _Tile(
                tileKey: 'Amount',
                value: Text(NumberFormat.currency(
                        locale: 'en_us', symbol: cSymbol('NGN'))
                    .format(widget.amount))),

            _Tile(
                tileKey: 'Transaction fee',
                value: Text('${cSymbol("NGN")}0.00')),
            const SizedBox(height: 20),
            SizedBox(
              height: 55,
              width: 100,
              child: Center(
                child: TextField(
                  onChanged: (value) => pin = value,
                  textAlign: TextAlign.center,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      counter: const SizedBox.shrink(),
                      labelText: 'Enter Pin',
                      labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 202, 202, 202)),
                      // isDense: true,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.greenAccent))),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: (widget.amount > widget.sender.balance!)
                      ? Color.fromARGB(24, 244, 67, 54)
                      : Color.fromARGB(33, 57, 197, 57)),
              child: Row(children: [
                Icon(Icons.credit_card,
                    color: (widget.amount > widget.sender.balance!)
                        ? Colors.red
                        : Colors.greenAccent),
                const SizedBox(width: 15),
                Text('Balance (${cSymbol("NGN")} ${widget.sender.balance})')
              ]),
            ),
            Expanded(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _Button(
                      label: 'Pay',
                      onPress: () {
                        Navigator.pop(
                            context,
                            Transaction(
                                senderId: widget.sender.id,
                                recipientId: widget.recipient.id,
                                amount: widget.amount));
                      },
                      enabled: pin != null &&
                          pin == widget.sender.pin.toString() &&
                          widget.amount < widget.sender.balance!)),
            ),
            const SizedBox(height: 20),
            // const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    super.key,
    required this.label,
    this.onPress,
    this.enabled = true,
  });

  final VoidCallback? onPress;
  final bool enabled;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onPress : null,
      borderRadius: BorderRadius.circular(30),
      overlayColor:
          MaterialStatePropertyAll(const Color.fromARGB(255, 25, 122, 76)),
      child: Ink(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
            color: enabled
                ? const Color.fromARGB(255, 18, 148, 85)
                : Color.fromARGB(85, 61, 61, 61),
            borderRadius: BorderRadius.circular(30)),
        child: Text('Pay',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.tileKey, required this.value});
  final String tileKey;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tileKey, style: Theme.of(context).textTheme.bodySmall),
          value,
        ],
      ),
    );
  }
}
