import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'pricing_item_card_support_widgets.dart';

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
      decoration: const BoxDecoration(
        color: Color(0xFF232936),
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
            activeColor: AppColors.primary,
            checkColor: AppColors.black,
            side: BorderSide(
              color: itemIsHidden ? AppColors.lightGrey : AppColors.primary,
              width: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              itemName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h4.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (pricingStatus != null &&
              showFinancials &&
              canViewFinancials &&
              (pricingStatus!.toUpperCase() == 'APPROVED' ||
                  pricingStatus!.toUpperCase() == 'PENDING_SIGNATURE')) ...[
            PricingStatChip(
              value: totalCost,
              color: const Color.fromARGB(255, 235, 16, 8),
              showFinancials: showFinancials,
            ),
            const SizedBox(width: 6),
            PricingStatChip(
              value: profitAmount,
              color: const Color(0xFF10B981),
              showFinancials: showFinancials,
            ),
            const SizedBox(width: 6),
            PricingStatChip(
              value: totalCost > 0 ? (profitAmount / totalCost * 100) : 0.0,
              color: const Color(0xFFF59E0B),
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
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
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
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.textSecondary,
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
              color: AppColors.textSecondary,
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
        border: outlined ? Border.all(color: const Color(0xFF4B5563)) : null,
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
              color: outlined ? AppColors.textSecondary : AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: outlined ? AppColors.textSecondary : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
