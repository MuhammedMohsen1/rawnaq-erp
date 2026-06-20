import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/pricing_version_model.dart';
import 'pricing_item_card_support_widgets.dart';
import 'pricing_item_card_visuals.dart';
import 'pricing_item_card_subitem_body.dart';
import 'pricing_item_card_subitem_widgets.dart';

class PricingSubItemSection extends StatelessWidget {
  const PricingSubItemSection({
    super.key,
    required this.subItemId,
    required this.index,
    required this.subItem,
    required this.isExpanded,
    required this.hasSubItemImages,
    required this.showFinancials,
    required this.canViewFinancials,
    required this.canReorderSubItems,
    required this.totalCost,
    required this.profitAmount,
    required this.elementRows,
    required this.onToggleExpanded,
    required this.onToggleVisibility,
    required this.onShowMenu,
    required this.onPickImages,
    required this.onPickImagesWithFilePicker,
    required this.onDeleteCurrentImage,
    required this.onCropCurrentImage,
    required this.onShowFullScreenImage,
    required this.onReorderElements,
    required this.onAddElement,
    required this.hasImagesOrUploading,
    required this.isUploadingImage,
    required this.selectedImageIndex,
    required this.deletingImages,
    required this.uploadingImages,
    this.descriptionController,
    this.descriptionFocusNode,
    this.onDescriptionChanged,
    this.profitMarginController,
    this.onProfitMarginChanged,
    this.onProfitMarginEditingComplete,
  });

  final String subItemId;
  final int index;
  final PricingSubItemModel subItem;
  final bool isExpanded;
  final bool hasSubItemImages;
  final bool showFinancials;
  final bool canViewFinancials;
  final bool canReorderSubItems;
  final double totalCost;
  final double profitAmount;
  final List<Widget> elementRows;
  final VoidCallback onToggleExpanded;
  final ValueChanged<bool> onToggleVisibility;
  final VoidCallback onShowMenu;
  final VoidCallback onPickImages;
  final VoidCallback onPickImagesWithFilePicker;
  final VoidCallback onDeleteCurrentImage;
  final VoidCallback onCropCurrentImage;
  final VoidCallback onShowFullScreenImage;
  final ReorderCallback onReorderElements;
  final VoidCallback onAddElement;
  final bool hasImagesOrUploading;
  final bool isUploadingImage;
  final Map<String, int> selectedImageIndex;
  final Map<String, bool> deletingImages;
  final Map<String, bool> uploadingImages;
  final TextEditingController? descriptionController;
  final FocusNode? descriptionFocusNode;
  final ValueChanged<String>? onDescriptionChanged;
  final TextEditingController? profitMarginController;
  final ValueChanged<String>? onProfitMarginChanged;
  final VoidCallback? onProfitMarginEditingComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('pricing-sub-item-$subItemId'),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF363C4A), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          PricingSubItemHeader(
            index: index,
            canReorderSubItems: canReorderSubItems,
            isExpanded: isExpanded,
            subItem: subItem,
            hasSubItemImages: hasSubItemImages,
            showFinancials: showFinancials,
            canViewFinancials: canViewFinancials,
            totalCost: totalCost,
            profitAmount: profitAmount,
            onToggleExpanded: onToggleExpanded,
            onToggleVisibility: onToggleVisibility,
            onShowMenu: onShowMenu,
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: PricingSubItemBody(
              subItem: subItem,
              showFinancials: showFinancials,
              hasImagesOrUploading: hasImagesOrUploading,
              isUploadingImage: isUploadingImage,
              selectedImageIndex: selectedImageIndex,
              deletingImages: deletingImages,
              uploadingImages: uploadingImages,
              onPickImages: onPickImages,
              onPickImagesWithFilePicker: onPickImagesWithFilePicker,
              onDeleteCurrentImage: onDeleteCurrentImage,
              onCropCurrentImage: onCropCurrentImage,
              onShowFullScreenImage: onShowFullScreenImage,
              elementRows: elementRows,
              onReorderElements: onReorderElements,
              onAddElement: onAddElement,
              descriptionController: descriptionController,
              descriptionFocusNode: descriptionFocusNode,
              onDescriptionChanged: onDescriptionChanged,
              profitMarginController: profitMarginController,
              onProfitMarginChanged: onProfitMarginChanged,
              onProfitMarginEditingComplete: onProfitMarginEditingComplete,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class PricingAddSubItemFooter extends StatelessWidget {
  const PricingAddSubItemFooter({
    super.key,
    required this.showFinancials,
    required this.canViewFinancials,
    required this.totalCost,
    required this.totalPrice,
    required this.onTap,
  });

  final bool showFinancials;
  final bool canViewFinancials;
  final double totalCost;
  final double totalPrice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        PricingItemCardAddButton(
          label: 'إضافة عنصر',
          onTap: onTap,
          outlined: true,
        ),
        if (showFinancials) const SizedBox(height: 16),
        if (showFinancials)
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 17.22,
              horizontal: 20,
            ),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF363C4A))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المجموع الفرعي',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'KD',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PricingFormattedNumber(
                      value: canViewFinancials ? totalPrice : totalCost,
                      showFinancials: showFinancials,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
