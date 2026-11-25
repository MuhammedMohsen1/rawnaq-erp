import 'package:rawnaq/core/utils/arabic_number_input_formatter.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/pricing_version_model.dart';
import 'profit_margin_input.dart';
import 'pricing_item_card_support_widgets.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

class PricingSubItemBody extends StatelessWidget {
  const PricingSubItemBody({
    super.key,
    required this.subItem,
    required this.showFinancials,
    required this.hasImagesOrUploading,
    required this.isUploadingImage,
    required this.selectedImageIndex,
    required this.deletingImages,
    required this.uploadingImages,
    required this.onPickImages,
    required this.onPickImagesWithFilePicker,
    required this.onDeleteCurrentImage,
    required this.onCropCurrentImage,
    required this.onShowFullScreenImage,
    required this.elementRows,
    required this.onReorderElements,
    required this.onAddElement,
    this.descriptionController,
    this.descriptionFocusNode,
    this.onDescriptionChanged,
    this.profitMarginController,
    this.onProfitMarginChanged,
    this.onProfitMarginEditingComplete,
  });

  final PricingSubItemModel subItem;
  final bool showFinancials;
  final bool hasImagesOrUploading;
  final bool isUploadingImage;
  final Map<String, int> selectedImageIndex;
  final Map<String, bool> deletingImages;
  final Map<String, bool> uploadingImages;
  final VoidCallback onPickImages;
  final VoidCallback onPickImagesWithFilePicker;
  final VoidCallback onDeleteCurrentImage;
  final VoidCallback onCropCurrentImage;
  final VoidCallback onShowFullScreenImage;
  final List<Widget> elementRows;
  final ReorderCallback onReorderElements;
  final VoidCallback onAddElement;
  final TextEditingController? descriptionController;
  final FocusNode? descriptionFocusNode;
  final ValueChanged<String>? onDescriptionChanged;
  final TextEditingController? profitMarginController;
  final ValueChanged<String>? onProfitMarginChanged;
  final VoidCallback? onProfitMarginEditingComplete;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final light = colors.brightness == Brightness.light;
    final addForeground = light ? AppColors.white : colors.textSecondary;
    final images = PricingSubItemImagesPanel(
      subItem: subItem,
      showFinancials: showFinancials,
      isUploadingImage: isUploadingImage,
      selectedImageIndex: selectedImageIndex,
      deletingImages: deletingImages,
      uploadingImages: uploadingImages,
      onPickImages: onPickImages,
      onPickImagesWithFilePicker: onPickImagesWithFilePicker,
      onDeleteCurrentImage: onDeleteCurrentImage,
      onCropCurrentImage: onCropCurrentImage,
      onShowFullScreenImage: onShowFullScreenImage,
    );
    final content = Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasImagesOrUploading) ...[
            PricingSubItemAddImagesButton(
              onPickImages: onPickImages,
              onPickImagesWithFilePicker: onPickImagesWithFilePicker,
            ),
            const SizedBox(height: 12),
          ],
          if (descriptionController != null &&
              descriptionFocusNode != null) ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final showCompactProfitInput =
                    profitMarginController != null &&
                    constraints.maxWidth >= 560;

                final descriptionField = Center(
                  child: TextField(
                    inputFormatters: const [ArabicNumberInputFormatter()],
                    controller: descriptionController,
                    focusNode: descriptionFocusNode,
                    onChanged: onDescriptionChanged,
                    minLines: 2,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    style: AppTextStyles.of(context).bodyMedium.copyWith(
                      color: AppColors.of(context).textPrimary,
                      height: 1.35,
                    ),
                    decoration: InputDecoration(
                      labelText: 'وصف البند الفرعي',
                      hintText: 'اكتب وصف البند الفرعي',
                      labelStyle: AppTextStyles.of(context).caption.copyWith(
                        color: AppColors.of(context).textSecondary,
                      ),
                      hintStyle: AppTextStyles.of(context).bodySmall.copyWith(
                        color: AppColors.of(context).textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.of(context).inputBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.of(context).border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.of(context).primary,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );

                if (showCompactProfitInput) {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: descriptionField),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 150,
                          child: ProfitMarginInput(
                            controller: profitMarginController!,
                            onChanged: onProfitMarginChanged ?? (_) {},
                            onEditingComplete: onProfitMarginEditingComplete,
                            compact: true,
                            fillHeight: true,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    descriptionField,
                    if (profitMarginController != null) ...[
                      const SizedBox(height: 12),
                      ProfitMarginInput(
                        controller: profitMarginController!,
                        onChanged: onProfitMarginChanged ?? (_) {},
                        onEditingComplete: onProfitMarginEditingComplete,
                        compact: true,
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
          ],
          if (elementRows.isNotEmpty) ...[
            Container(
              height: 41.5,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'وصف العنصر',
                      style: AppTextStyles.of(context).caption.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.of(context).textMuted,
                      ),
                    ),
                  ),
                  if (showFinancials) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'التكلفة (دينار)',
                        style: AppTextStyles.of(context).caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.of(context).textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorder: onReorderElements,
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    return Material(color: Colors.transparent, child: child);
                  },
                );
              },
              children: elementRows,
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'لا توجد فئات فرعية بعد',
                  style: AppTextStyles.of(
                    context,
                  ).bodyMedium.copyWith(color: AppColors.of(context).textMuted),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: light ? colors.buttonPrimary : null,
              border: light ? null : Border.all(color: colors.textDisabled),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: onAddElement,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: addForeground, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'إضافة عنصر',
                      style: AppTextStyles.of(context).bodyMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: addForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showFinancials) const SizedBox(height: 16),
          if (showFinancials)
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 17.22,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.of(context).border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'المجموع الفرعي',
                      style: AppTextStyles.of(context).bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.of(context).textSecondary,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'KD',
                        style: AppTextStyles.of(context).bodyMedium.copyWith(
                          fontSize: 14,
                          color: AppColors.of(context).textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PricingFormattedNumber(
                        value: subItem.totalCost,
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
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 570) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasImagesOrUploading)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(height: 260, child: images),
                  ),
                content,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImagesOrUploading)
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(
                      maxWidth: 200,
                      minWidth: 100,
                      maxHeight: 300,
                    ),
                    child: images,
                  ),
                ),
              Expanded(flex: 2, child: content),
            ],
          );
        },
      ),
    );
  }
}

