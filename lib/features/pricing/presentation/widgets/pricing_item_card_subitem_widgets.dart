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
        decoration: BoxDecoration(
          color: AppColors.of(context).sectionHeader,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.of(context).textSecondary,
              size: 20,
            ),
            Checkbox(
              value: !subItem.isHidden,
              onChanged: (value) => onToggleVisibility(value ?? false),
              activeColor: AppColors.of(context).primary,
              checkColor: Theme.of(context).colorScheme.onPrimary,
              side: BorderSide(
                color: subItem.isHidden
                    ? AppColors.of(context).lightGrey
                    : AppColors.of(context).primary,
                width: 1.5,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                subItem.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.of(
                  context,
                ).bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (hasSubItemImages) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.of(context).primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.of(
                      context,
                    ).primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 14,
                      color: AppColors.of(context).primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'صور',
                      style: AppTextStyles.of(context).bodySmall.copyWith(
                        color: AppColors.of(context).primary,
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
                          style: AppTextStyles.of(context).caption.copyWith(
                            color: AppColors.of(context).textSecondary,
                          ),
                        ),
                        if (decimalPart.isNotEmpty)
                          TextSpan(
                            text: decimalPart,
                            style: AppTextStyles.of(context).caption.copyWith(
                              color: AppColors.of(context).textSecondary,
                              fontSize:
                                  AppTextStyles.of(context).caption.fontSize! *
                                  0.75,
                            ),
                          ),
                        TextSpan(
                          text: ' KD',
                          style: TextStyle(
                            color: AppColors.of(context).textSecondary,
                            fontSize:
                                AppTextStyles.of(context).caption.fontSize! *
                                0.75,
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
              icon: Icon(
                Icons.more_vert,
                color: AppColors.of(context).textSecondary,
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
    required this.canReorderElements,
    required this.showFinancials,
    required this.isNewRow,
    required this.firstFieldFocusNode,
    required this.onToggleVisibility,
    required this.onDelete,
    required this.onChanged,
    required this.onSubmitted,
    required this.pricingItem,
  });

  final String subItemId;
  final String elementId;
  final int index;
  final PricingElementModel element;
  final bool isLocal;
  final bool canReorderElements;
  final bool showFinancials;
  final bool isNewRow;
  final FocusNode? firstFieldFocusNode;
  final ValueChanged<bool> onToggleVisibility;
  final VoidCallback onDelete;
  final ValueChanged<PricingItem> onChanged;
  final VoidCallback onSubmitted;
  final PricingItem pricingItem;

  @override
  Widget build(BuildContext context) {
    final canDragElement = canReorderElements && !isLocal;

    return Row(
      key: ValueKey('element-$subItemId-$elementId'),
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
                    onChanged: (value) => onToggleVisibility(value ?? false),
                    activeColor: AppColors.of(context).background,
                    checkColor: AppColors.of(context).primary,
                    side: BorderSide(
                      color: element.isHidden
                          ? Colors.red
                          : AppColors.of(context).primary,
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
                  child: Icon(
                    Icons.drag_indicator,
                    color: AppColors.of(context).textMuted,
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
              onSubmitted: onSubmitted,
            ),
          ),
        ),
      ],
    );
  }
}
