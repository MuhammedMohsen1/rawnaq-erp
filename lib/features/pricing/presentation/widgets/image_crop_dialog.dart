import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Dialog for cropping images before upload.
/// Default:
/// - Freeform crop.
/// - Initial crop rect covers the full displayed image.
/// - Confirm returns cropped bytes.
class ImageCropDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final String? fileName;

  const ImageCropDialog({super.key, required this.imageBytes, this.fileName});

  static Future<Uint8List?> show(
    BuildContext context,
    Uint8List imageBytes, {
    String? fileName,
  }) {
    return showDialog<Uint8List?>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          ImageCropDialog(imageBytes: imageBytes, fileName: fileName),
    );
  }

  @override
  State<ImageCropDialog> createState() => _ImageCropDialogState();
}

class _ImageCropDialogState extends State<ImageCropDialog> {
  final CropController _cropController = CropController();

  bool _isCropping = false;

  void _onCrop() {
    if (_isCropping) return;

    setState(() {
      _isCropping = true;
    });

    _cropController.crop();
  }

  void _onCropped(CropResult result) {
    if (!mounted) return;

    if (result is CropSuccess) {
      Navigator.of(context).pop(result.croppedImage);
      return;
    }

    if (result is CropFailure) {
      setState(() {
        _isCropping = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('فشل في قص الصورة'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _close() {
    if (_isCropping) return;
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: const Color(0xFF1A1D24),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: (screenSize.width * 0.9).clamp(360.0, 920.0),
        height: (screenSize.height * 0.9).clamp(520.0, 820.0),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildHint(),
            const SizedBox(height: 12),
            Expanded(child: _buildCropArea()),
            const SizedBox(height: 16),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
          child: const Icon(
            Icons.crop_free,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'قص ورفع الصورة',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.fileName?.trim().isNotEmpty == true
                    ? widget.fileName!
                    : 'Freeform - الحجم الكامل للصورة',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _isCropping ? null : _close,
          tooltip: 'إغلاق',
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1217),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF363C4A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'الصورة تبدأ بالحجم الكامل. حرّك الزوايا فقط إذا كنت تريد قص جزء معين.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropArea() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF363C4A)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Crop(
          key: ValueKey(widget.imageBytes.hashCode),
          image: widget.imageBytes,
          controller: _cropController,
          onCropped: _onCropped,

          // Critical:
          // null = freeform. Do not set this to 1.0.
          aspectRatio: null,

          // Critical for crop_your_image 2.x:
          // This replaces old initialSize.
          // It starts the crop rect as the full displayed image, not square.
          initialRectBuilder: InitialRectBuilder.withBuilder((
            viewportRect,
            imageRect,
          ) {
            return imageRect;
          }),

          withCircleUi: false,
          interactive: false,
          baseColor: Colors.black,
          maskColor: Colors.black.withValues(alpha: 0.62),
          radius: 0,

          progressIndicator: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),

          cornerDotBuilder: (size, edgeAlignment) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'عند التأكيد سيتم استخدام الصورة الحالية ورفعها مباشرة.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _isCropping ? null : _close,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: Color(0xFF363C4A)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          ),
          icon: const Icon(Icons.close, size: 18),
          label: Text(
            'إلغاء',
            style: AppTextStyles.buttonLarge.copyWith(fontSize: 14),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: _isCropping ? null : _onCrop,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.background,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          ),
          icon: _isCropping
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.cloud_upload_outlined, size: 18),
          label: Text(
            _isCropping ? 'جاري التجهيز...' : 'قص ورفع',
            style: AppTextStyles.buttonLarge.copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
