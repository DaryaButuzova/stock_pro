import 'dart:convert';
import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Saves a sales CSV report and opens it with the system default app.
///
/// Returns `null` on success, or a user-facing error message.
///
/// On iOS the file is stored in the app Documents folder:
/// Files → On My iPhone → Stock Pro → reports.
Future<String?> saveSalesReportCsvAndOpen(String csv) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${directory.path}/reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final fileName = _buildFileName();
    final file = File('${reportsDir.path}/$fileName');
    await file.writeAsString('\uFEFF$csv', encoding: utf8);

    final result = await OpenFilex.open(file.path);
    return switch (result.type) {
      ResultType.done => null,
      ResultType.noAppToOpen =>
        'Файл сохранён, но на устройстве нет приложения для CSV',
      ResultType.fileNotFound => 'Не удалось найти сохранённый файл',
      ResultType.permissionDenied => 'Нет разрешения на открытие файла',
      ResultType.error => result.message,
    };
  } catch (e) {
    return 'Не удалось сохранить отчёт';
  }
}

String _buildFileName() {
  final now = DateTime.now().toLocal();
  final stamp =
      '${now.year}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}_'
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}';
  return 'sales_report_$stamp.csv';
}
