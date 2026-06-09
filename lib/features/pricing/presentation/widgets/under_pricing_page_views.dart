import 'package:flutter/material.dart';
import 'package:flutter_ionicons/flutter_ionicons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../projects/presentation/widgets/project_attachments_panel.dart';
import '../../../projects/domain/enums/project_status.dart';
import '../cubit/pricing_state.dart';
import '../utils/pricing_status_utils.dart';
import 'add_pricing_item_button.dart';
import 'pricing_header.dart';
import 'pricing_items_list.dart';

class PricingLoadingView extends StatelessWidget {
  const PricingLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

class PricingErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PricingErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class PricingEmptyReadOnlyView extends StatelessWidget {
  const PricingEmptyReadOnlyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 54,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد بيانات تسعير لهذا المشروع المؤرشف',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'استعد المشروع أولاً لإضافة إصدار تسعير جديد.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PricingLoadedLayout extends StatelessWidget {
  final String projectId;
  final PricingLoaded state;
  final bool canEditPricing;
  final bool hideFinancials;
  final bool showFinancials;
  final VoidCallback onToggleFinancials;
  final Widget Function(BuildContext context, PricingLoaded state) buildSidebar;
  final VoidCallback onAddItem;
  final VoidCallback Function(String itemId) onAddSubItem;
  final Future<void> Function(int oldIndex, int newIndex)? onReorderItems;
  final Future<void> Function(String itemId, int oldIndex, int newIndex)?
  onReorderSubItems;
  final Future<void> Function(
    String itemId,
    String subItemId,
    String elementId,
    int targetOrder,
  )?
  onReorderElements;
  final void Function(String itemId, bool isExpanded) onItemExpandedChanged;
  final void Function(String itemId, Map<String, bool> subItemStates)
  onSubItemExpandedChanged;
  final void Function(String subItemId, double profitMargin)
  onSubItemProfitMarginChanged;
  final VoidCallback onDataChanged;

  const PricingLoadedLayout({
    super.key,
    required this.projectId,
    required this.state,
    required this.canEditPricing,
    required this.hideFinancials,
    required this.showFinancials,
    required this.onToggleFinancials,
    required this.buildSidebar,
    required this.onAddItem,
    required this.onAddSubItem,
    required this.onReorderItems,
    required this.onReorderSubItems,
    required this.onReorderElements,
    required this.onItemExpandedChanged,
    required this.onSubItemExpandedChanged,
    required this.onSubItemProfitMarginChanged,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _PricingLayout(
        projectId: projectId,
        state: state,
        padding: 16,
        canEditPricing: canEditPricing,
        hideFinancialsInitially: hideFinancials,
        showFinancials: showFinancials,
        onToggleFinancials: onToggleFinancials,
        buildSidebar: buildSidebar,
        onAddItem: onAddItem,
        onAddSubItem: onAddSubItem,
        onReorderItems: onReorderItems,
        onReorderSubItems: onReorderSubItems,
        onReorderElements: onReorderElements,
        onItemExpandedChanged: onItemExpandedChanged,
        onSubItemExpandedChanged: onSubItemExpandedChanged,
        onSubItemProfitMarginChanged: onSubItemProfitMarginChanged,
        onDataChanged: onDataChanged,
      ),
      tablet: _PricingLayout(
        projectId: projectId,
        state: state,
        padding: 24,
        canEditPricing: canEditPricing,
        hideFinancialsInitially: hideFinancials,
        showFinancials: showFinancials,
        onToggleFinancials: onToggleFinancials,
        buildSidebar: buildSidebar,
        onAddItem: onAddItem,
        onAddSubItem: onAddSubItem,
        onReorderItems: onReorderItems,
        onReorderSubItems: onReorderSubItems,
        onReorderElements: onReorderElements,
        onItemExpandedChanged: onItemExpandedChanged,
        onSubItemExpandedChanged: onSubItemExpandedChanged,
        onSubItemProfitMarginChanged: onSubItemProfitMarginChanged,
        onDataChanged: onDataChanged,
      ),
      desktop: _PricingLayout(
        projectId: projectId,
        state: state,
        padding: 32,
        canEditPricing: canEditPricing,
        hideFinancialsInitially: hideFinancials,
        showFinancials: showFinancials,
        onToggleFinancials: onToggleFinancials,
        buildSidebar: buildSidebar,
        onAddItem: onAddItem,
        onAddSubItem: onAddSubItem,
        onReorderItems: onReorderItems,
        onReorderSubItems: onReorderSubItems,
        onReorderElements: onReorderElements,
        onItemExpandedChanged: onItemExpandedChanged,
        onSubItemExpandedChanged: onSubItemExpandedChanged,
        onSubItemProfitMarginChanged: onSubItemProfitMarginChanged,
        onDataChanged: onDataChanged,
      ),
    );
  }
}

class _PricingLayout extends StatelessWidget {
  final String projectId;
  final PricingLoaded state;
  final double padding;
  final bool canEditPricing;
  final bool hideFinancialsInitially;
  final bool showFinancials;
  final VoidCallback onToggleFinancials;
  final Widget Function(BuildContext context, PricingLoaded state) buildSidebar;
  final VoidCallback onAddItem;
  final VoidCallback Function(String itemId) onAddSubItem;
  final Future<void> Function(int oldIndex, int newIndex)? onReorderItems;
  final Future<void> Function(String itemId, int oldIndex, int newIndex)?
  onReorderSubItems;
  final Future<void> Function(
    String itemId,
    String subItemId,
    String elementId,
    int targetOrder,
  )?
  onReorderElements;
  final void Function(String itemId, bool isExpanded) onItemExpandedChanged;
  final void Function(String itemId, Map<String, bool> subItemStates)
  onSubItemExpandedChanged;
  final void Function(String subItemId, double profitMargin)
  onSubItemProfitMarginChanged;
  final VoidCallback onDataChanged;

