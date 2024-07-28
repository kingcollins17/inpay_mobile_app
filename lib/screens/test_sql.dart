// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element

import 'package:flutter/material.dart';
// import 'package:inpay_app/state/data.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:inpay_app/widgets/loading_indicator.dart';
import '../data/models.dart' as models;

class TestSQLStorage extends StatefulWidget {
  const TestSQLStorage({super.key});

  @override
  State<TestSQLStorage> createState() => _TestSQLStorageState();
}

class _TestSQLStorageState extends State<TestSQLStorage> {
  String? response;
  bool isLoading = false;
  late final Future<Database> database;

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> _insertTransaction() async {
    final transaction = models.Transaction(
        id: 15,
        amount: 300,
        senderId: 2,
        recipientId: 5,
        hash: "5737dadv436eavfdss7343753929454f",
        sender: 'Pinta',
        recipient: 'Alaskar');
    final db = await database;
    return db.insert('transactions', transaction.json,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<dynamic> _fetchTransactions(Database db) async {
    // final db = await database;
    return db.query('transactions', orderBy: 'senderId');
  }

  Future<dynamic> _clearDB() async {
    final db = await database;
    return db.execute("DELETE FROM transactions");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 20),
                  child: Text(response ?? 'No Response',
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    setState(() => isLoading = true);
                    // var state = Provider.of<DataState>(context, listen: false);
                    // state.clearDB().then((value) => setState(() {
                    //       isLoading = false;
                    //       response = "cleared";
                    //     }));
                    // state.fetchFromLocalDB().then((value) => setState(() {
                    //       try {
                    //         isLoading = false;
                    //         response = value.toString();
                    //       } catch (e) {
                    //         response = e.toString();
                    //       }
                    //     }));

                    // state.database.then((value) {
                    // _fetchTransactions(value).then((value) {
                    //   setState(() {
                    //     try {
                    //       isLoading = false;
                    //       response = value.toString();
                    //     } catch (e) {
                    //       response = e.toString();
                    //     }
                    //   });
                    // });
                    // });

                    // Provider.of<DataState>(context, listen: false)
                    //     .saveToLocalDB([
                    //   models.Transaction(
                    //       id: 11,
                    //       amount: 300,
                    //       senderId: 2,
                    //       recipientId: 5,
                    //       hash: "5737dadv436eavfdss7343753929454f",
                    //       sender: 'Pinta',
                    //       recipient: 'Alaskar'),
                    //   models.Transaction(
                    //       id: 12,
                    //       amount: 300,
                    //       senderId: 2,
                    //       recipientId: 5,
                    //       hash: "5737dadv436eavfdss7343753929454f",
                    //       sender: 'Pinta',
                    //       recipient: 'Alaskar'),
                    //   models.Transaction(
                    //       id: 13,
                    //       amount: 300,
                    //       senderId: 2,
                    //       recipientId: 5,
                    //       hash: "5737dadv436eavfdss7343753929454f",
                    //       sender: 'Pinta',
                    //       recipient: 'Alaskar')
                    // ]).then((value) {
                    //   setState(() {
                    //     response = value.toString();
                    //     isLoading = false;
                    //   });
                    // });
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          const Color.fromARGB(255, 23, 71, 155)),
                      foregroundColor: MaterialStatePropertyAll(Colors.white)),
                  child: Text('Test SQL'),
                )
              ],
            ),
          ),
        ),
        if (isLoading) LoadingIndicator()
      ],
    );
  }
}
