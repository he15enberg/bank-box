import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/bank_sms_data.dart';

class ExcelService {
  Future<String> exportToExcel(List<BankSmsData> messages) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Bank SMS';

    // Header styling
    final Style headerStyle = workbook.styles.add('headerStyle');
    headerStyle.bold = true;
    headerStyle.fontColor = '#FFFFFF';
    headerStyle.backColor = '#000000';
    headerStyle.hAlign = HAlignType.center;
    headerStyle.borders.all.lineStyle = LineStyle.thin;
    headerStyle.borders.all.color = '#2A2A2A';

    // Data styling
    final Style dataStyle = workbook.styles.add('dataStyle');
    dataStyle.borders.all.lineStyle = LineStyle.thin;
    dataStyle.borders.all.color = '#E0E0E0';
    dataStyle.wrapText = true;

    // Headers
    final headers = [
      'S.No',
      'Date & Time',
      'Sender',
      'Bank Code',
      'Bank Name',
      'SMS Body',
      'Read Status',
      'SMS ID'
    ];

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(1, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final row = i + 2;

      sheet.getRangeByIndex(row, 1).setNumber((i + 1).toDouble());
      sheet.getRangeByIndex(row, 2).setText(
        msg.date != null ? dateFormat.format(msg.date!) : 'N/A',
      );
      sheet.getRangeByIndex(row, 3).setText(msg.sender);
      sheet.getRangeByIndex(row, 4).setText(msg.bankCode);
      sheet.getRangeByIndex(row, 5).setText(msg.bankName);
      sheet.getRangeByIndex(row, 6).setText(msg.body);
      sheet.getRangeByIndex(row, 7).setText(msg.isRead ? 'Read' : 'Unread');
      sheet.getRangeByIndex(row, 8).setNumber(msg.id?.toDouble() ?? 0);

      for (int j = 1; j <= 8; j++) {
        sheet.getRangeByIndex(row, j).cellStyle = dataStyle;
      }
    }

    // Auto-fit columns
    sheet.getRangeByIndex(1, 1, messages.length + 1, 1).columnWidth = 8;
    sheet.getRangeByIndex(1, 2, messages.length + 1, 2).columnWidth = 20;
    sheet.getRangeByIndex(1, 3, messages.length + 1, 3).columnWidth = 15;
    sheet.getRangeByIndex(1, 4, messages.length + 1, 4).columnWidth = 12;
    sheet.getRangeByIndex(1, 5, messages.length + 1, 5).columnWidth = 25;
    sheet.getRangeByIndex(1, 6, messages.length + 1, 6).columnWidth = 60;
    sheet.getRangeByIndex(1, 7, messages.length + 1, 7).columnWidth = 12;
    sheet.getRangeByIndex(1, 8, messages.length + 1, 8).columnWidth = 12;

    // Save file
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/Bankbox_$timestamp.xlsx';

    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return filePath;
  }

  Future<void> shareFile(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Bank SMS Export from Bankbox',
    );
  }
}
