import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bank_sms_data.dart';

class SmsListScreen extends StatelessWidget {
  final String bankCode;
  final String bankName;
  final List<BankSmsData> messages;

  const SmsListScreen({
    super.key,
    required this.bankCode,
    required this.bankName,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          bankName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${messages.length} messages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: messages.isEmpty
          ? const Center(
              child: Text(
                'No messages',
                style: TextStyle(color: Color(0xFFA1A1A1)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildSmsCard(messages[index]),
            ),
    );
  }

  Widget _buildSmsCard(BankSmsData sms) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sms.sender,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!sms.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                sms.date != null ? dateFormat.format(sms.date!) : 'Unknown',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFA1A1A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sms.body,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFCCCCCC),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
