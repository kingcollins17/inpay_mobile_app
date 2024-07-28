import 'package:flutter/foundation.dart';
import 'package:inpay_app/handler/access_key.dart';
import 'package:inpay_app/handler/account_handler.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/models.dart' as models;

class DataState with ChangeNotifier, DiagnosticableTreeMixin {
  final handler = AccountHandler.instance;
  List<models.Account> get accounts => handler.accounts;
  List<models.Transaction> get transactions => handler.transactions;
  List<models.Savings> get savings => handler.savings;
  List<models.Loan> get loans => handler.loans;

  Future<bool> unlockSavings(models.Savings savings, AccessKey accessKey,
      {required double interest}) async {
    await handler.depositFunds(accounts[0],
        amount: interest, accessKey: accessKey);
    //
    final unlocked = await handler.unlockSavings(savings, accessKey: accessKey);
    unlocked ? notifyListeners() : null;
    return unlocked;
  }

  List<models.Savings> getSavings(AccessKey accessKey) {
    if (handler.savings.isEmpty) {
      handler
          .refreshSavings(accounts.first, accessKey: accessKey)
          .then((value) => value.isNotEmpty ? notifyListeners() : null);
    }
    return handler.savings;
  }

  Future<Database> database = _initDB();

  DataState() {
    database = _initDB();
  }

  static Future<Database> _initDB() async {
    return openDatabase(join(await getDatabasesPath(), "transactions.db"),
        onCreate: (db, version) {
      db.execute('CREATE TABLE transactions (id INTEGER PRIMARY KEY,'
          'hash TEXT, amount TEXT, senderId TEXT, recipientId TEXT,'
          ' date TEXT, sender TEXT, recipient TEXT)');
    }, version: 1);
  }

  Future<bool> saveToLocalDB(List<models.Transaction> transactions) async {
    final db = await database;
    for (var e in transactions) {
      db.insert('transactions', e.json,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    return true;
  }

  Future<void> clearDB() async {
    final db = await database;
    db.execute("DELETE FROM transactions");
  }

  Future<List<models.Transaction>> fetchFromLocalDB() async {
    final db = await database;
    final result = await db.query('transactions');
    return result.map((e) => models.Transaction.fromDBMap(e)).toList();
  }

  Future<void> refresh(AccessKey accessKey) async {
    await handler.refreshAccounts(accessKey);
    await handler.refreshTransactionHistory(handler.accounts.first,
        outgoing: true, accessKey: accessKey);
    await handler.refreshSavings(accounts.first, accessKey: accessKey);
    await handler.refreshLoans(accounts.first, accessKey: accessKey);
    notifyListeners();
    return;
  }

  Future<void> refreshWith(
      AccessKey accessKey, Future<dynamic> Function() onRefresh) async {
    await onRefresh();
    notifyListeners();
  }

  Future<void> refreshTransactions(AccessKey accessKey) async {
    await handler.refreshTransactionHistory(accounts.first,
        outgoing: true, accessKey: accessKey);
    notifyListeners();
  }

  Future<void> refreshLoans(AccessKey accessKey) async {
    await handler.refreshLoans(accounts.first, accessKey: accessKey);
    notifyListeners();
  }

  Future<void> refreshAccount(AccessKey accessKey) async {
    await handler.refreshAccounts(accessKey);
    notifyListeners();
  }

  Future<void> refreshSavings(AccessKey accessKey) async {
    await handler.refreshSavings(accounts.first, accessKey: accessKey);
    notifyListeners();
  }
}
