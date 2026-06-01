import 'package:intl/intl.dart';

final NumberFormat _currencyFormat = NumberFormat.currency(
  locale: 'en',
  symbol: 'KD ',
  decimalDigits: 3,
);

String formatKwd(double value) => _currencyFormat.format(value);

String formatPercent(double value) => '${value.toStringAsFixed(1)}%';

String formatProjectStatus(String status) {
  switch (status) {
    case 'EXECUTION':
      return 'قيد التنفيذ';
    case 'COMPLETED':
      return 'مكتمل';
    default:
      return status;
  }
}
