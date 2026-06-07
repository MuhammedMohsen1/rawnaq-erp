import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/pricing_version_model.dart';
import 'pricing_item_card_support_widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImagesOrUploading)
            Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: Container(
                margin: const EdgeInsets.only(
                  right: 12,
                  top: 12,
                  bottom: 12,
                  left: 12,
                ),
                constraints: const BoxConstraints(
                  maxWidth: 200,
                  minWidth: 100,
                  maxHeight: 300,
                ),
                child: PricingSubItemImagesPanel(
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
                ),
              ),
            ),
          Expanded(
            flex: 2,
            child: Padding(
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
                    TextField(
                      controller: descriptionController,
                      focusNode: descriptionFocusNode,
                      onChanged: onDescriptionChanged,
                      minLines: 2,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                      decoration: InputDecoration(
                        labelText: 'وصف البند الفرعي',
                        hintText: 'اكتب وصف البند الفرعي',
                        labelStyle: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF202632),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF363C4A),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          if (showFinancials) ...[
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
                            return Material(
                              color: Colors.transparent,
                              child: child,
                            );
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
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF4B5563)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: onAddElement,
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
                            'إضافة عنصر',
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
                  if (showFinancials) const SizedBox(height: 16),
                  if (showFinancials)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 17.22,
                        horizontal: 20,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFF363C4A)),
                        ),
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
            ),
          ),
        ],
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
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.cardBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Text(
                  subItem.images.isEmpty
                      ? '0/0 Photos'
                      : '${selectedImageIndex[subItem.id] != null ? (selectedImageIndex[subItem.id]!.clamp(0, subItem.images.length - 1) + 1) : 1}/${subItem.images.length} Photos',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isUploadingImage)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPickImages,
                      onLongPress: onPickImagesWithFilePicker,
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.add_photo_alternate,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: subItem.images.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPickImages,
        onLongPress: onPickImagesWithFilePicker,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'إضافة صورة',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