  const _PricingLayout({
    required this.projectId,
    required this.state,
    required this.padding,
    required this.canEditPricing,
    required this.hideFinancialsInitially,
    required this.showFinancials,
    required this.onToggleFinancials,
    required this.buildSidebar,
    required this.onAddItem,
    required this.onAddSubItem,
    required this.onReorderItems,
    required this.onReorderSubItems,
    required this.onReorderElements,
    required this.onItemExpandedChanged,
    required this.onSubItemExpandedChanged,
    required this.onSubItemProfitMarginChanged,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = PricingStatusUtils.getStatusColor(
      state.pricingVersion.status,
    );
    final showMobileFinancialToggle =
        hideFinancialsInitially && ResponsiveLayout.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PricingHeader(
            statusText: state.getStatusText(),
            statusColor: statusColor,
          ),
          const SizedBox(height: 24),
          if (showMobileFinancialToggle) ...[
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: PricingMobileFinancialVisibilityButton(
                showFinancials: showFinancials,
                onPressed: onToggleFinancials,
              ),
            ),
            const SizedBox(height: 16),
          ],
          ProjectAttachmentsPanel(
            projectId: projectId,
            projectStatus: ProjectStatusExtension.fromApiString(
              state.pricingVersion.status,
            ),
            readOnly: state.readOnly,
          ),
          const SizedBox(height: 24),
          PricingItemsList(
            projectId: projectId,
            version: state.pricingVersion.version,
            items: state.pricingVersion.items ?? [],
            pricingStatus: state.pricingVersion.status,
            itemExpandedStates: state.itemExpandedStates,
            subItemExpandedStates: state.subItemExpandedStates,
            subItemProfitMargins: state.subItemProfitMargins,
            onItemExpandedChanged: onItemExpandedChanged,
            onSubItemExpandedChanged: onSubItemExpandedChanged,
            onDataChanged: onDataChanged,
            onSubItemProfitMarginChanged: onSubItemProfitMarginChanged,
            onAddSubItem: onAddSubItem,
            onReorderItems: onReorderItems,
            onReorderSubItems: onReorderSubItems,
            onReorderElements: onReorderElements,
            readOnly: !canEditPricing,
            showFinancials: showFinancials,
          ),
          const SizedBox(height: 24),
          if (canEditPricing) ...[
            AddPricingItemButton(onTap: onAddItem),
            const SizedBox(height: 24),
          ],
          if (showFinancials) buildSidebar(context, state),
        ],
      ),
    );
  }
}

class PricingMobileFinancialVisibilityButton extends StatelessWidget {
  final bool showFinancials;
  final VoidCallback onPressed;

  const PricingMobileFinancialVisibilityButton({
    super.key,
    required this.showFinancials,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: showFinancials ? 'إخفاء بيانات التسعير' : 'إظهار بيانات التسعير',
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          icon: Icon(
            showFinancials ? Ionicons.eye_outline : Ionicons.eye_off_outline,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
