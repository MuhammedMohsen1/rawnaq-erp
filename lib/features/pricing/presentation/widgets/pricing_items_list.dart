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
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState();
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Builder(
            builder: (context) {
              // Get user role information
              final authState = context.read<AuthBloc>().state;
              bool isAdminOrManager = false;
              if (authState is AuthAuthenticated) {
                final user = authState.user;
                isAdminOrManager = user.isAdmin || user.isManager;
              }

              return PricingItemCard(
                key: ValueKey('pricing-item-${item.id}'),
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
              );
            },
          ),
        );
      }).toList(),
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
              'ابدأ بإضافة فئة جديدة',
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
