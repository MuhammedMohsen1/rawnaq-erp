import 'dart:typed_data';

class FileDownloadHelper {
  static void downloadFile({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) {
    throw UnsupportedError('File downloading is only supported on web.');
  }

  static void downloadZipFile({
    required Uint8List bytes,
    required String fileName,
  }) => downloadFile(bytes: bytes, fileName: fileName);

  static void downloadExcelFile({
    required Uint8List bytes,
    required String fileName,
  }) => downloadFile(bytes: bytes, fileName: fileName);

  static void downloadCsvFile({
    required Uint8List bytes,
    required String fileName,
  }) => downloadFile(bytes: bytes, fileName: fileName);

  static void downloadPdfFile({
    required Uint8List bytes,
    required String fileName,
  }) => downloadFile(bytes: bytes, fileName: fileName);

  static String generateSettlementFileName({
    required String reportType,
    required DateTime date,
    String extension = 'zip',
  }) {
    final dateStr = date.toIso8601String().split('T')[0];
    return '${reportType}_settlement_reports_$dateStr.$extension';
  }
}
