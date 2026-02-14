import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bank_sms_data.dart';
import '../data/bank_directory.dart';

class SmsListScreen extends StatefulWidget {
  final String bankName;
  final List<BankSmsData> messages;

  const SmsListScreen({
    super.key,
    required this.bankName,
    required this.messages,
  });

  @override
  State<SmsListScreen> createState() => _SmsListScreenState();
}

class _SmsListScreenState extends State<SmsListScreen> {
  String? _selectedCode;
  List<BankSmsData> _filteredMessages = [];
  List<String> _availableCodes = [];

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    // Get all codes that actually have messages
    final Set<String> codesWithMessages = {};
    for (final msg in widget.messages) {
      codesWithMessages.add(msg.bankCode);
    }

    // Get codes for this bank from directory
    final bankCodes = BankDirectory.getCodesForBank(widget.bankName);

    // Filter to only codes that have messages
    _availableCodes =
        bankCodes.where((code) => codesWithMessages.contains(code)).toList();

    // Sort codes alphabetically
    _availableCodes.sort();

    // Initially show all messages
    _filteredMessages = widget.messages;
  }

  void _filterByCode(String? code) {
    setState(() {
      _selectedCode = code;
      if (code == null) {
        _filteredMessages = widget.messages;
      } else {
        _filteredMessages =
            widget.messages.where((msg) => msg.bankCode == code).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.bankName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
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
                  '${_filteredMessages.length} messages',
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
      body: Column(
        children: [
          // Code filter dropdown
          if (_availableCodes.length > 1) _buildCodeFilter(),

          // Messages list
          Expanded(
            child: _filteredMessages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages',
                      style: TextStyle(color: Color(0xFFA1A1A1)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredMessages.length,
                    itemBuilder: (context, index) =>
                        _buildSmsCard(_filteredMessages[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(
          bottom: BorderSide(color: Color(0xFF2A2A2A)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Sender Code',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFA1A1A1),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCode,
                hint: const Text(
                  'All Codes',
                  style: TextStyle(color: Colors.white),
                ),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                dropdownColor: const Color(0xFF1A1A1A),
                isExpanded: true,
                items: [
                  // "All" option
                  DropdownMenuItem<String>(
                    value: null,
                    child: Row(
                      children: [
                        const Icon(Icons.all_inclusive,
                            size: 16, color: Color(0xFFA1A1A1)),
                        const SizedBox(width: 8),
                        const Text(
                          'All Codes',
                          style: TextStyle(color: Colors.white),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${widget.messages.length}',
                            style: const TextStyle(
                              color: Color(0xFFA1A1A1),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  const DropdownMenuItem<String>(
                    enabled: false,
                    child: Divider(color: Color(0xFF2A2A2A)),
                  ),
                  // Individual codes
                  ..._availableCodes.map((code) {
                    final count = widget.messages
                        .where((msg) => msg.bankCode == code)
                        .length;
                    return DropdownMenuItem<String>(
                      value: code,
                      child: Row(
                        children: [
                          const Icon(Icons.label_outline,
                              size: 16, color: Color(0xFFA1A1A1)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              code,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Color(0xFFA1A1A1),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: _filterByCode,
              ),
            ),
          ),
          // Code chips for quick selection
          if (_availableCodes.length <= 6) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCodeChip(null, 'All', widget.messages.length),
                  ..._availableCodes.map((code) {
                    final count = widget.messages
                        .where((msg) => msg.bankCode == code)
                        .length;
                    return _buildCodeChip(code, code, count);
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeChip(String? code, String label, int count) {
    final isSelected = _selectedCode == code;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _filterByCode(code),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.white : const Color(0xFF2A2A2A),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontFamily: code != null ? 'monospace' : null,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.black.withValues(alpha: 0.2)
                      : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.black : const Color(0xFFA1A1A1),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
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
              // Bank code badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  sms.bankCode,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sms.sender,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA1A1A1),
                  ),
                  overflow: TextOverflow.ellipsis,
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
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sms.date != null ? dateFormat.format(sms.date!) : 'Unknown date',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
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
