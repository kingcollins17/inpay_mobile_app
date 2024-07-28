///
class User {
  final int? id;
  final String name, email;
  final String? password;
  User({this.id, required this.name, required this.email, this.password});

  Map<String, dynamic> get json =>
      {'id': id, 'name': name, 'email': email, 'password': password};

  Map<String, String> get registerMap =>
      {'name': name, "email": email, "password": password!};
  Map<String, String> get loginMap => {"email": email, "password": password!};

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json["id"], name: json["name"], email: json["email"]);
  }

  @override
  String toString() {
    return 'User <$json>';
  }

  bool equals(User other) => id == other.id && email == other.email;
}

class Account {
  final int? id, pin;
  final String name;
  final String? accountNumber;
  final double? balance, level;
  final int userId;

  bool operator >(Account other) => (balance ?? 0) > (other.balance ?? 0);

  Account operator &(double amount) {
    return Account(
        name: name,
        userId: userId,
        pin: pin,
        accountNumber: accountNumber,
        level: level,
        balance: (balance ?? 0) + amount,
        id: id);
  }

  Account(
      {this.id,
      required this.name,
      this.accountNumber,
      this.balance = 10.5,
      this.level = 0.000005,
      this.pin = 1234,
      required this.userId});

  bool equals(Account other) =>
      id == other.pin &&
      accountNumber == other.accountNumber &&
      userId == other.userId;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        id: json["id"],
        name: json["name"],
        accountNumber: json['account_no'],
        balance: json["balance"],
        pin: json["pin"],
        level: json["level"],
        userId: json["user_id"]);
  }
  Map<String, dynamic> get json => {
        'id': id,
        'name': name,
        'accountNumber': accountNumber,
        'balance': balance,
        'level': level,
        'pin': pin,
        'userId': userId
      };

  @override
  String toString() {
    return 'Account<$json>';
  }

  static fromList(List<dynamic> jsonList) {
    return List.generate(
        jsonList.length, (index) => Account.fromJson(jsonList[index]));
  }
}

class Transaction {
  final int? id;
  final String? hash;
  final double amount;
  final int? senderId, recipientId;
  final DateTime? date;

  ///Extra meta data that is included during history fetch
  String? sender, recipient;

  bool equals(Transaction other) =>
      id == other.id && date == other.date && hash == other.hash;

  Transaction(
      {required this.senderId,
      required this.recipientId,
      required this.amount,
      this.id,
      this.hash,
      this.date,
      this.sender,
      this.recipient});

  Map<String, dynamic> get transferMap =>
      {'amount': amount, 'sender_id': senderId, 'recipient_id': recipientId};

  factory Transaction.fromHistoryJson(Map<String, dynamic> json,
      {required bool outgoing, required Account account}) {
    return Transaction(
      senderId: outgoing ? account.id : json["sender_id"],
      recipientId: !outgoing ? account.id : json["recipient_id"],
      hash: json["session_id"],
      amount: json["amount"],
      date: DateTime.tryParse(json["date"] ?? ""),
      sender: outgoing ? account.name : json["sender"],
      recipient: outgoing ? json["recipient"] : account.name,
    );
  }

  factory Transaction.fromDBMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      hash: map['hash'],
      senderId: int.parse(map['senderId'].toString()),
      recipientId: int.parse(map['recipientId'].toString()),
      amount: double.parse(map['amount'].toString()),
      sender: map['sender'].toString(),
      recipient: map['recipient'].toString(),
      date: DateTime.tryParse(map['date'] ?? ""),
    );
  }
  static List<Transaction> fromHistoryList(List<dynamic> jsonList,
      {required bool outgoing, required Account account}) {
    return List.generate(
        jsonList.length,
        (index) => Transaction.fromHistoryJson(jsonList[index],
            outgoing: outgoing, account: account));
  }

  Map<String, dynamic> get json => {
        'id': id,
        'hash': hash,
        'amount': amount,
        'senderId': senderId,
        'recipientId': recipientId,
        'date': date,
        'sender': sender,
        'recipient': recipient
      };

  @override
  String toString() {
    return 'Transaction <$json>';
  }
}

class Savings {
  final int id, accountId;
  final double amount;
  final DateTime? date;

  Savings(
      {required this.id,
      required this.accountId,
      required this.amount,
      this.date});

  Map<String, dynamic> get json =>
      {'id': id, 'amount': amount, 'date': date, 'accountId': accountId};

  bool equals(Savings other) =>
      id == other.id &&
      amount == other.amount &&
      accountId == other.accountId &&
      date == other.date;

  factory Savings.fromJson(Map<String, dynamic> json) {
    return Savings(
        id: json['id'],
        accountId: json['account_id'],
        amount: json['amount'],
        date: DateTime.tryParse(json['date'] ?? ''));
  }

  static List<Savings> fromJsonList(List<dynamic> jsonList) {
    return List.generate(
        jsonList.length, (index) => Savings.fromJson(jsonList[index]));
  }

  @override
  String toString() {
    return 'Savings<$json>';
  }
}

class Loan {
  int id, accountId;
  double amount;
  DateTime? date;
  Loan(
      {required this.id,
      required this.accountId,
      required this.amount,
      this.date});

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
        id: json["id"],
        accountId: json["account_id"],
        amount: json["amount"],
        date: DateTime.tryParse(json["date"] ?? ""));
  }

  bool equals(Loan other) =>
      id == other.id &&
      accountId == other.accountId &&
      amount == other.amount &&
      date == other.date;

  Map<String, dynamic> get json =>
      {'id': id, 'accountId': accountId, 'amount': amount, 'date': date};
  @override
  String toString() {
    return 'Loan <$json>';
  }

  static List<Loan> fromJsonList(List<dynamic> jsonList) {
    return List.generate(
        jsonList.length, (index) => Loan.fromJson(jsonList[index]));
  }
}
