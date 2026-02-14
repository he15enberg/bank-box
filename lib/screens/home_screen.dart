import 'package:flutter/material.dart';
import '../models/bank_sms_data.dart';
import '../services/sms_service.dart';
import '../services/excel_service.dart';
import '../data/bank_directory.dart';
import 'sms_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SmsService _smsService = SmsService();
  final ExcelService _excelService = ExcelService();

  List<BankSmsData> _allMessages = [];
  Map<String, List<BankSmsData>> _groupedByBankName = {};
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    try {
      final messages = await _smsService.filterBankSms();
      final grouped = _smsService.groupByBankName(messages);

      setState(() {
        _allMessages = messages;
        _groupedByBankName = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages: $e')),
        );
      }
    }
  }

  Future<void> _exportToExcel() async {
    if (_allMessages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No messages to export')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final filePath = await _excelService.exportToExcel(_allMessages);

      setState(() => _isExporting = false);

      if (mounted) {
        _showExportSuccessSheet(filePath);
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _showExportSuccessSheet(String filePath) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(
              Icons.check_circle,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Export Successful',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_allMessages.length} messages exported',
              style: const TextStyle(color: Color(0xFFA1A1A1)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _excelService.shareFile(filePath);
                },
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share File'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateToSmsList(String bankName) {
    final messages = _groupedByBankName[bankName] ?? [];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SmsListScreen(
          bankName: bankName,
          messages: messages,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bankbox'),
        actions: [
          IconButton(
            onPressed: _loadMessages,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _buildContent(),
      floatingActionButton: _isLoading || _allMessages.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _isExporting ? null : _exportToExcel,
              backgroundColor: Colors.white,
              icon: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.download, color: Colors.black),
              label: Text(
                _isExporting ? 'Exporting...' : 'Export to Excel',
                style: const TextStyle(color: Colors.black),
              ),
            ),
    );
  }

  Widget _buildContent() {
    if (_allMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Color(0xFF2A2A2A),
            ),
            const SizedBox(height: 16),
            const Text(
              'No bank messages found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We couldn\'t find any SMS from known banks',
              style: TextStyle(color: Color(0xFFA1A1A1)),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _loadMessages,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // Sort banks by message count (descending)
    final sortedBanks = _groupedByBankName.keys.toList()
      ..sort((a, b) =>
          (_groupedByBankName[b]?.length ?? 0) -
          (_groupedByBankName[a]?.length ?? 0));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text(
              'Banks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              '${BankDirectory.totalCodes} codes tracked',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sortedBanks.map((bankName) => _buildBankCard(bankName)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.email,
              color: Colors.black,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_allMessages.length}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Bank messages found',
                  style: TextStyle(color: Color(0xFFA1A1A1)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_groupedByBankName.length} banks',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(String bankName) {
    final messages = _groupedByBankName[bankName] ?? [];

    // Get unique codes used in messages for this bank
    final uniqueCodes = <String>{};
    for (final msg in messages) {
      uniqueCodes.add(msg.bankCode);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToSmsList(bankName),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bankName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${uniqueCodes.length} sender ${uniqueCodes.length == 1 ? 'code' : 'codes'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFA1A1A1),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${messages.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFA1A1A1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