class PricingSubItemImagesPanel extends StatelessWidget {
  const PricingSubItemImagesPanel({
    super.key,
    required this.subItem,
    required this.showFinancials,
    required this.isUploadingImage,
    required this.selectedImageIndex,
    required this.deletingImages,
    required this.uploadingImages,
    required this.onPickImages,
    required this.onPickImagesWithFilePicker,
    required this.onDeleteCurrentImage,
    required this.onCropCurrentImage,
    required this.onShowFullScreenImage,
  });

  final PricingSubItemModel subItem;
  final bool showFinancials;
  final bool isUploadingImage;
  final Map<String, int> selectedImageIndex;
  final Map<String, bool> deletingImages;
  final Map<String, bool> uploadingImages;
  final VoidCallback onPickImages;
  final VoidCallback onPickImagesWithFilePicker;
  final VoidCallback onDeleteCurrentImage;
  final VoidCallback onCropCurrentImage;
  final VoidCallback onShowFullScreenImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.of(context).border),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.of(context).cardBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.of(context).border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ArabicNumberTransformer.transform(
                      subItem.images.isEmpty
                          ? '0/0 Photos'
                          : '${selectedImageIndex[subItem.id] != null ? (selectedImageIndex[subItem.id]!.clamp(0, subItem.images.length - 1) + 1) : 1}/${subItem.images.length} Photos',
                    ),
                    style: AppTextStyles.of(
                      context,
                    ).bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 4),
                if (isUploadingImage)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.of(context).primary,
                    ),
                  )
                else
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPickImages,
                      onLongPress: onPickImagesWithFilePicker,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.add_photo_alternate,
                          size: 18,
                          color: AppColors.of(context).primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: subItem.images.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.of(context).primary,
                    ),
                  )
                : PricingImagePreview(
                    subItem: subItem,
                    showFinancials: showFinancials,
                    selectedImageIndex: selectedImageIndex,
                    deletingImages: deletingImages,
                    uploadingImages: uploadingImages,
                    onDeleteCurrentImage: onDeleteCurrentImage,
                    onCropCurrentImage: onCropCurrentImage,
                    onShowFullScreenImage: onShowFullScreenImage,
                    onPickImages: onPickImages,
                    onPickImagesWithFilePicker: onPickImagesWithFilePicker,
                  ),
          ),
        ],
      ),
    );
  }
}

class PricingSubItemAddImagesButton extends StatelessWidget {
  const PricingSubItemAddImagesButton({
    super.key,
    required this.onPickImages,
    required this.onPickImagesWithFilePicker,
  });

  final VoidCallback onPickImages;
  final VoidCallback onPickImagesWithFilePicker;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final light = colors.brightness == Brightness.light;
    final foreground = light ? AppColors.white : colors.textSecondary;
    return Material(
      color: light ? colors.buttonPrimary : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPickImages,
        onLongPress: onPickImagesWithFilePicker,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: light ? null : Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: foreground,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'إضافة صورة',
                  style: AppTextStyles.of(context).bodyMedium.copyWith(
                    color: foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
