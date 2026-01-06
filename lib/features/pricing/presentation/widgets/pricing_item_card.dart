import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/datasources/pricing_api_datasource.dart';
import '../../data/models/pricing_version_model.dart';
import '../../domain/entities/pricing_item.dart';
import 'pricing_table_row.dart';

/// Local element that hasn't been saved to backend yet
class LocalElement {
  final String tempId;
  final String subItemId;
  String name;
  String? description;
  String costType;
  double? totalCost;
  double? unitCost;
  double? quantity;
  bool isCompleted;
  DateTime? lastModified;

  LocalElement({
    required this.tempId,
    required this.subItemId,
    this.name = '',
    this.description,
    this.costType = 'UNIT_BASED',
    this.totalCost,
    this.unitCost,
    this.quantity,
    this.isCompleted = false,
    this.lastModified,
  });

  bool get hasRequiredData {
    // Name must be non-empty and have at least 2 characters
    if (name.trim().isEmpty || name.trim().length < 2) return false;

    if (costType == 'UNIT_BASED') {
      // Both unitCost and quantity must be valid positive numbers
      return unitCost != null &&
          quantity != null &&
          unitCost! > 0 &&
          quantity! > 0 &&
          unitCost!.isFinite &&
          quantity!.isFinite;
    } else {
      // Total cost must be valid positive number
      return totalCost != null && totalCost! > 0 && totalCost!.isFinite;
    }
  }
}

class PricingItemCard extends StatefulWidget {
  final String projectId;
  final int version;
  final PricingItemModel item;
  final String?
  pricingStatus; // DRAFT, PENDING_APPROVAL, APPROVED, PROFIT_PENDING, etc.
  final ValueChanged<PricingItemModel>? onItemChanged;
  final ValueChanged<PricingSubItemModel>?
  onSubItemChanged; // For profit margin updates
  final VoidCallback? onAddSubItem;
  final bool initialIsExpanded;
  final Map<String, bool> initialSubItemExpandedStates;
  final ValueChanged<bool>? onExpandedChanged;
  final ValueChanged<Map<String, bool>>? onSubItemExpandedChanged;
  final VoidCallback? onItemDeleted;
  final ValueChanged<String>? onSubItemDeleted; // subItemId

  const PricingItemCard({
    super.key,
    required this.projectId,
    required this.version,
    required this.item,
    this.pricingStatus,
    this.onItemChanged,
    this.onSubItemChanged,
    this.onAddSubItem,
    this.initialIsExpanded = true,
    this.initialSubItemExpandedStates = const {},
    this.onExpandedChanged,
    this.onSubItemExpandedChanged,
    this.onItemDeleted,
    this.onSubItemDeleted,
  });

  @override
  State<PricingItemCard> createState() => _PricingItemCardState();
}

