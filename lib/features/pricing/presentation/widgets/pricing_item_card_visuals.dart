import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'pricing_item_card_support_widgets.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

class PricingItemCardHeader extends StatelessWidget {
  const PricingItemCardHeader({
    super.key,
    required this.itemName,
    required this.itemIsHidden,
    required this.onVisibilityChanged,
    required this.onToggleExpanded,
    required this.onMenuPressed,
    required this.isExpanded,
    required this.canShowFinancials,
    required this.showFinancials,
    required this.canViewFinancials,
    required this.totalCost,
    required this.profitAmount,
    required this.pricingStatus,
  });

  final String itemName;
  final bool itemIsHidden;
  final ValueChanged<bool> onVisibilityChanged;
  final VoidCallback onToggleExpanded;
  final VoidCallback onMenuPressed;
  final bool isExpanded;
  final bool canShowFinancials;
  final bool showFinancials;
  final bool canViewFinancials;
  final double totalCost;
  final double profitAmount;
  final String? pricingStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 71,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
      decoration: BoxDecoration(
        color: AppColors.of(context).sectionHeader,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.architecture, color: Color(0xFF135BEC), size: 24),
          Checkbox(
            value: !itemIsHidden,
            onChanged: (value) => onVisibilityChanged(value ?? false),
            activeColor: AppColors.of(context).primary,
            checkColor: Theme.of(context).colorScheme.onPrimary,
            side: BorderSide(
              color: itemIsHidden
                  ? AppColors.of(context).lightGrey
                  : AppColors.of(context).primary,
              width: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ArabicNumberTransformer.transform(itemName),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.of(
                context,
              ).h4.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          if (pricingStatus != null &&
              showFinancials &&
              canViewFinancials &&
              (pricingStatus!.toUpperCase() == 'APPROVED' ||
                  pricingStatus!.toUpperCase() == 'PENDING_SIGNATURE')) ...[
            PricingStatCard(
              label: 'التكلفة',
              value: totalCost,
              color: (Theme.of(context).brightness == Brightness.light
                  ? AppColors.light.error
                  : const Color.fromARGB(255, 235, 16, 8)),
              showFinancials: showFinancials,
            ),
            const SizedBox(width: 6),
            PricingStatCard(
              label: 'صافي الربح',
              value: profitAmount,
              color: (Theme.of(context).brightness == Brightness.light
                  ? AppColors.light.success
                  : const Color(0xFF10B981)),
              showFinancials: showFinancials,
            ),
            const SizedBox(width: 6),
            PricingStatChip(
              value: totalCost > 0 ? (profitAmount / totalCost * 100) : 0.0,
              color: (Theme.of(context).brightness == Brightness.light
                  ? AppColors.light.warning
                  : const Color(0xFFF59E0B)),
              suffix: '%',
              showFinancials: showFinancials,
            ),
            const SizedBox(width: 16),
          ],
          if (canShowFinancials) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        'KD',
                        style: AppTextStyles.of(context).caption.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.of(context).textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    PricingFormattedNumber(
                      value: canViewFinancials
                          ? profitAmount + totalCost
                          : totalCost,
                      showFinancials: showFinancials,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 16),
          ],
          IconButton(
            onPressed: onMenuPressed,
            icon: Icon(
              Icons.more_vert,
              color: AppColors.of(context).textSecondary,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 18,
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onToggleExpanded,
            icon: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.of(context).textSecondary,
              size: 24,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class PricingItemCardAddButton extends StatelessWidget {
  const PricingItemCardAddButton({
    super.key,
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        border: outlined
            ? Border.all(color: AppColors.of(context).textDisabled)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: outlined
                  ? AppColors.of(context).textSecondary
                  : AppColors.of(context).primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              ArabicNumberTransformer.transform(label),
              style: AppTextStyles.of(context).bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: outlined
                    ? AppColors.of(context).textSecondary
                    : AppColors.of(context).primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
