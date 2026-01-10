import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Image gallery widget for pricing sub-items
/// Displays images with carousel navigation and delete functionality
class PricingImageGallery extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  final bool isDeleting;
  final Function(int index) onImageSelected;
  final Function(String imageUrl) onDeleteImage;
  final Function(String imageUrl) onViewFullScreen;

  const PricingImageGallery({
    super.key,
    required this.images,
    required this.selectedIndex,
    this.isDeleting = false,
    required this.onImageSelected,
    required this.onDeleteImage,
    required this.onViewFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const _EmptyGallery();
    }

    // Ensure index is within bounds
    final safeIndex =
        selectedIndex >= images.length ? images.length - 1 : selectedIndex;
    final currentImage = images[safeIndex];

    return Column(
      children: [
        // Main Image Display
        Expanded(
          child: _MainImageDisplay(
            imageUrl: currentImage,
            isDeleting: isDeleting,
            onDelete: () => onDeleteImage(currentImage),
            onViewFullScreen: () => onViewFullScreen(currentImage),
          ),
        ),
        // Thumbnails Row
        if (images.length > 1)
          _ThumbnailsRow(
            images: images,
            selectedIndex: safeIndex,
            onImageSelected: onImageSelected,
          ),
      ],
    );
  }
}

/// Main image display with delete and fullscreen buttons
class _MainImageDisplay extends StatelessWidget {
  final String imageUrl;
  final bool isDeleting;
  final VoidCallback onDelete;
  final VoidCallback onViewFullScreen;

  const _MainImageDisplay({
    required this.imageUrl,
    required this.isDeleting,
    required this.onDelete,
    required this.onViewFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            // Image
            Image.network(
              imageUrl,
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
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
            // Delete button
            Positioned(
              top: 8,
              right: 8,
              child: _IconButton(
                onTap: isDeleting ? null : onDelete,
                icon: isDeleting
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
            // Fullscreen button
            Positioned(
              bottom: 8,
              right: 8,
              child: _IconButton(
                onTap: onViewFullScreen,
                icon: const Icon(
                  Icons.fullscreen,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon button with rounded background
class _IconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget icon;

  const _IconButton({
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: icon,
        ),
      ),
    );
  }
}

/// Thumbnails row for image navigation
class _ThumbnailsRow extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  final Function(int index) onImageSelected;

  const _ThumbnailsRow({
    required this.images,
    required this.selectedIndex,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageUrl = images[index];
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onImageSelected(index),
            child: Container(
              width: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFF363C4A),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  imageUrl,
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
            ),
          );
        },
      ),
    );
  }
}

/// Empty gallery state
class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A313D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF363C4A)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 8),
            Text(
              'لا توجد صور',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
