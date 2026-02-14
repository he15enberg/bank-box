import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/bank_sms_data.dart';
import '../data/bank_directory.dart';

class SmsService {
  final SmsQuery _query = SmsQuery();

  Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<bool> hasPermission() async {
    return await Permission.sms.isGranted;
  }

  Future<List<SmsMessage>> fetchAllSms() async {
    final messages = await _query.getAllSms;
    return messages;
  }

  Future<List<BankSmsData>> filterBankSms() async {
    final allMessages = await fetchAllSms();
    final List<BankSmsData> bankMessages = [];

    for (final sms in allMessages) {
      final sender = sms.sender ?? '';
      if (sender.isEmpty) continue;

      final bankCode = BankDirectory.findBankCode(sender);
      if (bankCode != null) {
        bankMessages.add(BankSmsData(
          id: sms.id,
          sender: sender,
          bankCode: bankCode,
          bankName: BankDirectory.getBankName(bankCode),
          body: sms.body ?? '',
          date: sms.date,
          isRead: sms.isRead ?? false,
        ));
      }
    }

    bankMessages.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });

    return bankMessages;
  }

  /// Group messages by bank code (original method)
  Map<String, List<BankSmsData>> groupByBank(List<BankSmsData> messages) {
    final Map<String, List<BankSmsData>> grouped = {};
    for (final msg in messages) {
      if (!grouped.containsKey(msg.bankCode)) {
        grouped[msg.bankCode] = [];
      }
      grouped[msg.bankCode]!.add(msg);
    }
    return grouped;
  }

  /// Group messages by bank name (for the new UI with multiple codes per bank)
  Map<String, List<BankSmsData>> groupByBankName(List<BankSmsData> messages) {
    final Map<String, List<BankSmsData>> grouped = {};
    for (final msg in messages) {
      if (!grouped.containsKey(msg.bankName)) {
        grouped[msg.bankName] = [];
      }
      grouped[msg.bankName]!.add(msg);
    }
    return grouped;
  }
}
