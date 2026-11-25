import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

/// Header widget showing pricing status badge
class PricingHeader extends StatelessWidget {
  final String statusText;
  final Color statusColor;

  const PricingHeader({
    super.key,
    required this.statusText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: _StatusBadge(statusText: statusText, statusColor: statusColor),
    );
  }
}

/// Private widget for status badge
class _StatusBadge extends StatelessWidget {
  final String statusText;
  final Color statusColor;

  const _StatusBadge({required this.statusText, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            ArabicNumberTransformer.transform(statusText),
            style: AppTextStyles.of(context).caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
