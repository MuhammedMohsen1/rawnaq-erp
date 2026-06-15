import 'package:intl/intl.dart';
import '../../../projects/domain/enums/project_type.dart';

final NumberFormat _currencyFormat = NumberFormat.currency(
  locale: 'en',
  symbol: 'KD ',
  decimalDigits: 3,
);

String formatKwd(double value) => _currencyFormat.format(value);

String formatPercent(double value) => '${value.toStringAsFixed(1)}%';

String formatProjectStatus(String status, {String? projectType}) {
  switch (status) {
    case 'DRAFT':
      return 'مسودة';
    case 'UNDER_PRICING':
      return 'قيد التسعير';
    case 'PENDING_SIGNATURE':
      return 'بانتظار التوقيع';
    case 'EXECUTION':
      return projectType?.toUpperCase() == 'DESIGN'
          ? 'قيد التصميم'
          : 'قيد التنفيذ';
    case 'COMPLETED':
      return 'مكتمل';
    case 'CANCELLED':
      return 'ملغي';
    default:
      return status;
  }
}

String formatProjectType(String? projectType) {
  return ProjectTypeExtension.fromApiString(projectType).arabicName;
}
