import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/pricing_version_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'pricing_item_card.dart';

/// List widget displaying all pricing items
class PricingItemsList extends StatelessWidget {
  final String projectId;
  final int version;
  final List<PricingItemModel> items;
  final String? pricingStatus;
  final Map<String, bool> itemExpandedStates;
  final Map<String, Map<String, bool>> subItemExpandedStates;
  final Map<String, double>? subItemProfitMargins;
  final Function(String itemId, bool isExpanded) onItemExpandedChanged;
  final Function(String itemId, Map<String, bool> subItemStates)
  onSubItemExpandedChanged;
  final VoidCallback onDataChanged;
  final Function(String subItemId, double profitMargin)
  onSubItemProfitMarginChanged;
  final Function(String itemId) onAddSubItem;
  final Future<void> Function(int oldIndex, int newIndex)? onReorderItems;
  final Future<void> Function(String itemId, int oldIndex, int newIndex)?
  onReorderSubItems;

  const PricingItemsList({
    super.key,
    required this.projectId,
    required this.version,
    required this.items,
    this.pricingStatus,
    required this.itemExpandedStates,
    required this.subItemExpandedStates,
    this.subItemProfitMargins,
    required this.onItemExpandedChanged,
    required this.onSubItemExpandedChanged,
    required this.onDataChanged,
    required this.onSubItemProfitMarginChanged,
    required this.onAddSubItem,
    this.onReorderItems,
    this.onReorderSubItems,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState();
    }

    return Builder(
      builder: (context) {
        final authState = context.read<AuthBloc>().state;
        bool isAdminOrManager = false;
        if (authState is AuthAuthenticated) {
          final user = authState.user;
          isAdminOrManager = user.isAdmin || user.isManager;
        }

        final status = pricingStatus?.toUpperCase();
        final canReorder =
            isAdminOrManager ||
            status == 'DRAFT' ||
            status == 'PENDING_SIGNATURE';

        return ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: items.length,
          onReorder: (oldIndex, newIndex) async {
            if (!canReorder || onReorderItems == null) return;
            await onReorderItems!(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final item = items[index];

            return Padding(
              key: ValueKey('pricing-item-${item.id}'),
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: PricingItemCard(
                      projectId: projectId,
                      version: version,
                      item: item,
                      pricingStatus: pricingStatus,
                      isAdminOrManager: isAdminOrManager,
                      initialIsExpanded: itemExpandedStates[item.id] ?? true,
                      initialSubItemExpandedStates:
                          subItemExpandedStates[item.id] ?? {},
                      externalProfitMargins: subItemProfitMargins,
                      onExpandedChanged: (isExpanded) =>
                          onItemExpandedChanged(item.id, isExpanded),
                      onSubItemExpandedChanged: (subItemStates) =>
                          onSubItemExpandedChanged(item.id, subItemStates),
                      onItemDeleted: onDataChanged,
                      onSubItemDeleted: (_) => onDataChanged(),
                      onItemChanged: (_) => onDataChanged(),
                      onSubItemChanged: (updatedSubItem) {
                        onSubItemProfitMarginChanged(
                          updatedSubItem.id,
                          updatedSubItem.profitMargin,
                        );
                      },
                      onAddSubItem: () => onAddSubItem(item.id),
                      canReorderSubItems: canReorder,
                      onReorderSubItems: (oldSubIndex, newSubIndex) async {
                        if (onReorderSubItems == null) return;
                        await onReorderSubItems!(
                          item.id,
                          oldSubIndex,
                          newSubIndex,
                        );
                      },
                    ),
                  ),
                  if (canReorder) ...[
                    const SizedBox(width: 8),
                    ReorderableDragStartListener(
                      index: index,
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A313D),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF363C4A)),
                        ),
                        child: const Icon(
                          Icons.drag_indicator,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Empty state widget when no items exist
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              Icons.folder_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد فئات بعد',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة بند جديد',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
