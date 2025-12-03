import 'dart:html' as html;
import 'dart:typed_data';

/// Helper class for handling file downloads in web environment
class FileDownloadHelper {
  /// Downloads a file from bytes data with automatic browser download
  static void downloadFile({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) {
    try {
      // Create blob from bytes
      final blob = html.Blob([bytes], mimeType ?? 'application/octet-stream');

      // Create object URL
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create temporary anchor element for download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..setAttribute('target', '_self')
        ..style.display = 'none';

      // Add to DOM, trigger download, and remove immediately
      html.document.body?.children.add(anchor);

      // Use a small delay to ensure DOM is updated before clicking
      Future.delayed(const Duration(milliseconds: 10), () {
        anchor.click();

        // Clean up immediately after click
        Future.delayed(const Duration(milliseconds: 50), () {
          html.document.body?.children.remove(anchor);
          html.Url.revokeObjectUrl(url);
        });
      });
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  /// Downloads a ZIP file with appropriate MIME type
  static void downloadZipFile({
    required Uint8List bytes,
    required String fileName,
  }) {
    downloadFile(
      bytes: bytes,
      fileName: fileName.endsWith('.zip') ? fileName : '$fileName.zip',
      mimeType: 'application/zip',
    );
  }

  /// Downloads an Excel file with appropriate MIME type
  static void downloadExcelFile({
    required Uint8List bytes,
    required String fileName,
  }) {
    downloadFile(
      bytes: bytes,
      fileName: fileName.endsWith('.xlsx') ? fileName : '$fileName.xlsx',
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  /// Downloads a CSV file with appropriate MIME type
  static void downloadCsvFile({
    required Uint8List bytes,
    required String fileName,
  }) {
    downloadFile(
      bytes: bytes,
      fileName: fileName.endsWith('.csv') ? fileName : '$fileName.csv',
      mimeType: 'text/csv',
    );
  }

  /// Downloads a PDF file with appropriate MIME type
  static void downloadPdfFile({
    required Uint8List bytes,
    required String fileName,
  }) {
    downloadFile(
      bytes: bytes,
      fileName: fileName.endsWith('.pdf') ? fileName : '$fileName.pdf',
      mimeType: 'application/pdf',
    );
  }

  /// Generates a filename with date for settlement reports
  static String generateSettlementFileName({
    required String reportType,
    required DateTime date,
    String extension = 'zip',
  }) {
    final dateStr = date.toIso8601String().split('T')[0]; // YYYY-MM-DD
    return '${reportType}_settlement_reports_$dateStr.$extension';
  }
}
