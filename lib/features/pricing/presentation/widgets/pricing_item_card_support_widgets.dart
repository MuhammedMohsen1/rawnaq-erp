import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/pricing_version_model.dart';

class PricingFormattedNumber extends StatelessWidget {
  final double value;
  final bool showFinancials;
  final double fontSize;
  final FontWeight fontWeight;

  const PricingFormattedNumber({
    super.key,
    required this.value,
    required this.showFinancials,
    this.fontSize = 20,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    if (!showFinancials) {
      return Text(
        '••••',
        style: TextStyle(
          fontFamily: 'Menlo',
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: AppColors.textPrimary,
        ),
      );
    }

    final parts = value.toStringAsFixed(3).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];
    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Menlo',
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: AppColors.textPrimary,
        ),
        children: [
          TextSpan(text: formattedInteger),
          TextSpan(
            text: '.$decimalPart',
            style: TextStyle(fontSize: fontSize * 0.7, fontWeight: fontWeight),
          ),
        ],
      ),
    );
  }
}

class PricingStatChip extends StatelessWidget {
  final double value;
  final Color color;
  final String suffix;
  final bool showFinancials;

  const PricingStatChip({
    super.key,
    required this.value,
    required this.color,
    this.suffix = 'KD',
    required this.showFinancials,
  });

  @override
  Widget build(BuildContext context) {
    final formattedValue = !showFinancials
        ? '••••'
        : suffix == '%'
        ? value.toStringAsFixed(1)
        : value.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$formattedValue $suffix',
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PricingStatCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool showFinancials;

  const PricingStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.showFinancials,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Total $label',
      child: Container(
        constraints: const BoxConstraints(minWidth: 66),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Text(
          '${showFinancials ? value.toStringAsFixed(2) : '••••'} KD',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class PricingSubItemStats extends StatelessWidget {
  final PricingSubItemModel subItem;
  final bool showFinancials;
  final bool canViewFinancials;

  const PricingSubItemStats({
    super.key,
    required this.subItem,
    required this.showFinancials,
    required this.canViewFinancials,
  });

  @override
  Widget build(BuildContext context) {
    if (!showFinancials || !canViewFinancials) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PricingStatCard(
          label: 'تكلفة',
          value: subItem.totalCost,
          color: AppColors.delete,
          showFinancials: showFinancials,
        ),
        const SizedBox(width: 4),
        PricingStatCard(
          label: 'إيرادات',
          value: subItem.profitAmount,
          color: const Color(0xFF10B981),
          showFinancials: showFinancials,
        ),
        const SizedBox(width: 4),
        PricingStatChip(
          value: subItem.totalCost > 0
              ? (subItem.profitAmount / subItem.totalCost * 100)
              : 0.0,
          color: const Color(0xFFF59E0B),
          suffix: '%',
          showFinancials: showFinancials,
        ),
      ],
    );
  }
}

class PricingImagePreview extends StatefulWidget {
  final PricingSubItemModel subItem;
  final bool showFinancials;
  final Map<String, int> selectedImageIndex;
  final Map<String, bool> deletingImages;
  final Map<String, bool> uploadingImages;
  final VoidCallback onDeleteCurrentImage;
  final VoidCallback onCropCurrentImage;
  final VoidCallback onShowFullScreenImage;
  final VoidCallback onPickImages;
  final VoidCallback onPickImagesWithFilePicker;

  const PricingImagePreview({
    super.key,
    required this.subItem,
    required this.showFinancials,
    required this.selectedImageIndex,
    required this.deletingImages,
    required this.uploadingImages,
    required this.onDeleteCurrentImage,
    required this.onCropCurrentImage,
    required this.onShowFullScreenImage,
    required this.onPickImages,
    required this.onPickImagesWithFilePicker,
  });

  @override
  State<PricingImagePreview> createState() => _PricingImagePreviewState();
}

class _PricingImagePreviewState extends State<PricingImagePreview> {
  @override
  Widget build(BuildContext context) {
    final imageCount = widget.subItem.images.length;

    if (imageCount == 0) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF363C4A)),
          color: const Color(0xFF161A22),
        ),
        child: const Center(
          child: Text(
            'لا توجد صور للمعاينة',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    widget.selectedImageIndex.putIfAbsent(widget.subItem.id, () => 0);
    final currentIndex = widget.selectedImageIndex[widget.subItem.id] ?? 0;
    final safeIndex = currentIndex >= imageCount
        ? imageCount - 1
        : currentIndex;
    final currentImage = widget.subItem.images[safeIndex];
    final isDeleting = widget.deletingImages[currentImage] == true;
    final isUploading = widget.uploadingImages[widget.subItem.id] == true;

    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF363C4A)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      currentImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF2A313D),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 64,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFF2A313D),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (widget.showFinancials)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${safeIndex + 1} / $imageCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (isDeleting)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                      child: InkWell(
                        onTap: isDeleting ? null : widget.onDeleteCurrentImage,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: isDeleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 48,
                    child: Material(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                      child: InkWell(
                        onTap: isUploading ? null : widget.onCropCurrentImage,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.crop,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                      child: InkWell(
                        onTap: widget.onShowFullScreenImage,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.fullscreen,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (imageCount > 1)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageCount,
              itemBuilder: (context, index) {
                final imageUrl = widget.subItem.images[index];
                final isSelected = index == safeIndex;
                final isThumbnailDeleting =
                    widget.deletingImages[imageUrl] == true;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.selectedImageIndex[widget.subItem.id] = index;
                    });
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFF363C4A),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                            imageUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF2A313D),
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                              );
                            },
                          ),
                        ),
                        if (isThumbnailDeleting)
                          Container(
                            color: Colors.black.withOpacity(0.4),
                            child: const Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.5),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isUploading ? null : widget.onPickImages,
              onLongPress: isUploading
                  ? null
                  : widget.onPickImagesWithFilePicker,
              borderRadius: BorderRadius.circular(8),
              child: isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 24, color: AppColors.primary),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