class _PricingItemCardState extends State<PricingItemCard> {
  final _apiDataSource = PricingApiDataSource();
  final _imagePicker = ImagePicker();
  late bool _isExpanded;
  final Map<String, bool> _expandedSubItems = {};
  final Map<String, List<LocalElement>> _localElements =
      {}; // subItemId -> List<LocalElement>
  final Map<String, bool> _savingElements = {}; // tempId -> isSaving
  final Map<String, Timer?> _saveTimers = {}; // tempId -> debounce timer
  final Map<String, bool> _updatingElements = {}; // elementId -> isUpdating
  final Map<String, Timer?> _updateTimers = {}; // elementId -> debounce timer
  final Map<String, PricingItem> _pendingUpdates =
      {}; // elementId -> latest PricingItem values
  final Map<String, bool> _uploadingImages = {}; // subItemId -> isUploading
  final Map<String, bool> _deletingImages = {}; // imageUrl -> isDeleting
  final Map<String, double> _profitMargins =
      {}; // subItemId -> profitMargin (for APPROVED status)
  final Map<String, TextEditingController> _profitControllers =
      {}; // subItemId -> TextEditingController for profit margin input
  final Map<String, int> _selectedImageIndex =
      {}; // subItemId -> selected image index
  bool _isRestoringState =
      false; // Flag to prevent state reset during restoration

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialIsExpanded;
    // Initialize sub-items from parent-provided states
    if (widget.item.subItems != null) {
      for (var subItem in widget.item.subItems!) {
        _expandedSubItems[subItem.id] =
            widget.initialSubItemExpandedStates[subItem.id] ?? false;
        _localElements[subItem.id] = [];
        // Initialize profit margin controllers
        if (widget.pricingStatus?.toUpperCase() == 'APPROVED') {
          _profitMargins[subItem.id] = subItem.profitMargin;
          _profitControllers[subItem.id] = TextEditingController(
            text: subItem.profitMargin.toStringAsFixed(2),
          );
        }
      }
    }
  }

  @override
  void didUpdateWidget(PricingItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When widget updates (new data from backend), sync with parent-provided states
    if (_isRestoringState) {
      return; // Skip state updates during restoration
    }

    // Update main expanded state from parent if changed
    if (widget.initialIsExpanded != _isExpanded) {
      _isExpanded = widget.initialIsExpanded;
    }

    // Update sub-item expanded states from parent
    if (widget.item.subItems != null) {
      for (var subItem in widget.item.subItems!) {
        final parentState =
            widget.initialSubItemExpandedStates[subItem.id] ?? false;
        if (!_expandedSubItems.containsKey(subItem.id) ||
            _expandedSubItems[subItem.id] != parentState) {
          _expandedSubItems[subItem.id] = parentState;
        }
        // Preserve local elements for existing sub-items
        if (!_localElements.containsKey(subItem.id)) {
          _localElements[subItem.id] = [];
        }
      }
    }
  }

  @override
  void dispose() {
    // Dispose profit margin controllers
    for (var controller in _profitControllers.values) {
      controller.dispose();
    }
    _profitControllers.clear();
    // Cancel all pending save timers
    for (var timer in _saveTimers.values) {
      timer?.cancel();
    }
    _saveTimers.clear();
    // Cancel all pending update timers
    for (var timer in _updateTimers.values) {
      timer?.cancel();
    }
    _updateTimers.clear();
    super.dispose();
  }

  String _formatNumberWithDecimals(double value) {
    // Format number with 3 decimals and add thousand separators
    final parts = value.toStringAsFixed(3).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    // Add thousand separators to integer part
    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return '$formattedInteger.$decimalPart';
  }

  Widget _buildFormattedNumber(
    double value, {
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    // Format number with 3 decimals and add thousand separators
    final parts = value.toStringAsFixed(3).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    // Add thousand separators to integer part
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
            style: TextStyle(
              fontSize: fontSize * 0.7, // Smaller font for decimals
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildCostTextSpans(double value, {double fontSize = 12}) {
    // Format number with 3 decimals and add thousand separators
    final parts = value.toStringAsFixed(3).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    // Add thousand separators to integer part
    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return [
      const TextSpan(text: 'د.ك '), // KD at the beginning (opposite direction)
      TextSpan(text: formattedInteger),
      TextSpan(
        text: '.$decimalPart',
        style: TextStyle(fontSize: fontSize * 0.7), // Smaller font for decimals
      ),
    ];
  }

  void _toggleSubItem(String subItemId) {
    setState(() {
      _expandedSubItems[subItemId] = !(_expandedSubItems[subItemId] ?? false);
    });
    // Notify parent of state change
    widget.onSubItemExpandedChanged?.call(
      Map<String, bool>.from(_expandedSubItems),
    );
  }

  Future<void> _uploadImages(String subItemId) async {
    print('_uploadImages called for subItem: $subItemId');
    try {
      setState(() {
        _uploadingImages[subItemId] = true;
      });

      List<String> imagePaths = [];
      List<MapEntry<String, List<int>>>? imageBytesList;

      // Use file_picker for desktop/web, image_picker for mobile
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux) {
        // Desktop/Web: Use file_picker
        print('Using file_picker for desktop/web platform...');
        print('Platform: ${defaultTargetPlatform}, kIsWeb: $kIsWeb');
        try {
          print('Calling FilePicker.platform.pickFiles...');

          // Small delay to ensure UI is ready
          await Future.delayed(const Duration(milliseconds: 50));

          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: true,
            withData: kIsWeb, // Only load data for web
            dialogTitle: 'اختر الصور',
          );

          print(
            'FilePicker returned, result is ${result != null ? "not null" : "null"}',
          );

          print('FilePicker result: ${result != null ? "not null" : "null"}');

          if (result == null) {
            print('User canceled file picker or no files selected');
            setState(() {
              _uploadingImages[subItemId] = false;
            });
            return;
          }

          print('Number of files: ${result.files.length}');

          if (result.files.isNotEmpty) {
            imageBytesList = [];
            for (var file in result.files) {
              print(
                'Processing file: ${file.name}, path: ${file.path}, has bytes: ${file.bytes != null}',
              );
              if (file.path != null && !kIsWeb) {
                // Desktop: use file path
                imagePaths.add(file.path!);
                print('Added file path: ${file.path}');
              } else if (file.bytes != null && kIsWeb) {
                // Web: use bytes
                final fileName = file.name;
                imageBytesList.add(MapEntry(fileName, file.bytes!));
                print(
                  'Added file from web: $fileName (${file.bytes!.length} bytes)',
                );
              } else if (file.path != null && kIsWeb) {
                // Web with path (shouldn't happen but handle it)
                print(
                  'Warning: Web file has path instead of bytes: ${file.path}',
                );
              }
            }
            print(
              'Picked ${imagePaths.length + imageBytesList.length} images using file_picker',
            );
          } else {
            print('No files in result');
          }
        } catch (e, stackTrace) {
          print('file_picker failed with error: $e');
          print('Stack trace: $stackTrace');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل فتح نافذة اختيار الملفات: $e'),
                duration: const Duration(seconds: 4),
              ),
            );
          }
          setState(() {
            _uploadingImages[subItemId] = false;
          });
          return;
        }
      } else {
        // Mobile: Use image_picker
        print('Using image_picker for mobile platform...');
        List<XFile> pickedFiles = [];
        try {
          pickedFiles = await _imagePicker.pickMultiImage();
          print('Picked ${pickedFiles.length} images using image_picker');
        } catch (e) {
          print('pickMultiImage failed: $e, trying single image pick...');
          // Fallback to single image
          try {
            final singleFile = await _imagePicker.pickImage(
              source: ImageSource.gallery,
            );
            if (singleFile != null) {
              pickedFiles = [singleFile];
              print('Picked single image: ${singleFile.path}');
            }
          } catch (e2) {
            print('Single image pick also failed: $e2');
            throw Exception('Failed to pick images: $e2');
          }
        }

        // Convert XFile to file paths
        imagePaths = pickedFiles.map((file) => file.path).toList();
      }

      if (imagePaths.isEmpty &&
          (imageBytesList == null || imageBytesList.isEmpty)) {
        print('No images selected');
        setState(() {
          _uploadingImages[subItemId] = false;
        });
        return;
      }

      // Upload images
      await _apiDataSource.uploadSubItemImages(
        widget.projectId,
        widget.version,
        widget.item.id,
        subItemId,
        imagePaths,
        imageBytes: imageBytesList,
      );

      // Refresh data to show new images
      try {
        final updatedVersion = await _apiDataSource.getPricingVersion(
          widget.projectId,
          widget.version,
        );
        final updatedItem = updatedVersion.items?.firstWhere(
          (i) => i.id == widget.item.id,
        );

        if (updatedItem != null && mounted) {
          widget.onItemChanged?.call(updatedItem);
        }
      } catch (e) {
        // If refresh fails, still show success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم رفع الصور ولكن فشل تحديث البيانات: ${e.toString()}',
              ),
            ),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفع الصور بنجاح'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        String errorMessage = 'فشل رفع الصور: ${e.toString()}';

        // Provide more user-friendly error messages
        if (e.toString().contains('NotFoundException') ||
            e.toString().contains('NOT_FOUND')) {
          errorMessage =
              'لا يمكن رفع الصور. يرجى التحقق من أن:\n'
              '1. المشروع موجود\n'
              '2. إصدار التسعير في حالة "مسودة" (DRAFT)\n'
              '3. الفئة والفئة الفرعية موجودة في هذا الإصدار';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      // Print error for debugging
      print('Error uploading images: $e');
      print('Stack trace: $stackTrace');
    } finally {
      if (mounted) {
        setState(() {
          _uploadingImages[subItemId] = false;
        });
      }
    }
  }

  Future<void> _deleteImage(String subItemId, String imageUrl) async {
    print('_deleteImage called for subItem: $subItemId, imageUrl: $imageUrl');
    try {
      setState(() {
        _deletingImages[imageUrl] = true;
      });

      // Delete image
      await _apiDataSource.deleteSubItemImage(
        widget.projectId,
        widget.version,
        widget.item.id,
        subItemId,
        imageUrl,
      );

      // Refresh data to show updated images
      try {
        final updatedVersion = await _apiDataSource.getPricingVersion(
          widget.projectId,
          widget.version,
        );
        final updatedItem = updatedVersion.items?.firstWhere(
          (i) => i.id == widget.item.id,
        );

        if (updatedItem != null && mounted) {
          // Reset selected index if needed
          final subItem = updatedItem.subItems?.firstWhere(
            (si) => si.id == subItemId,
            orElse: () => updatedItem.subItems!.first,
          );
          if (subItem != null) {
            final currentIndex = _selectedImageIndex[subItemId] ?? 0;
            if (currentIndex >= (subItem.images.length)) {
              setState(() {
                _selectedImageIndex[subItemId] = subItem.images.isEmpty
                    ? 0
                    : subItem.images.length - 1;
              });
            }
          }
          widget.onItemChanged?.call(updatedItem);
        }
      } catch (e) {
        // If refresh fails, still show success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم حذف الصورة ولكن فشل تحديث البيانات: ${e.toString()}',
              ),
            ),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الصورة بنجاح'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حذف الصورة: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _deletingImages.remove(imageUrl);
        });
      }
    }
  }

  Future<void> _showDeleteItemConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C212B),
        title: Text(
          'تأكيد الحذف',
          style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'هل أنت متأكد من حذف العنصر "${widget.item.name}"؟\n\nسيتم حذف جميع الفئات الفرعية والعناصر المرتبطة به.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'إلغاء',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'حذف',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteItem();
    }
  }

  Future<void> _showDeleteSubItemConfirmation(
    String subItemId,
    String subItemName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C212B),
        title: Text(
          'تأكيد الحذف',
          style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'هل أنت متأكد من حذف الفئة الفرعية "$subItemName"؟\n\nسيتم حذف جميع العناصر المرتبطة بها.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'إلغاء',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'حذف',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteSubItem(subItemId);
    }
  }

  Future<void> _deleteItem() async {
    try {
      await _apiDataSource.deleteItem(
        widget.projectId,
        widget.version,
        widget.item.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف العنصر بنجاح'),
            duration: Duration(seconds: 2),
          ),
        );
        // Notify parent to refresh data
        widget.onItemDeleted?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حذف العنصر: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteSubItem(String subItemId) async {
    try {
      await _apiDataSource.deleteSubItem(
        widget.projectId,
        widget.version,
        widget.item.id,
        subItemId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الفئة الفرعية بنجاح'),
            duration: Duration(seconds: 2),
          ),
        );
        // Notify parent to refresh data
        widget.onSubItemDeleted?.call(subItemId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حذف الفئة الفرعية: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildImagePreview(PricingSubItemModel subItem) {
    // Initialize selected index if not set
    if (!_selectedImageIndex.containsKey(subItem.id) &&
        subItem.images.isNotEmpty) {
      _selectedImageIndex[subItem.id] = 0;
    }

    final currentIndex = _selectedImageIndex[subItem.id] ?? 0;
    // Ensure index is within bounds
    final safeIndex = currentIndex >= subItem.images.length
        ? (subItem.images.isEmpty ? 0 : subItem.images.length - 1)
        : currentIndex;
    final currentImage = subItem.images[safeIndex];
    final isDeleting = _deletingImages[currentImage] == true;

    return Column(
      children: [
        // Main Image Display
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
                  Image.network(
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
                    child: Material(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                      child: InkWell(
                        onTap: isDeleting
                            ? null
                            : () => _deleteImage(subItem.id, currentImage),
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
                ],
              ),
            ),
          ),
        ),
        // Thumbnails Row
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Thumbnails
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: subItem.images.length,
                  itemBuilder: (context, index) {
                    final imageUrl = subItem.images[index];
                    final isSelected = index == safeIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImageIndex[subItem.id] = index;
                        });
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFF363C4A),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF2A313D),
                                child: const Icon(
                                  Icons.broken_image,
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
              ),
              // Add Image Button
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF4B5563),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _uploadingImages[subItem.id] == true
                        ? null
                        : () {
                            print(
                              'Upload button clicked for subItem: ${subItem.id}',
                            );
                            _uploadImages(subItem.id);
                          },
                    borderRadius: BorderRadius.circular(8),
                    child: _uploadingImages[subItem.id] == true
                        ? const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate,
                                size: 24,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'إضافة',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addLocalElement(String subItemId) {
    setState(() {
      final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
      final newElement = LocalElement(tempId: tempId, subItemId: subItemId);

      // Create new list with new element at the TOP (first position)
      final currentList = _localElements[subItemId] ?? [];
      _localElements[subItemId] = [newElement, ...currentList];

      // Auto-expand the sub-item when adding element
      _expandedSubItems[subItemId] = true;
    });
    // Notify parent of state change
    widget.onSubItemExpandedChanged?.call(
      Map<String, bool>.from(_expandedSubItems),
    );
  }

  void _updateLocalElement(
    String subItemId,
    String tempId,
    LocalElement updatedElement,
  ) {
    setState(() {
      final elements = _localElements[subItemId] ?? [];
      final index = elements.indexWhere((e) => e.tempId == tempId);
      if (index != -1) {
        updatedElement.lastModified = DateTime.now();
        elements[index] = updatedElement;

        // Cancel existing timer for this element
        _saveTimers[tempId]?.cancel();

        // Only auto-save if element has all required data and user has stopped typing
        if (updatedElement.hasRequiredData && !updatedElement.isCompleted) {
          // Add debounce: wait 2 seconds after last change before saving
          _saveTimers[tempId] = Timer(const Duration(seconds: 2), () {
            if (mounted) {
              _saveElementToBackend(subItemId, updatedElement);
            }
          });
        }
      }
    });
  }

  void _removeLocalElement(String subItemId, String tempId) {
    setState(() {
      _localElements[subItemId]?.removeWhere((e) => e.tempId == tempId);
      _savingElements.remove(tempId);
      _saveTimers[tempId]?.cancel();
      _saveTimers.remove(tempId);
    });
  }

  Future<void> _deleteElement(
    String subItemId,
    String elementId,
    bool isLocal,
  ) async {
    if (isLocal) {
      // Just remove from local elements
      _removeLocalElement(subItemId, elementId);
      return;
    }

    // Delete from backend
    try {
      // Ensure the sub-item is expanded and notify parent before deletion
      setState(() {
        _expandedSubItems[subItemId] = true;
      });
      widget.onSubItemExpandedChanged?.call(
        Map<String, bool>.from(_expandedSubItems),
      );

      await _apiDataSource.deletePricingElement(
        widget.projectId,
        widget.version,
        widget.item.id,
        subItemId,
        elementId,
      );

      // Refresh the item data to reflect the deletion
      try {
        final updatedVersion = await _apiDataSource.getPricingVersion(
          widget.projectId,
          widget.version,
        );
        final updatedItem = updatedVersion.items?.firstWhere(
          (i) => i.id == widget.item.id,
        );

        if (updatedItem != null && mounted) {
          // Update widget with new data - parent will preserve expanded states
          widget.onItemChanged?.call(updatedItem);
        }
      } catch (e) {
        // If refresh fails, the parent will still preserve states
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف العنصر بنجاح'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حذف العنصر: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveElementToBackend(
    String subItemId,
    LocalElement localElement,
  ) async {
    if (_savingElements[localElement.tempId] == true) return; // Already saving

    // Cancel the timer since we're saving now
    _saveTimers[localElement.tempId]?.cancel();
    _saveTimers.remove(localElement.tempId);

    // Double-check that element still has required data
    if (!localElement.hasRequiredData) return;

    setState(() {
      _savingElements[localElement.tempId] = true;
      localElement.isCompleted = true;
    });

    try {
      // Ensure the sub-item is expanded and notify parent before saving
      setState(() {
        _expandedSubItems[subItemId] = true;
      });
      widget.onSubItemExpandedChanged?.call(
        Map<String, bool>.from(_expandedSubItems),
      );

      await _apiDataSource.addPricingElement(
        widget.projectId,
        widget.version,
        widget.item.id,
        subItemId,
        name: localElement.name.trim(),
        costType: localElement.costType,
        unitCost: localElement.unitCost,
        quantity: localElement.quantity,
        totalCost: localElement.totalCost,
      );

      // Refresh data to show the newly saved element - parent will preserve expanded states
      try {
        final updatedVersion = await _apiDataSource.getPricingVersion(
          widget.projectId,
          widget.version,
        );
        final updatedItem = updatedVersion.items?.firstWhere(
          (i) => i.id == widget.item.id,
        );

        if (updatedItem != null && mounted) {
          // Remove from local elements AFTER getting updated data to prevent visual jump
          setState(() {
            _localElements[subItemId]?.removeWhere(
              (e) => e.tempId == localElement.tempId,
            );
            _savingElements.remove(localElement.tempId);
          });

          // Update the widget with new data - parent will preserve expanded states
          widget.onItemChanged?.call(updatedItem);
        } else {
          // If item not found, still remove from local elements
          setState(() {
            _localElements[subItemId]?.removeWhere(
              (e) => e.tempId == localElement.tempId,
            );
            _savingElements.remove(localElement.tempId);
          });
        }
      } catch (e) {
        // If refresh fails, still remove from local elements
        setState(() {
          _localElements[subItemId]?.removeWhere(
            (e) => e.tempId == localElement.tempId,
          );
          _savingElements.remove(localElement.tempId);
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ العنصر بنجاح'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _savingElements[localElement.tempId] = false;
        localElement.isCompleted = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حفظ العنصر: ${e.toString()}')),
        );
      }
    }
  }

  void _scheduleUpdateElement(
    String subItemId,
    String elementId,
    PricingItem updatedItem,
  ) {
    // Store the latest update values
    _pendingUpdates[elementId] = updatedItem;

    // Cancel existing timer for this element
    _updateTimers[elementId]?.cancel();

    // Ensure the sub-item is expanded
    setState(() {
      _expandedSubItems[subItemId] = true;
    });
    widget.onSubItemExpandedChanged?.call(
      Map<String, bool>.from(_expandedSubItems),
    );

    // Add debounce: wait 2 seconds after last change before updating
    _updateTimers[elementId] = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        final pendingItem = _pendingUpdates[elementId];
        if (pendingItem != null) {
          _pendingUpdates.remove(elementId);
          _updateSavedElement(subItemId, elementId, pendingItem);
        }
      }
    });
  }

  Future<void> _updateSavedElement(
    String subItemId,
    String elementId,
    PricingItem updatedItem,
  ) async {
    // Cancel the timer since we're updating now
    _updateTimers[elementId]?.cancel();
    _updateTimers.remove(elementId);

    setState(() {
      _updatingElements[elementId] = true;
    });

    try {
      // Determine cost type based on what's filled
      String? newCostType;
      if (updatedItem.quantity != null && updatedItem.unitPrice != null) {
        newCostType = 'UNIT_BASED';
      } else if (updatedItem.total > 0 &&
          updatedItem.quantity == null &&
          updatedItem.unitPrice == null) {
        newCostType = 'TOTAL';
      }

      await _apiDataSource.updatePricingElement(
        widget.projectId,
        widget.version,
        widget.item.id,
        subItemId,
        elementId,
        name: updatedItem.description.trim(),
        costType: newCostType,
        unitCost: updatedItem.unitPrice,
        quantity: updatedItem.quantity,
        totalCost: newCostType == 'TOTAL' ? updatedItem.total : null,
      );

      // Refresh data to show the updated element - parent will preserve expanded states
      try {
        final updatedVersion = await _apiDataSource.getPricingVersion(
          widget.projectId,
          widget.version,
        );
        final updatedItem = updatedVersion.items?.firstWhere(
          (i) => i.id == widget.item.id,
        );

        if (updatedItem != null && mounted) {
          // Update the widget with new data - parent will preserve expanded states
          widget.onItemChanged?.call(updatedItem);
        }
      } catch (e) {
        // If refresh fails, the parent will still preserve states
      }

      setState(() {
        _updatingElements.remove(elementId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث العنصر بنجاح'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _updatingElements.remove(elementId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحديث العنصر: ${e.toString()}')),
        );
      }
    }
  }

  List<PricingElementModel> _getAllElementsForSubItem(String subItemId) {
    final subItem = widget.item.subItems?.firstWhere(
      (si) => si.id == subItemId,
      orElse: () => widget.item.subItems?.first ?? widget.item.subItems!.first,
    );

    // Get saved elements and sort by createdAt (newest first)
    final savedElements = (subItem?.elements ?? []).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Get local elements (not yet saved)
    final localElementsList = _localElements[subItemId] ?? [];

    // Convert local elements to PricingElementModel for display
    // Local elements list has newest at index 0 (from insert(0, ...))
    // So we keep them as-is to display newest first
    final localElements = localElementsList.map((local) {
      final calculatedCost = local.costType == 'UNIT_BASED'
          ? (local.unitCost ?? 0) * (local.quantity ?? 0)
          : (local.totalCost ?? 0);

      return PricingElementModel(
        id: local.tempId,
        pricingSubItemId: local.subItemId,
        name: local.name,
        description: local.description,
        costType: local.costType,
        totalCost: local.totalCost,
        unitCost: local.unitCost,
        quantity: local.quantity,
        calculatedCost: calculatedCost,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();

    // Filter out any saved elements that might have the same temp ID (shouldn't happen, but safety check)
    final savedElementIds = savedElements.map((e) => e.id).toSet();
    final filteredLocalElements = localElements
        .where((e) => !savedElementIds.contains(e.id))
        .toList();

    // Return local elements first (newest at top), then saved elements below (also newest first)
    // Make sure we don't have duplicates
    return [...filteredLocalElements, ...savedElements];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C212B),
        border: Border.all(color: const Color(0xFF363C4A)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 71,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
            decoration: const BoxDecoration(
              color: Color(0xFF232936),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.architecture,
                  color: Color(0xFF135BEC),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.item.name,
                        style: AppTextStyles.h4.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.item.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.item.description!,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Total Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Text(
                            'KD',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _buildFormattedNumber(
                          widget.item.totalPrice,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => _showDeleteItemConfirmation(),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  tooltip: 'حذف العنصر',
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                    // Notify parent of state change
                    widget.onExpandedChanged?.call(_isExpanded);
                  },
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          // Content (Collapsible)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sub-Items List
                  if (widget.item.subItems != null &&
                      widget.item.subItems!.isNotEmpty)
                    ...widget.item.subItems!.map((subItem) {
                      final isSubItemExpanded =
                          _expandedSubItems[subItem.id] ?? false;
                      final allElements = _getAllElementsForSubItem(subItem.id);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF363C4A),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Sub-Item Header (Foldable)
                            InkWell(
                              onTap: () => _toggleSubItem(subItem.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A313D),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSubItemExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        subItem.name,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    // Show total cost in header only when NOT APPROVED/PROFIT_PENDING
                                    if (widget.pricingStatus?.toUpperCase() !=
                                            'APPROVED' &&
                                        widget.pricingStatus?.toUpperCase() !=
                                            'PROFIT_PENDING' &&
                                        allElements.isNotEmpty) ...[
                                      Builder(
                                        builder: (context) {
                                          final total = allElements
                                              .fold<double>(
                                                0,
                                                (sum, element) =>
                                                    sum +
                                                    (element.totalCost ?? 0)
                                                        .toDouble(),
                                              );
                                          final totalStr = total
                                              .toStringAsFixed(3);
                                          final dotIndex = totalStr.indexOf(
                                            '.',
                                          );
                                          final intPart = dotIndex >= 0
                                              ? totalStr.substring(0, dotIndex)
                                              : totalStr;
                                          final decimalPart = dotIndex >= 0
                                              ? totalStr.substring(dotIndex)
                                              : '';
                                          return RichText(
                                            textDirection: TextDirection.ltr,
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: intPart,
                                                  style: AppTextStyles.caption
                                                      .copyWith(
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                ),
                                                if (decimalPart.isNotEmpty)
                                                  TextSpan(
                                                    text: decimalPart,
                                                    style: AppTextStyles.caption
                                                        .copyWith(
                                                          color: AppColors
                                                              .textSecondary,
                                                          fontSize:
                                                              AppTextStyles
                                                                  .caption
                                                                  .fontSize! *
                                                              0.75, // smaller
                                                        ),
                                                  ),
                                                TextSpan(
                                                  text: ' KD',
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize:
                                                        AppTextStyles
                                                            .caption
                                                            .fontSize! *
                                                        0.75, // smaller
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                      ),
                                      onPressed: () =>
                                          _showDeleteSubItemConfirmation(
                                            subItem.id,
                                            subItem.name,
                                          ),
                                      tooltip: 'حذف الفئة الفرعية',
                                      color: Colors.red,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 18),
                                      onPressed: () =>
                                          _addLocalElement(subItem.id),
                                      tooltip: 'إضافة عنصر',
                                      color: AppColors.primary,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Elements List (Expandable)
                            if (isSubItemExpanded) ...[
                              // Add Image Button when no images - show above Elements table (top left)
                              if (subItem.images.isEmpty &&
                                  _uploadingImages[subItem.id] != true) ...[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 16,
                                    left: 12,
                                    right: 12,
                                    top: 12,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          print(
                                            'Upload button clicked for subItem: ${subItem.id}',
                                          );
                                          _uploadImages(subItem.id);
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          height: 50,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0xFF4B5563),
                                              style: BorderStyle.solid,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            color: const Color(
                                              0xFF2A313D,
                                            ).withOpacity(0.3),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.add_photo_alternate,
                                                size: 18,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'إضافة صور',
                                                style: AppTextStyles.bodyMedium
                                                    .copyWith(
                                                      color: AppColors.primary,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              // Profit Margin Input (only show when status is APPROVED)
                              if (widget.pricingStatus?.toUpperCase() ==
                                  'APPROVED') ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF15181E),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF363C4A),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'نسبة الربح (%)',
                                                style: AppTextStyles.bodyMedium
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 120,
                                              child: Builder(
                                                builder: (context) {
                                                  // Get or create controller for this subItem
                                                  if (!_profitControllers
                                                      .containsKey(
                                                        subItem.id,
                                                      )) {
                                                    final initialValue =
                                                        _profitMargins[subItem
                                                            .id] ??
                                                        subItem.profitMargin;
                                                    _profitControllers[subItem
                                                            .id] =
                                                        TextEditingController(
                                                          text: initialValue
                                                              .toStringAsFixed(
                                                                2,
                                                              ),
                                                        );
                                                  }
                                                  return TextField(
                                                    controller:
                                                        _profitControllers[subItem
                                                            .id]!,
                                                    keyboardType:
                                                        const TextInputType.numberWithOptions(
                                                          decimal: true,
                                                        ),
                                                    textAlign: TextAlign.center,
                                                    style: AppTextStyles
                                                        .bodyMedium,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: const Color(
                                                        0xFF2A313D,
                                                      ),
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color: Color(
                                                                0xFF363C4A,
                                                              ),
                                                            ),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            borderSide:
                                                                const BorderSide(
                                                                  color: Color(
                                                                    0xFF363C4A,
                                                                  ),
                                                                ),
                                                          ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            borderSide:
                                                                const BorderSide(
                                                                  color: AppColors
                                                                      .primary,
                                                                ),
                                                          ),
                                                      contentPadding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 12,
                                                          ),
                                                    ),
                                                    onChanged: (value) {
                                                      // Parse the input value as a percentage (e.g., 15 for 15%, 15.5 for 15.5%)
                                                      // The value is stored as-is (15 = 15%), and will be divided by 100 when calculating profit
                                                      final margin =
                                                          double.tryParse(
                                                            value,
                                                          ) ??
                                                          0.0;
                                                      // Ensure margin is non-negative
                                                      final clampedMargin =
                                                          margin < 0
                                                          ? 0.0
                                                          : margin;

                                                      setState(() {
                                                        _profitMargins[subItem
                                                                .id] =
                                                            clampedMargin;
                                                      });

                                                      // Calculate profit: cost * (margin / 100)
                                                      final cost =
                                                          subItem.totalCost > 0
                                                          ? subItem.totalCost
                                                          : allElements.fold<
                                                              double
                                                            >(
                                                              0,
                                                              (sum, e) =>
                                                                  sum +
                                                                  (e.totalCost ??
                                                                          0)
                                                                      .toDouble(),
                                                            );
                                                      final profit =
                                                          cost *
                                                          (clampedMargin / 100);
                                                      final totalPrice =
                                                          cost + profit;

                                                      // Update subItem profit margin
                                                      if (widget
                                                              .onSubItemChanged !=
                                                          null) {
                                                        final updatedSubItem =
                                                            PricingSubItemModel(
                                                              id: subItem.id,
                                                              pricingItemId: subItem
                                                                  .pricingItemId,
                                                              name:
                                                                  subItem.name,
                                                              description: subItem
                                                                  .description,
                                                              images: subItem
                                                                  .images,
                                                              profitMargin:
                                                                  clampedMargin,
                                                              profitAmount:
                                                                  profit,
                                                              totalCost: cost,
                                                              totalPrice:
                                                                  totalPrice,
                                                              order:
                                                                  subItem.order,
                                                              createdAt: subItem
                                                                  .createdAt,
                                                              updatedAt: subItem
                                                                  .updatedAt,
                                                              elements: subItem
                                                                  .elements,
                                                            );
                                                        widget
                                                            .onSubItemChanged!(
                                                          updatedSubItem,
                                                        );
                                                      }
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Cost, Profit, Total breakdown summary
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF15181E),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF363C4A),
                                            ),
                                          ),
                                          child: Builder(
                                            builder: (context) {
                                              final cost = subItem.totalCost > 0
                                                  ? subItem.totalCost
                                                  : allElements.fold<double>(
                                                      0,
                                                      (sum, e) =>
                                                          sum +
                                                          (e.totalCost ?? 0)
                                                              .toDouble(),
                                                    );
                                              final margin =
                                                  _profitMargins[subItem.id] ??
                                                  subItem.profitMargin;
                                              final profit =
                                                  cost * (margin / 100);
                                              final total = cost + profit;
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'ملخص التسعير',
                                                    style: AppTextStyles
                                                        .bodyMedium
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'التكلفة',
                                                        style: AppTextStyles
                                                            .caption
                                                            .copyWith(
                                                              color: AppColors
                                                                  .textSecondary,
                                                            ),
                                                      ),
                                                      Text(
                                                        '${cost.toStringAsFixed(3)} KD',
                                                        style: AppTextStyles
                                                            .caption
                                                            .copyWith(
                                                              color: AppColors
                                                                  .textSecondary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'الربح (${margin.toStringAsFixed(2)}%)',
                                                        style: AppTextStyles
                                                            .caption
                                                            .copyWith(
                                                              color:
                                                                  const Color(
                                                                    0xFF10B981,
                                                                  ),
                                                            ),
                                                      ),
                                                      Text(
                                                        '${profit.toStringAsFixed(3)} KD',
                                                        style: AppTextStyles
                                                            .caption
                                                            .copyWith(
                                                              color:
                                                                  const Color(
                                                                    0xFF10B981,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  const Divider(
                                                    color: Color(0xFF363C4A),
                                                    height: 1,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'الإجمالي',
                                                        style: AppTextStyles
                                                            .caption
                                                            .copyWith(
                                                              color: AppColors
                                                                  .textPrimary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 13,
                                                            ),
                                                      ),
                                                      Text(
                                                        '${total.toStringAsFixed(3)} KD',
                                                        style: AppTextStyles
                                                            .caption
                                                            .copyWith(
                                                              color: AppColors
                                                                  .textPrimary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 13,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              // Two-column layout: Images preview on left (if exists), Elements on right
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left column: Images Preview (only show if images exist or uploading)
                                    if (subItem.images.isNotEmpty ||
                                        _uploadingImages[subItem.id] ==
                                            true) ...[
                                      Flexible(
                                        flex: 1,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            right: 12,
                                            top: 12,
                                            bottom: 12,
                                          ),
                                          constraints: const BoxConstraints(
                                            maxWidth: 400,
                                            minWidth: 200,
                                            maxHeight: 600,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color(0xFF363C4A),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: const Color(0xFF1C212B),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Images Header
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            color: Color(
                                                              0xFF363C4A,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        subItem.images.isEmpty
                                                            ? '0/0 Photos'
                                                            : '${(_selectedImageIndex[subItem.id] ?? 0) + 1}/${subItem.images.length} Photos',
                                                        style: AppTextStyles
                                                            .bodyMedium
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                      const Spacer(),
                                                      if (_uploadingImages[subItem
                                                              .id] ==
                                                          true)
                                                        const SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: AppColors
                                                                    .primary,
                                                              ),
                                                        )
                                                      else
                                                        Material(
                                                          color: Colors
                                                              .transparent,
                                                          child: InkWell(
                                                            onTap: () {
                                                              print(
                                                                'Upload button clicked for subItem: ${subItem.id}',
                                                              );
                                                              _uploadImages(
                                                                subItem.id,
                                                              );
                                                            },
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  4,
                                                                ),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    4,
                                                                  ),
                                                              child: const Icon(
                                                                Icons
                                                                    .add_photo_alternate,
                                                                size: 18,
                                                                color: AppColors
                                                                    .primary,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                // Main Image Display
                                                Expanded(
                                                  child: subItem.images.isEmpty
                                                      ? const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: AppColors
                                                                    .primary,
                                                              ),
                                                        )
                                                      : _buildImagePreview(
                                                          subItem,
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    // Right column: Elements
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Always show elements table when there are elements
                                          if (allElements.isNotEmpty) ...[
                                            // Table Header
                                            Container(
                                              height: 41.5,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      'وصف العنصر',
                                                      style: AppTextStyles
                                                          .caption
                                                          .copyWith(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: const Color(
                                                              0xFF6B7280,
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      'التكلفة (دينار)',
                                                      style: AppTextStyles
                                                          .caption
                                                          .copyWith(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: const Color(
                                                              0xFF6B7280,
                                                            ),
                                                          ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            // Elements as Table Rows
                                            // Display in order: newest local elements first (at top), then saved elements
                                            ...allElements.asMap().entries.map((
                                              entry,
                                            ) {
                                              final index = entry.key;
                                              final element = entry.value;
                                              final isLocal = element.id
                                                  .startsWith('temp-');

                                              // Safely find local element
                                              LocalElement? localElement;
                                              if (isLocal) {
                                                try {
                                                  localElement =
                                                      _localElements[subItem.id]
                                                          ?.firstWhere(
                                                            (e) =>
                                                                e.tempId ==
                                                                element.id,
                                                          );
                                                } catch (e) {
                                                  localElement = null;
                                                }
                                              }

                                              final isSaving =
                                                  (isLocal &&
                                                      localElement != null &&
                                                      (_savingElements[element
                                                              .id] ==
                                                          true)) ||
                                                  (!isLocal &&
                                                      _updatingElements[element
                                                              .id] ==
                                                          true);

                                              // Convert element to PricingItem for table row
                                              final pricingItem = PricingItem(
                                                id: element.id,
                                                description: element.name,
                                                quantity:
                                                    element.costType ==
                                                        'UNIT_BASED'
                                                    ? element.quantity
                                                    : null,
                                                unitPrice:
                                                    element.costType ==
                                                        'UNIT_BASED'
                                                    ? element.unitCost
                                                    : null,
                                                total: element.calculatedCost,
                                              );

                                              return Stack(
                                                key: ValueKey(
                                                  'element-${subItem.id}-${element.id}-$index',
                                                ),
                                                children: [
                                                  PricingTableRow(
                                                    item: pricingItem,
                                                    isNewRow:
                                                        isLocal &&
                                                        localElement != null &&
                                                        !localElement
                                                            .hasRequiredData,
                                                    onDelete: () =>
                                                        _deleteElement(
                                                          subItem.id,
                                                          element.id,
                                                          isLocal,
                                                        ),
                                                    onChanged: (updatedItem) {
                                                      if (isLocal &&
                                                          localElement !=
                                                              null) {
                                                        // Determine cost type based on what's filled
                                                        String newCostType =
                                                            localElement
                                                                .costType;
                                                        if (updatedItem
                                                                    .quantity !=
                                                                null &&
                                                            updatedItem
                                                                    .unitPrice !=
                                                                null) {
                                                          newCostType =
                                                              'UNIT_BASED';
                                                        } else if (updatedItem
                                                                    .total >
                                                                0 &&
                                                            updatedItem
                                                                    .quantity ==
                                                                null &&
                                                            updatedItem
                                                                    .unitPrice ==
                                                                null) {
                                                          newCostType = 'TOTAL';
                                                        }

                                                        // Update local element - only update name if it's not empty
                                                        final updated = LocalElement(
                                                          tempId: localElement
                                                              .tempId,
                                                          subItemId:
                                                              localElement
                                                                  .subItemId,
                                                          name: updatedItem
                                                              .description
                                                              .trim(),
                                                          costType: newCostType,
                                                          unitCost: updatedItem
                                                              .unitPrice,
                                                          quantity: updatedItem
                                                              .quantity,
                                                          totalCost:
                                                              newCostType ==
                                                                  'TOTAL'
                                                              ? updatedItem
                                                                    .total
                                                              : null,
                                                          isCompleted:
                                                              localElement
                                                                  .isCompleted,
                                                        );
                                                        _updateLocalElement(
                                                          subItem.id,
                                                          element.id,
                                                          updated,
                                                        );
                                                      } else {
                                                        // Store latest values and schedule update with debounce
                                                        _pendingUpdates[element
                                                                .id] =
                                                            updatedItem;
                                                        _scheduleUpdateElement(
                                                          subItem.id,
                                                          element.id,
                                                          updatedItem,
                                                        );
                                                      }
                                                    },
                                                    onFieldCompleted: () {
                                                      // Trigger immediate save when user finishes editing field (blur or submit)
                                                      if (isLocal &&
                                                          localElement !=
                                                              null &&
                                                          localElement
                                                              .hasRequiredData &&
                                                          !localElement
                                                              .isCompleted) {
                                                        // Cancel debounce timer and save immediately
                                                        _saveTimers[element.id]
                                                            ?.cancel();
                                                        _saveTimers.remove(
                                                          element.id,
                                                        );
                                                        _saveElementToBackend(
                                                          subItem.id,
                                                          localElement,
                                                        );
                                                      } else if (!isLocal) {
                                                        // Cancel debounce timer and update immediately with latest values
                                                        _updateTimers[element
                                                                .id]
                                                            ?.cancel();
                                                        _updateTimers.remove(
                                                          element.id,
                                                        );
                                                        final pendingItem =
                                                            _pendingUpdates[element
                                                                .id];
                                                        if (pendingItem !=
                                                            null) {
                                                          _pendingUpdates
                                                              .remove(
                                                                element.id,
                                                              );
                                                          _updateSavedElement(
                                                            subItem.id,
                                                            element.id,
                                                            pendingItem,
                                                          );
                                                        }
                                                      }
                                                    },
                                                  ),
                                                  if (isSaving)
                                                    Positioned.fill(
                                                      child: Container(
                                                        color: Colors.black
                                                            .withOpacity(0.3),
                                                        child: const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: AppColors
                                                                    .primary,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              );
                                            }),
                                          ] else ...[
                                            Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: Center(
                                                child: Text(
                                                  'لا توجد عناصر بعد',
                                                  style: AppTextStyles
                                                      .bodyMedium
                                                      .copyWith(
                                                        color:
                                                            AppColors.textMuted,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    })
                  else ...[
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
                  // Add Sub-Item Button
                  const SizedBox(height: 12),
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF4B5563)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: widget.onAddSubItem,
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
                            'إضافة فئة فرعية',
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
                  // Subtotal
                  const SizedBox(height: 16),
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
                            _buildFormattedNumber(
                              widget.item.totalPrice,
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
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
