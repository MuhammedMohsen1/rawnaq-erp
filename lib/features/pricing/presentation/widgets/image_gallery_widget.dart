import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ImageGalleryWidget extends StatelessWidget {
  final List<String> imageUrls;
  final int selectedIndex;
  final ValueChanged<int>? onImageSelected;
  final VoidCallback? onAddImage;

  const ImageGalleryWidget({
    super.key,
    required this.imageUrls,
    this.selectedIndex = 0,
    this.onImageSelected,
    this.onAddImage,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return _buildEmptyGallery();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Image
        Container(
          height: 339.78,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF363C4A)),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrls[selectedIndex],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.inputBackground,
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.textMuted,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Image Counter Overlay
              Positioned(
                top: 9,
                left: 9,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${selectedIndex + 1}/${imageUrls.length} Photos',
                    style: const TextStyle(
                      fontFamily: 'Menlo',
                      fontSize: 11.8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Thumbnail Strip
        SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length + (onAddImage != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == imageUrls.length && onAddImage != null) {
                return _buildAddImageButton();
              }
              return _buildThumbnail(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(int index) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onImageSelected?.call(index),
      child: Container(
        width: 64,
        height: 64,
        margin: EdgeInsets.only(right: index < imageUrls.length - 1 ? 8 : 0),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF135BEC) : const Color(0xFF363C4A),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Image.network(
                imageUrls[index],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.inputBackground,
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.textMuted,
                      size: 24,
                    ),
                  );
                },
              ),
              if (!isSelected)
                Container(
                  color: Colors.black.withOpacity(0.4),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF4B5563),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onAddImage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
              color: AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGallery() {
    return Container(
      height: 339.78,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF363C4A)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_outlined,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد صور',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            if (onAddImage != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onAddImage,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('إضافة صورة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardBackground,
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

