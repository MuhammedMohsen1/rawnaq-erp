import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/pricing_version_model.dart';
import '../../domain/entities/pricing_item.dart';
import 'pricing_item_card_support_widgets.dart';
import 'pricing_table_row.dart';

class PricingSubItemHeader extends StatelessWidget {
  const PricingSubItemHeader({
    super.key,
    required this.index,
    required this.canReorderSubItems,
    required this.isExpanded,
    required this.subItem,
    required this.hasSubItemImages,
    required this.showFinancials,
    required this.canViewFinancials,
    required this.totalCost,
    required this.profitAmount,
    required this.onToggleExpanded,
    required this.onToggleVisibility,
    required this.onShowMenu,
  });

  final int index;
  final bool canReorderSubItems;
  final bool isExpanded;
  final PricingSubItemModel subItem;
  final bool hasSubItemImages;
  final bool showFinancials;
  final bool canViewFinancials;
  final double totalCost;
  final double profitAmount;
  final VoidCallback onToggleExpanded;
  final ValueChanged<bool> onToggleVisibility;
  final VoidCallback onShowMenu;

  @override
  Widget build(BuildContext context) {
    final headerChild = InkWell(
      onTap: onToggleExpanded,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF2A313D),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.textSecondary,
              size: 20,
            ),
            Checkbox(
              value: !subItem.isHidden,
              onChanged: (value) => onToggleVisibility(value ?? false),
              activeColor: AppColors.primary,
              checkColor: AppColors.black,
              side: BorderSide(
                color: subItem.isHidden
                    ? AppColors.lightGrey
                    : AppColors.primary,
                width: 1.5,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                subItem.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (hasSubItemImages) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'صور',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
            PricingSubItemStats(
              subItem: subItem,
              showFinancials: showFinancials,
              canViewFinancials: canViewFinancials,
            ),
            if (canViewFinancials) const SizedBox(width: 8),
            if (showFinancials)
              Builder(
                builder: (context) {
                  final total = canViewFinancials
                      ? totalCost + profitAmount
                      : totalCost;
                  final totalStr = total.toStringAsFixed(3);
                  final dotIndex = totalStr.indexOf('.');
                  final intPart = dotIndex >= 0
                      ? totalStr.substring(0, dotIndex)
                      : totalStr;
                  final decimalPart = dotIndex >= 0
                      ? totalStr.substring(dotIndex)
                      : '';

                  return RichText(
                    textDirection: TextDirection.ltr,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: intPart,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (decimalPart.isNotEmpty)
                          TextSpan(
                            text: decimalPart,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: AppTextStyles.caption.fontSize! * 0.75,
                            ),
                          ),
                        TextSpan(
                          text: ' KD',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppTextStyles.caption.fontSize! * 0.75,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onShowMenu,
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 18,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );

    return canReorderSubItems
        ? ReorderableDelayedDragStartListener(index: index, child: headerChild)
        : headerChild;
  }
}

class PricingElementRowShell extends StatelessWidget {
  const PricingElementRowShell({
    super.key,
    required this.subItemId,
    required this.elementId,
    required this.index,
    required this.element,
    required this.isLocal,
    required this.isSaving,
    required this.canReorderElements,
    required this.showFinancials,
    required this.isNewRow,
    required this.firstFieldFocusNode,
    required this.onToggleVisibility,
    required this.onDelete,
    required this.onChanged,
    required this.onFieldCompleted,
    required this.onSubmitted,
    required this.pricingItem,
  });

  final String subItemId;
  final String elementId;
  final int index;
  final PricingElementModel element;
  final bool isLocal;
  final bool isSaving;
  final bool canReorderElements;
  final bool showFinancials;
  final bool isNewRow;
  final FocusNode? firstFieldFocusNode;
  final ValueChanged<bool> onToggleVisibility;
  final VoidCallback onDelete;
  final ValueChanged<PricingItem> onChanged;
  final VoidCallback onFieldCompleted;
  final VoidCallback onSubmitted;
  final PricingItem pricingItem;

  @override
  Widget build(BuildContext context) {
    final canDragElement = canReorderElements && !isLocal;

    return Stack(
      key: ValueKey('element-$subItemId-$elementId'),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 44,
              child: isLocal
                  ? const SizedBox.shrink()
                  : Tooltip(
                      message: element.isHidden
                          ? 'إظهار العنصر في التسعير و PDF'
                          : 'إخفاء العنصر من التسعير و PDF',
                      child: Checkbox(
                        value: !element.isHidden,
                        onChanged: (value) =>
                            onToggleVisibility(value ?? false),
                        activeColor: AppColors.background,
                        checkColor: AppColors.primary,
                        side: BorderSide(
                          color: element.isHidden
                              ? Colors.red
                              : AppColors.primary,
                        ),
                      ),
                    ),
            ),
            SizedBox(
              width: 28,
              height: 44,
              child: canDragElement
                  ? ReorderableDragStartListener(
                      index: index,
                      child: const Icon(
                        Icons.drag_indicator,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: Opacity(
                opacity: element.isHidden ? 0.55 : 1,
                child: PricingTableRow(
                  item: pricingItem,
                  showFinancials: showFinancials,
                  isNewRow: isNewRow,
                  firstFieldFocusNode: firstFieldFocusNode,
                  onDelete: onDelete,
                  onChanged: onChanged,
                  onFieldCompleted: onFieldCompleted,
                  onSubmitted: onSubmitted,
                ),
              ),
            ),
          ],
        ),
        if (isSaving)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
