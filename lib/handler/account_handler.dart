// ignore_for_file: prefer_final_fields, unused_field, unused_import

import 'package:inpay_app/data/models.dart';
import 'package:inpay_app/errors/base.dart';
import 'package:inpay_app/handler/access_key.dart';
import 'package:inpay_app/handler/base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inpay_app/api/accounts.dart' as api;

abstract interface class AccountHandler extends Handler {
  ///The sole instance of this class
  static AccountHandler? _instance;

  AccountHandler() {
    if (_instance != null) {
      throw SingletonError();
    }
    AccountHandler._instance = this;
  }

  ///Returns true if transaction was successful, otherwise false
  @tested
  Future<bool> transferFunds(Transaction transaction,
      {required AccessKey accessKey});

  @tested
  bool get hasKey;

  static AccountHandler get instance {
    return _instance ??= _AccountHandlerImpl();
    // return _instance!;
  }

  @tested
  List<Account> get accounts;

  List<Transaction> get transactions;

  List<Savings> get savings;

  List<Loan> get loans;

  // List<Loan> get loansList;

  @tested
  Future<bool> createAccount(Account account, {required AccessKey accessKey});

  @tested
  List<Loan> loansFor(Account account);

  @tested
  List<Savings> savingsFor(Account account);

  @tested
  Future<Account> depositFunds(Account account,
      {required double amount, required AccessKey accessKey});

  @tested
  Future<Status> requestLoan(Account account,
      {required double amount, required AccessKey accessKey});

  @tested
  Future<bool> paybackLoan(Loan loan, {required AccessKey accessKey});

  @tested
  Future<bool> unlockSavings(Savings savings, {required AccessKey accessKey});

  @tested
  Future<List<Loan>> refreshLoans(Account account,
      {required AccessKey accessKey});

  @tested
  Future<bool> saveFunds(Account account,
      {required double amount,
      required AccessKey accessKey,
      Function(List<Savings>)? onRefreshDone});

  @tested
  Future<List<Savings>> refreshSavings(Account account,
      {required AccessKey accessKey});

  @tested
  Future<List<Transaction>> refreshTransactionHistory(Account account,
      {required bool outgoing, required AccessKey accessKey});

  @tested
  Future<dynamic> refreshAccounts(AccessKey accessKey);
}

/////////////////////////////////////////////////////
//
//
///Default implementation of the AccountHandler class
base class _AccountHandlerImpl extends AccountHandler {
  AccessKey? accessKey;

  var _accounts = <Account>[];
  var _loans = <Loan>[];
  var _savings = <Savings>[];
  var _transactions = <Transaction>[];

  @override
  List<Transaction> get transactions => _transactions;

  @override
  List<Savings> get savings => _savings;

  @override
  List<Loan> get loans => _loans;

  ///Whether this handler has accessKey
  @override
  bool get hasKey => accessKey != null;

  @override
  List<Account> get accounts => _accounts;

  @override
  List<Loan> loansFor(Account account) =>
      _loans.where((element) => element.accountId == account.id).toList();

  @override
  List<Savings> savingsFor(Account account) =>
      _savings.where((element) => element.accountId == account.id).toList();

  @override
  Future<bool> transferFunds(Transaction transaction,
      {required AccessKey accessKey}) async {
    final transferred =
        await api.transferFunds(transaction, accessKey: accessKey.toString());

    return transferred;
  }

  @override
  Future<bool> createAccount(Account account,
      {required AccessKey accessKey}) async {
    final created =
        await api.createAccount(account, accessKey: accessKey.toString());
    (created) ? refreshAccounts(accessKey) : null;
    return created;
  }

  @override
  Future<Account> depositFunds(Account account,
      {required double amount, required AccessKey accessKey}) async {
    final deposited = await api.depositFunds(account,
        amount: amount, accessKey: accessKey.toString());

    ///Creates a new account and adds this amount to previous amount if [deposited]
    return deposited ? (account & amount) : account;
  }

  @override
  Future<Status> requestLoan(Account account,
      {required double amount, required AccessKey accessKey}) async {
    final loaned = await api.requestLoan(account,
        amount: amount, accessKey: accessKey.toString());
    return (
      status: loaned,
      message: loaned ? "Loan approved" : "Not Eligible for this loan"
    );
  }

  @override
  Future<bool> paybackLoan(Loan loan, {required AccessKey accessKey}) async {
    final paid = await api.repayLoan(loan, accessKey: accessKey.toString());
    if (paid) {
      _loans = _loans.where((element) => element.id != loan.id).toList();
    }
    return paid;
  }

  @override
  Future<List<Loan>> refreshLoans(Account account,
      {required AccessKey accessKey}) async {
    _loans = await api.fetchLoans(account, accessKey: accessKey.toString());
    return _loans;
  }

  @override
  Future<bool> unlockSavings(Savings savings,
      {required AccessKey accessKey}) async {
    final unlocked =
        await api.unlockSavedFunds(savings, accessKey: accessKey.toString());
    if (unlocked) {
      _savings.removeWhere((element) => element.id == savings.id);
    }
    return unlocked;
  }

  @override
  Future<bool> saveFunds(Account account,
      {required double amount,
      required AccessKey accessKey,
      Function(List<Savings>)? onRefreshDone}) async {
    final saved = await api.lockSaveFunds(account,
        amount: amount, accessKey: accessKey.toString());
    if (saved) {
      //refresh savings asynchronously
      refreshSavings(account, accessKey: accessKey).then((refreshedSavings) =>
          onRefreshDone != null ? onRefreshDone(refreshedSavings) : null);
    }
    return saved;
  }

  @override
  Future<List<Savings>> refreshSavings(Account account,
      {required AccessKey accessKey}) async {
    _savings =
        await api.fetchSavedFunds(account, accessKey: accessKey.toString());
    return _savings;
  }

  @override
  Future<List<Account>> refreshAccounts(AccessKey accessKey) async {
    _accounts = await api.fetchAccounts(accessKey.toString());
    return accounts;
  }

  @override
  Future<List<Transaction>> refreshTransactionHistory(Account account,
      {required bool outgoing, required AccessKey accessKey}) async {
    _transactions = await api.fetchTransactionHistory(account,
        outgoing: outgoing, accessKey: accessKey.toString());
    return _transactions
      ..addAll(await api.fetchTransactionHistory(account,
          outgoing: !outgoing, accessKey: accessKey.toString()));
  }
}
