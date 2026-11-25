import 'package:flutter/material.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

class ContractExportReviewItem extends StatelessWidget {
  final String label;
  final String value;

  const ContractExportReviewItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              ArabicNumberTransformer.transform(label),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              ArabicNumberTransformer.transform(value.isEmpty ? '-' : value),
              textDirection: value.contains(RegExp(r'[ء-ي]'))
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }
}
