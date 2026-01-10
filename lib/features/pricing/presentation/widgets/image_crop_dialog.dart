import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Dialog for cropping images before upload
/// Supports square (1:1) and free aspect ratio modes
class ImageCropDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final String? fileName;

  const ImageCropDialog({
    super.key,
    required this.imageBytes,
    this.fileName,
  });

  /// Shows the crop dialog and returns the cropped image bytes or null if cancelled
  static Future<Uint8List?> show(
    BuildContext context,
    Uint8List imageBytes, {
    String? fileName,
  }) async {
    return showDialog<Uint8List?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ImageCropDialog(
        imageBytes: imageBytes,
        fileName: fileName,
      ),
    );
  }

  @override
  State<ImageCropDialog> createState() => _ImageCropDialogState();
}

class _ImageCropDialogState extends State<ImageCropDialog> {
  final CropController _cropController = CropController();
  bool _isSquareMode = true;
  bool _isCropping = false;

  void _onCrop() {
    setState(() {
      _isCropping = true;
    });
    _cropController.crop();
  }

  void _onCropped(CropResult result) {
    if (result is CropSuccess) {
      Navigator.of(context).pop(result.croppedImage);
    } else if (result is CropFailure) {
      setState(() {
        _isCropping = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في قص الصورة'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width * 0.8;
    final dialogHeight = screenSize.height * 0.85;

    return Dialog(
      backgroundColor: const Color(0xFF1A1D24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: dialogWidth.clamp(400.0, 800.0),
        height: dialogHeight.clamp(500.0, 700.0),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'قص الصورة',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
                if (widget.fileName != null)
                  Text(
                    widget.fileName!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Aspect ratio toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1217),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF363C4A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModeButton(
                    label: 'مربع 1:1',
                    icon: Icons.crop_square,
                    isSelected: _isSquareMode,
                    onTap: () {
                      if (!_isSquareMode) {
                        setState(() {
                          _isSquareMode = true;
                        });
                        _cropController.aspectRatio = 1.0;
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildModeButton(
                    label: 'حر',
                    icon: Icons.crop_free,
                    isSelected: !_isSquareMode,
                    onTap: () {
                      if (_isSquareMode) {
                        setState(() {
                          _isSquareMode = false;
                        });
                        _cropController.aspectRatio = null;
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Crop area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF363C4A)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Crop(
                    key: ValueKey(_isSquareMode), // Force rebuild when mode changes
                    image: widget.imageBytes,
                    controller: _cropController,
                    onCropped: _onCropped,
                    aspectRatio: _isSquareMode ? 1.0 : null,
                    initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                      size: 0.8,
                      aspectRatio: _isSquareMode ? 1.0 : null,
                    ),
                    maskColor: Colors.black.withValues(alpha: 0.7),
                    baseColor: Colors.black,
                    cornerDotBuilder: (size, edgeAlignment) => Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel button
                OutlinedButton(
                  onPressed: _isCropping ? null : () => Navigator.of(context).pop(null),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: Color(0xFF363C4A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'إلغاء',
                    style: AppTextStyles.buttonLarge.copyWith(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),

                // Crop button
                ElevatedButton(
                  onPressed: _isCropping ? null : _onCrop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isCropping
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.crop, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'قص',
                              style: AppTextStyles.buttonLarge.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
