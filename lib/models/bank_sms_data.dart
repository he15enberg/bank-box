class BankSmsData {
  final int? id;
  final String sender;
  final String bankCode;
  final String bankName;
  final String body;
  final DateTime? date;
  final bool isRead;

  BankSmsData({
    this.id,
    required this.sender,
    required this.bankCode,
    required this.bankName,
    required this.body,
    this.date,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'bankCode': bankCode,
      'bankName': bankName,
      'body': body,
      'date': date?.toIso8601String(),
      'isRead': isRead,
    };
  }
}
