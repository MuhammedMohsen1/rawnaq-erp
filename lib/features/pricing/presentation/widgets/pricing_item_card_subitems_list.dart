import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/pricing_version_model.dart';
import '../../domain/entities/pricing_item.dart';
import 'pricing_item_card_local_element.dart';
import 'pricing_item_card_subitem_widgets.dart';
import 'pricing_item_card_section_widgets.dart';

class PricingItemCardSubItemsList extends StatelessWidget {
  const PricingItemCardSubItemsList({
    super.key,
    required this.item,
    required this.showFinancials,
    required this.canViewFinancials,
    required this.canReorderSubItems,
    required this.canReorderElements,
    required this.expandedSubItems,
    required this.localElements,
    required this.savingElements,
    required this.updatingElements,
    required this.uploadingImages,
    required this.deletingImages,
    required this.selectedImageIndex,
    required this.localElementFocusNodes,
    required this.onToggleSubItem,
    required this.onToggleSubItemVisibility,
    required this.onShowSubItemContextMenu,
    required this.onPickImages,
    required this.onPickImagesWithFilePicker,
    required this.onDeleteCurrentImage,
    required this.onCropCurrentImage,
    required this.onShowFullScreenImage,
    required this.onAddElement,
    required this.onReorderSubItems,
    required this.onReorderElements,
    required this.onToggleElementVisibility,
    required this.onDeleteElement,
    required this.onElementChanged,
    required this.onElementFieldCompleted,
    required this.onElementSubmitted,
    required this.getAllElementsForSubItem,
  });

  final PricingItemModel item;
  final bool showFinancials;
  final bool canViewFinancials;
  final bool canReorderSubItems;
  final bool canReorderElements;
  final Map<String, bool> expandedSubItems;
  final Map<String, List<LocalElement>> localElements;
  final Map<String, bool> savingElements;
  final Map<String, bool> updatingElements;
  final Map<String, bool> uploadingImages;
  final Map<String, bool> deletingImages;
  final Map<String, int> selectedImageIndex;
  final Map<String, FocusNode> localElementFocusNodes;
  final void Function(String subItemId) onToggleSubItem;
  final Future<void> Function(PricingSubItemModel subItem, bool newValue)
  onToggleSubItemVisibility;
  final void Function(PricingSubItemModel subItem) onShowSubItemContextMenu;
  final void Function(String subItemId) onPickImages;
  final void Function(String subItemId) onPickImagesWithFilePicker;
  final void Function(String subItemId, String imageUrl, int imageIndex)
  onDeleteCurrentImage;
  final void Function(String subItemId, String imageUrl, int imageIndex)
  onCropCurrentImage;
  final void Function(String subItemId, String imageUrl) onShowFullScreenImage;
  final ValueChanged<String> onAddElement;
  final Future<void> Function(int oldIndex, int newIndex)? onReorderSubItems;
  final Future<void> Function(
    String subItemId,
    String elementId,
    int targetOrder,
  )?
  onReorderElements;
  final void Function(
    PricingSubItemModel subItem,
    PricingElementModel element,
    bool newValue,
  )
  onToggleElementVisibility;
  final void Function(String subItemId, String elementId, bool isLocal)
  onDeleteElement;
  final void Function(
    String subItemId,
    String elementId,
    PricingElementModel element,
    LocalElement? localElement,
    bool isLocal,
    PricingItem updatedItem,
  )
  onElementChanged;
  final void Function({
    required PricingSubItemModel subItem,
    required PricingElementModel element,
    required bool isLocal,
    required LocalElement? localElement,
    required bool addNext,
  })
  onElementFieldCompleted;
  final void Function({
    required PricingSubItemModel subItem,
    required PricingElementModel element,
    required bool isLocal,
    required LocalElement? localElement,
    required bool addNext,
  })
  onElementSubmitted;
  final List<PricingElementModel> Function(String subItemId)
  getAllElementsForSubItem;

