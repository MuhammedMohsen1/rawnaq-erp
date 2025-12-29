import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/pricing_item.dart';
import 'pricing_table_row.dart';

class GlobalExpensesCard extends StatefulWidget {
  final List<PricingItem> items;
  final ValueChanged<List<PricingItem>>? onItemsChanged;
  final VoidCallback? onAddItem;

  const GlobalExpensesCard({
    super.key,
    required this.items,
    this.onItemsChanged,
    this.onAddItem,
  });

  @override
  State<GlobalExpensesCard> createState() => _GlobalExpensesCardState();
}

class _GlobalExpensesCardState extends State<GlobalExpensesCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C212B),
        border: Border.all(color: const Color(0xFF363C4A)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 61,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF232936),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'المصروفات العامة',
                  style: AppTextStyles.h4.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A313D),
                    border: Border.all(color: const Color(0xFF363C4A)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.statusCompleted.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'قيد التنفيذ',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4ADE80),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Status',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          // Table (Collapsible)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    height: 41.5,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'وصف العنصر',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'التكلفة (دينار)',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Table Rows
                  ...widget.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return PricingTableRow(
                      item: item,
                      isNewRow: item.unitPrice == null && item.quantity == null,
                      onDelete: () {
                        final newItems = List<PricingItem>.from(widget.items);
                        newItems.removeAt(index);
                        widget.onItemsChanged?.call(newItems);
                      },
                      onChanged: (updatedItem) {
                        final newItems = List<PricingItem>.from(widget.items);
                        newItems[index] = updatedItem.copyWith(
                          total: updatedItem.calculateTotal(),
                        );
                        widget.onItemsChanged?.call(newItems);
                      },
                    );
                  }),
                  // Add Item Row Button
                  const SizedBox(height: 12),
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF4B5563),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: widget.onAddItem,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'إضافة صف',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