  @override
  Widget build(BuildContext context) {
    if (item.subItems == null || item.subItems!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'لا توجد فئات فرعية بعد',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Material(color: Colors.transparent, child: child);
          },
        );
      },
      buildDefaultDragHandles: false,
      onReorder: onReorderSubItems ?? (_, __) {},
      children: item.subItems!.asMap().entries.map((entry) {
        final index = entry.key;
        final subItem = entry.value;
        final isSubItemExpanded = expandedSubItems[subItem.id] ?? false;
        final hasSubItemImages = subItem.images.isNotEmpty;
        final allElements = getAllElementsForSubItem(subItem.id);
        final elementRows = allElements.asMap().entries.map((elementEntry) {
          final index = elementEntry.key;
          final element = elementEntry.value;
          final isLocal = element.id.startsWith('temp-');

          LocalElement? localElement;
          if (isLocal) {
            try {
              localElement = localElements[subItem.id]?.firstWhere(
                (e) => e.tempId == element.id,
              );
            } catch (e) {
              localElement = null;
            }
          }

          final isSaving =
              (isLocal &&
                  localElement != null &&
                  (savingElements[element.id] == true)) ||
              (!isLocal && updatingElements[element.id] == true);

          final pricingItem = PricingItem(
            id: element.id,
            description: element.name,
            quantity: element.costType == 'UNIT_BASED'
                ? element.quantity
                : null,
            unitPrice: element.costType == 'UNIT_BASED'
                ? element.unitCost
                : null,
            total: element.calculatedCost,
            costType: element.costType,
          );

          return PricingElementRowShell(
            key: ValueKey(element.id),
            subItemId: subItem.id,
            elementId: element.id,
            index: index,
            element: element,
            isLocal: isLocal,
            isSaving: isSaving,
            canReorderElements: canReorderElements,
            showFinancials: showFinancials,
            isNewRow:
                isLocal &&
                localElement != null &&
                !localElement.hasRequiredData,
            firstFieldFocusNode: isLocal
                ? localElementFocusNodes[element.id]
                : null,
            onToggleVisibility: (value) =>
                onToggleElementVisibility(subItem, element, value),
            onDelete: () => onDeleteElement(subItem.id, element.id, isLocal),
            onChanged: (updatedItem) {
              onElementChanged(
                subItem.id,
                element.id,
                element,
                localElement,
                isLocal,
                updatedItem,
              );
            },
            onFieldCompleted: () => onElementFieldCompleted(
              subItem: subItem,
              element: element,
              isLocal: isLocal,
              localElement: localElement,
              addNext: false,
            ),
            onSubmitted: () => onElementSubmitted(
              subItem: subItem,
              element: element,
              isLocal: isLocal,
              localElement: localElement,
              addNext: true,
            ),
            pricingItem: pricingItem,
          );
        }).toList();

        return PricingSubItemSection(
          key: ValueKey(subItem.id),
          subItemId: subItem.id,
          index: index,
          subItem: subItem,
          isExpanded: isSubItemExpanded,
          hasSubItemImages: hasSubItemImages,
          showFinancials: showFinancials,
          canViewFinancials: canViewFinancials,
          canReorderSubItems: canReorderSubItems,
          totalCost: subItem.totalCost,
          profitAmount: subItem.profitAmount,
          elementRows: elementRows,
          onToggleExpanded: () => onToggleSubItem(subItem.id),
          onToggleVisibility: (value) =>
              onToggleSubItemVisibility(subItem, value),
          onShowMenu: () => onShowSubItemContextMenu(subItem),
          onPickImages: () => onPickImages(subItem.id),
          onPickImagesWithFilePicker: () =>
              onPickImagesWithFilePicker(subItem.id),
          onDeleteCurrentImage: () => onDeleteCurrentImage(
            subItem.id,
            subItem.images[selectedImageIndex[subItem.id] ?? 0],
            selectedImageIndex[subItem.id] ?? 0,
          ),
          onCropCurrentImage: () => onCropCurrentImage(
            subItem.id,
            subItem.images[selectedImageIndex[subItem.id] ?? 0],
            selectedImageIndex[subItem.id] ?? 0,
          ),
          onShowFullScreenImage: () => onShowFullScreenImage(
            subItem.id,
            subItem.images[selectedImageIndex[subItem.id] ?? 0],
          ),
          onReorderElements: (oldIndex, newIndex) async {
            if (onReorderElements == null) return;
            final normalizedNewIndex = oldIndex < newIndex
                ? newIndex - 1
                : newIndex;
            if (oldIndex < 0 ||
                normalizedNewIndex < 0 ||
                oldIndex >= allElements.length ||
                normalizedNewIndex >= allElements.length) {
              return;
            }

            final movedElement = allElements[oldIndex];
            if (movedElement.id.startsWith('temp-')) return;

            final targetOrder =
                allElements
                    .take(normalizedNewIndex)
                    .where((element) => !element.id.startsWith('temp-'))
                    .length +
                1;

            await onReorderElements!(subItem.id, movedElement.id, targetOrder);
          },
          onAddElement: () => onAddElement(subItem.id),
          hasImagesOrUploading:
              subItem.images.isNotEmpty || uploadingImages[subItem.id] == true,
          isUploadingImage: uploadingImages[subItem.id] == true,
          selectedImageIndex: selectedImageIndex,
          deletingImages: deletingImages,
          uploadingImages: uploadingImages,
        );
      }).toList(),
    );
  }
}
