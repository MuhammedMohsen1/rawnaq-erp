import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pasteboard/pasteboard.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/arabic_number_input_formatter.dart';
import '../../../../core/widgets/dialog_keyboard_actions.dart';
import '../../data/datasources/pricing_api_datasource.dart';
import '../../data/models/pricing_version_model.dart';
import '../../domain/entities/pricing_item.dart';
import 'image_crop_dialog.dart';
import 'pricing_item_card_local_element.dart';
import 'pricing_item_card_visuals.dart';
import 'pricing_item_card_section_widgets.dart';
import 'pricing_item_card_subitems_list.dart';
part 'pricing_item_card_image_actions.dart';

class PricingItemCard extends StatefulWidget {
  final String projectId;
  final int version;
  final PricingItemModel item;
  final String? pricingStatus; // DRAFT, APPROVED, PENDING_SIGNATURE, etc.
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
  final bool isAdminOrManager; // Whether user is Admin or Manager of Department
  final bool canViewFinancials;
  final Map<String, double>?
  externalProfitMargins; // Profit margins from parent (e.g., bulk update)
  final bool canReorderItem;
  final int? itemReorderIndex;
  final bool canReorderSubItems;
  final Future<void> Function(int oldIndex, int newIndex)? onReorderSubItems;
  final bool canReorderElements;
  final bool showFinancials;
  final Future<void> Function(
    String subItemId,
    String elementId,
    int targetOrder,
  )?
  onReorderElements;

  const PricingItemCard({
    super.key,
    required this.projectId,
    required this.version,
    required this.item,
    this.pricingStatus,
    this.onItemChanged,
    this.onSubItemChanged,
    this.onAddSubItem,
    this.initialIsExpanded = false,
    this.initialSubItemExpandedStates = const {},
    this.onExpandedChanged,
    this.onSubItemExpandedChanged,
    this.onItemDeleted,
    this.onSubItemDeleted,
    this.isAdminOrManager = false,
    this.canViewFinancials = false,
    this.externalProfitMargins,
    this.canReorderItem = false,
    this.itemReorderIndex,
    this.canReorderSubItems = false,
    this.onReorderSubItems,
    this.canReorderElements = false,
    this.showFinancials = true,
    this.onReorderElements,
  });

  @override
  State<PricingItemCard> createState() => _PricingItemCardState();
}

class _DuplicateOptions {
  final int count;

  const _DuplicateOptions({required this.count});
}

class _TrailingNumberName {
  final String prefix;
  final int number;
  final int width;
  final int zeroCodeUnit;
  final bool hasTrailingNumber;

  const _TrailingNumberName._({
    required this.prefix,
    required this.number,
    required this.width,
    required this.zeroCodeUnit,
    required this.hasTrailingNumber,
  });

  factory _TrailingNumberName.parse(String name) {
    final match = RegExp(
      r'([0-9\u0660-\u0669\u06F0-\u06F9]+)\s*$',
    ).firstMatch(name);

    if (match == null) {
      return _TrailingNumberName._(
        prefix: name,
        number: 0,
        width: 0,
        zeroCodeUnit: '0'.codeUnitAt(0),
        hasTrailingNumber: false,
      );
    }

    final digits = match.group(1)!;
    final zeroCodeUnit = _zeroCodeUnitForDigit(digits.codeUnitAt(0));
    var number = 0;
    for (final digit in digits.codeUnits) {
      number = (number * 10) + _digitValue(digit);
    }

    return _TrailingNumberName._(
      prefix: name.substring(0, match.start),
      number: number,
      width: digits.length,
      zeroCodeUnit: zeroCodeUnit,
      hasTrailingNumber: true,
    );
  }

  String duplicateNameAt(int duplicateIndex) {
    if (!hasTrailingNumber) {
      return prefix;
    }

    final nextNumber = number + duplicateIndex;
    final nextDigits = _formatNumber(
      nextNumber,
      width: width,
      zeroCodeUnit: zeroCodeUnit,
    );
    return '$prefix$nextDigits';
  }

  static int _zeroCodeUnitForDigit(int codeUnit) {
    if (codeUnit >= 0x0660 && codeUnit <= 0x0669) return 0x0660;
    if (codeUnit >= 0x06F0 && codeUnit <= 0x06F9) return 0x06F0;
    return '0'.codeUnitAt(0);
  }

  static int _digitValue(int codeUnit) {
    if (codeUnit >= 0x0660 && codeUnit <= 0x0669) return codeUnit - 0x0660;
    if (codeUnit >= 0x06F0 && codeUnit <= 0x06F9) return codeUnit - 0x06F0;
    return codeUnit - '0'.codeUnitAt(0);
  }

  static String _formatNumber(
    int number, {
    required int width,
    required int zeroCodeUnit,
  }) {
    final westernDigits = number.toString().padLeft(width, '0');
    if (zeroCodeUnit == '0'.codeUnitAt(0)) {
      return westernDigits;
    }

    return String.fromCharCodes(
      westernDigits.codeUnits.map(
        (digit) => zeroCodeUnit + digit - '0'.codeUnitAt(0),
      ),
    );
  }
}

class _PricingItemCardState extends State<PricingItemCard>
    with PricingItemCardImageActions {
  final _apiDataSource = PricingApiDataSource();
  final _imagePicker = ImagePicker();
  late bool _isExpanded;
  final Map<String, bool> _expandedSubItems = {};
  final Map<String, List<LocalElement>> _localElements =
      {}; // subItemId -> List<LocalElement>
  final Map<String, bool> _savingElements = {}; // tempId -> isSaving
  final Map<String, Timer?> _saveTimers = {}; // tempId -> debounce timer
  final Map<String, FocusNode> _localElementFocusNodes =
      {}; // tempId -> first field focus node
  final Map<String, bool> _updatingElements = {}; // elementId -> isUpdating
  final Map<String, Timer?> _updateTimers = {}; // elementId -> debounce timer
  final Map<String, PricingItem> _pendingUpdates =
      {}; // elementId -> latest PricingItem values
  final Map<String, Timer?> _profitMarginTimers =
      {}; // subItemId -> debounce timer for profit margin updates
  final Map<String, bool> _uploadingImages = {}; // subItemId -> isUploading
  final Map<String, bool> _deletingImages = {}; // imageUrl -> isDeleting
  final Map<String, double> _profitMargins =
      {}; // subItemId -> profitMargin (for APPROVED status)
  final Map<String, TextEditingController> _profitControllers =
      {}; // subItemId -> TextEditingController for profit margin input
  final Map<String, TextEditingController> _notesControllers =
      {}; // subItemId -> TextEditingController for notes input
  final Map<String, FocusNode> _notesFocusNodes =
      {}; // subItemId -> FocusNode for notes input
  final Map<String, Timer?> _notesTimers =
      {}; // subItemId -> debounce timer for notes saving
  final Map<String, int> _selectedImageIndex =
      {}; // subItemId -> selected image index
  final bool _isRestoringState =
      false; // Flag to prevent state reset during restoration

  @override
  PricingApiDataSource get apiDataSource => _apiDataSource;
  @override
  ImagePicker get imagePicker => _imagePicker;
  @override
  Map<String, bool> get uploadingImages => _uploadingImages;
  @override
  Map<String, bool> get deletingImages => _deletingImages;
  @override
  Map<String, int> get selectedImageIndex => _selectedImageIndex;

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
        // Keep local controller state in sync with backend profit margins.
        _profitMargins[subItem.id] = subItem.profitMargin;
        _profitControllers[subItem.id] = TextEditingController(
          text: subItem.profitMargin.toStringAsFixed(2),
        );
        // Initialize notes controller
        _notesControllers[subItem.id] = TextEditingController(
          text: subItem.description,
        );
        _notesFocusNodes[subItem.id] = _createSubItemDescriptionFocusNode(
          subItem.id,
        );
      }
      setState(() {});
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

    // Update sub-item expanded states from parent (only for new sub-items)
    if (widget.item.subItems != null) {
      for (var subItem in widget.item.subItems!) {
        // Only initialize expanded state if not already tracked locally
        // This prevents collapsing when widget rebuilds during user interaction
        if (!_expandedSubItems.containsKey(subItem.id)) {
          final parentState =
              widget.initialSubItemExpandedStates[subItem.id] ?? false;
          _expandedSubItems[subItem.id] = parentState;
        }
        // Preserve local elements for existing sub-items
        if (!_localElements.containsKey(subItem.id)) {
          _localElements[subItem.id] = [];
        }
        if (!_profitControllers.containsKey(subItem.id)) {
          _profitMargins[subItem.id] = subItem.profitMargin;
          _profitControllers[subItem.id] = TextEditingController(
            text: subItem.profitMargin.toStringAsFixed(2),
          );
        }
        // Sync notes controller with latest data (only if no pending save)
        final newNotes = subItem.description ?? '';
        final existingController = _notesControllers[subItem.id];
        final notesFocusNode = _notesFocusNodes[subItem.id];
        final hasPendingNoteSave = _notesTimers[subItem.id]?.isActive ?? false;
        if (existingController == null) {
          _notesControllers[subItem.id] = TextEditingController(text: newNotes);
          _notesFocusNodes[subItem.id] = _createSubItemDescriptionFocusNode(
            subItem.id,
          );
        } else if (existingController.text != newNotes &&
            !hasPendingNoteSave &&
            !(notesFocusNode?.hasFocus ?? false)) {
          // Only sync if there's no pending save (user isn't actively editing)
          final selection = existingController.selection;
          existingController.text = newNotes;
          final clampedOffset = selection.baseOffset.clamp(0, newNotes.length);
          existingController.selection = TextSelection.collapsed(
            offset: clampedOffset,
          );
        }

        // Sync profit margin from external source (e.g., bulk update)
        // Only sync if there's no pending profit margin save (user isn't actively editing)
        final hasPendingProfitSave =
            _profitMarginTimers[subItem.id]?.isActive ?? false;
        if (widget.externalProfitMargins != null && !hasPendingProfitSave) {
          final externalMargin = widget.externalProfitMargins![subItem.id];
          if (externalMargin != null &&
              externalMargin != _profitMargins[subItem.id]) {
            _profitMargins[subItem.id] = externalMargin;
            final profitController = _profitControllers[subItem.id];
            if (profitController != null) {
              profitController.text = externalMargin.toStringAsFixed(2);
            }
          }
        } else if (!hasPendingProfitSave) {
          final latestMargin = subItem.profitMargin;
          if (latestMargin != _profitMargins[subItem.id]) {
            _profitMargins[subItem.id] = latestMargin;
            final profitController = _profitControllers[subItem.id];
            if (profitController != null) {
              profitController.text = latestMargin.toStringAsFixed(2);
            }
          }
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
    for (var focusNode in _localElementFocusNodes.values) {
      focusNode.dispose();
    }
    _localElementFocusNodes.clear();
    // Cancel all pending update timers
    for (var timer in _updateTimers.values) {
      timer?.cancel();
    }
    _updateTimers.clear();
    // Cancel all pending profit margin update timers
    for (var timer in _profitMarginTimers.values) {
      timer?.cancel();
    }
    _profitMarginTimers.clear();
    // Dispose notes controllers
    for (var controller in _notesControllers.values) {
      controller.dispose();
    }
    _notesControllers.clear();
    // Dispose notes focus nodes
    for (var focusNode in _notesFocusNodes.values) {
      focusNode.dispose();
    }
    _notesFocusNodes.clear();
    // Cancel notes timers
    for (var timer in _notesTimers.values) {
      timer?.cancel();
    }
    _notesTimers.clear();
    super.dispose();
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

  Future<void> _handleSubItemReorder(int oldIndex, int newIndex) async {
    if (!widget.canReorderSubItems || widget.onReorderSubItems == null) {
      return;
    }

    await widget.onReorderSubItems!(oldIndex, newIndex);
  }

  //                         IconButton(
  //                           onPressed: hasImages ? cropCurrentImage : null,
  //                           tooltip: 'قص',
  //                           icon: const Icon(
  //                             Icons.crop,
  //                             color: AppColors.primary,
  //                           ),
  //                         ),
  //                         IconButton(
  //                           onPressed: hasImages ? removeCurrentImage : null,
  //                           tooltip: 'حذف',
  //                           icon: const Icon(
  //                             Icons.delete_outline,
  //                             color: AppColors.error,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   const SizedBox(height: 16),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     children: [
  //                       OutlinedButton.icon(
  //                         onPressed: () => Navigator.of(dialogContext).pop(),
  //                         style: OutlinedButton.styleFrom(
  //                           foregroundColor: AppColors.textSecondary,
  //                           side: const BorderSide(color: Color(0xFF363C4A)),
  //                         ),
  //                         icon: const Icon(Icons.cancel),
  //                         label: const Text('إلغاء'),
  //                       ),
  //                       const SizedBox(width: 12),
  //                       ElevatedButton.icon(
  //                         onPressed: hasImages ? uploadImages : null,
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: AppColors.background,
  //                           foregroundColor: Colors.white,
  //                         ),
  //                         icon: const Icon(Icons.cloud_upload_outlined),
  //                         label: const Text('رفع الصور'),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  @override
  Future<void> _cropPickedImagesThenUpload(
    String subItemId,
    List<MapEntry<String, Uint8List>> pickedImages,
  ) async {
    if (pickedImages.isEmpty) return;

    final croppedImages = <MapEntry<String, Uint8List>>[];

    for (final image in pickedImages) {
      if (!mounted) return;

      final croppedBytes = await ImageCropDialog.show(
        context,
        image.value,
        fileName: image.key,
      );

      // User cancelled crop dialog.
      // Do not upload anything if crop was cancelled.
      if (croppedBytes == null) {
        return;
      }

      croppedImages.add(MapEntry(_croppedFileName(image.key), croppedBytes));
    }

    if (croppedImages.isEmpty) return;

    await _uploadSelectedImages(subItemId, croppedImages);
  }

  @override
  String _croppedFileName(String originalName) {
    final dotIndex = originalName.lastIndexOf('.');

    if (dotIndex <= 0 || dotIndex == originalName.length - 1) {
      return 'cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }

    final name = originalName.substring(0, dotIndex);
    final extension = originalName.substring(dotIndex);

    return '${name}_cropped$extension';
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
          'هل أنت متأكد من حذف البند الفرعية "$subItemName"؟\n\nسيتم حذف جميع العناصر المرتبطة بها.',
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
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل حذف العنصر: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _showItemContextMenu() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1C212B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text(
                'تعديل البند الفرعية',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: AppColors.primary),
              title: const Text(
                'انشاء نسخة مطابقة',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.pop(context, 'duplicate'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('حذف', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (result == 'edit') {
      await _showEditItemDialog();
    } else if (result == 'duplicate') {
      await _duplicateItem();
    } else if (result == 'delete') {
      await _showDeleteItemConfirmation();
    }
  }

  Future<void> _showSubItemContextMenu(PricingSubItemModel subItem) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1C212B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text(
                'تعديل الاسم',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: AppColors.primary),
              title: const Text(
                'انشاء نسخة مطابقة',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.pop(context, 'duplicate'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('حذف', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (result == 'edit') {
      await _showEditSubItemDialog(subItem);
    } else if (result == 'duplicate') {
      await _duplicateSubItem(subItem);
    } else if (result == 'delete') {
      await _showDeleteSubItemConfirmation(subItem.id, subItem.name);
    }
  }

  Future<_DuplicateOptions?> _showDuplicateOptionsDialog(String title) async {
    final countController = TextEditingController(text: '1');
    String? errorText;

    final result = await showDialog<_DuplicateOptions>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1C212B),
          title: Text(
            title,
            style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اكتب عدد النسخ المطلوبة. إذا كان الاسم ينتهي برقم سيتم زيادته تلقائياً.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: countController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  ArabicNumberInputFormatter(),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'عدد النسخ',
                  errorText: errorText,
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF363C4A)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.error),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.error),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (_) {
                  final count = int.tryParse(countController.text.trim());
                  if (count == null || count < 1) {
                    setDialogState(() {
                      errorText = 'ادخل رقم أكبر من صفر';
                    });
                    return;
                  }

                  Navigator.pop(context, _DuplicateOptions(count: count));
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final count = int.tryParse(countController.text.trim());
                if (count == null || count < 1) {
                  setDialogState(() {
                    errorText = 'ادخل رقم أكبر من صفر';
                  });
                  return;
                }

                Navigator.pop(context, _DuplicateOptions(count: count));
              },
              child: Text(
                'تكرار',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    countController.dispose();
    return result;
  }

  Future<void> _duplicateItem() async {
    final options = await _showDuplicateOptionsDialog('تكرار العنصر');
    if (options == null) return;

    final namePattern = _TrailingNumberName.parse(widget.item.name);

    try {
      for (var index = 1; index <= options.count; index++) {
        final duplicatedItem = await _apiDataSource.duplicatePricingItem(
          widget.projectId,
          widget.version,
          widget.item.id,
        );
        final duplicateName = namePattern.duplicateNameAt(index);

        if (duplicatedItem.name != duplicateName) {
          await _apiDataSource.updatePricingItem(
            widget.projectId,
            widget.version,
            duplicatedItem.id,
            name: duplicateName,
          );
        }
      }

      if (mounted) {
        widget.onItemChanged?.call(widget.item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              options.count == 1
                  ? 'تم نسخ العنصر بنجاح'
                  : 'تم إنشاء ${options.count} نسخ من العنصر بنجاح',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل نسخ العنصر: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _duplicateSubItem(PricingSubItemModel subItem) async {
    final options = await _showDuplicateOptionsDialog('تكرار البند الفرعية');
    if (options == null) return;

    final namePattern = _TrailingNumberName.parse(subItem.name);

    try {
      for (var index = 1; index <= options.count; index++) {
        final duplicatedSubItem = await _apiDataSource.duplicatePricingSubItem(
          widget.projectId,
          widget.version,
          widget.item.id,
          subItem.id,
        );
        final duplicateName = namePattern.duplicateNameAt(index);

        if (duplicatedSubItem.name != duplicateName) {
          await _apiDataSource.updatePricingSubItem(
            widget.projectId,
            widget.version,
            widget.item.id,
            duplicatedSubItem.id,
            name: duplicateName,
          );
        }
      }

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              options.count == 1
                  ? 'تم نسخ البند الفرعية بنجاح'
                  : 'تم إنشاء ${options.count} نسخ من البند الفرعية بنجاح',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل نسخ البند الفرعية: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _showEditItemDialog() async {
    final nameController = TextEditingController(text: widget.item.name);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        void submit() {
          if (nameController.text.trim().isNotEmpty) {
            Navigator.pop(context, {'name': nameController.text.trim()});
          }
        }

        return DialogKeyboardActions(
          onSubmit: submit,
          onClose: () => Navigator.pop(context),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1C212B),
            title: Text(
              'تعديل العنصر',
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'اسم العنصر',
                      labelStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF363C4A)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: submit,
                child: Text(
                  'حفظ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    nameController.dispose();

    if (result != null && result['name'] != null) {
      try {
        await _apiDataSource.updatePricingItem(
          widget.projectId,
          widget.version,
          widget.item.id,
          name: result['name'],
          description: result['description']?.isEmpty == true
              ? null
              : result['description'],
        );

        // Refresh data
        final updatedVersion = await _apiDataSource.getPricingVersion(
          widget.projectId,
          widget.version,
        );
        final updatedItem = updatedVersion.items?.firstWhere(
          (i) => i.id == widget.item.id,
        );

        if (updatedItem != null && mounted) {
          widget.onItemChanged?.call(updatedItem);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث العنصر بنجاح'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text('فشل تحديث العنصر: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }

  Future<void> _showEditSubItemDialog(PricingSubItemModel subItem) async {
    final nameController = TextEditingController(text: subItem.name);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        void submit() {
          if (nameController.text.trim().isNotEmpty) {
            Navigator.pop(context, {'name': nameController.text.trim()});
          }
        }

        return DialogKeyboardActions(
          onSubmit: submit,
          onClose: () => Navigator.pop(context),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1C212B),
            title: Text(
              'تعديل البند الفرعية',
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'اسم البند الفرعية',
                      labelStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF363C4A)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: submit,
                child: Text(
                  'حفظ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    nameController.dispose();

    if (result != null && result['name'] != null) {
      try {
        await _apiDataSource.updatePricingSubItem(
          widget.projectId,
          widget.version,
          widget.item.id,
          subItem.id,
          name: result['name'],
        );

        // Refresh data
        final updatedVersion = await _apiDataSource.getPricingVersion(
          widget.projectId,
          widget.version,
        );
        final updatedItem = updatedVersion.items?.firstWhere(
          (i) => i.id == widget.item.id,
        );

        if (updatedItem != null && mounted) {
          widget.onItemChanged?.call(updatedItem);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث البند الفرعية بنجاح'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text('فشل تحديث البند الفرعية: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }

  void _scheduleSubItemDescriptionUpdate(
    PricingSubItemModel subItem,
    String description,
  ) {
    final normalizedDescription = description.trim();
    final currentDescription = (subItem.description ?? '').trim();

    _notesTimers[subItem.id]?.cancel();
    if (normalizedDescription == currentDescription) {
      _notesTimers.remove(subItem.id);
      return;
    }

    _notesTimers[subItem.id] = Timer(const Duration(milliseconds: 800), () {
      _flushSubItemDescription(subItem.id);
    });
  }

  FocusNode _createSubItemDescriptionFocusNode(String subItemId) {
    final focusNode = FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        _flushSubItemDescription(subItemId);
      }
    });
    return focusNode;
  }

  PricingSubItemModel? _findSubItem(String subItemId) {
    final subItems = widget.item.subItems;
    if (subItems == null) return null;

    for (final subItem in subItems) {
      if (subItem.id == subItemId) {
        return subItem;
      }
    }

    return null;
  }

  void _flushSubItemDescription(String subItemId) {
    final subItem = _findSubItem(subItemId);
    final controller = _notesControllers[subItemId];
    if (subItem == null || controller == null) return;

    final description = controller.text.trim();
    final currentDescription = (subItem.description ?? '').trim();

    _notesTimers[subItemId]?.cancel();
    _notesTimers.remove(subItemId);

    if (description == currentDescription) return;

    _saveSubItemDescription(subItem, description);
  }

  void _scheduleSubItemProfitMarginUpdate(
    PricingSubItemModel subItem,
    String value,
  ) {
    final parsedMargin = double.tryParse(value.trim());
    if (parsedMargin == null) {
      _profitMarginTimers[subItem.id]?.cancel();
      _profitMarginTimers.remove(subItem.id);
      return;
    }

    _profitMargins[subItem.id] = parsedMargin;
    _profitMarginTimers[subItem.id]?.cancel();
    _profitMarginTimers[subItem.id] = Timer(
      const Duration(milliseconds: 800),
      () {
        _flushSubItemProfitMargin(subItem.id);
      },
    );
  }

  void _flushSubItemProfitMargin(String subItemId) {
    final subItem = _findSubItem(subItemId);
    final controller = _profitControllers[subItemId];
    if (subItem == null || controller == null) return;

    final profitMargin = double.tryParse(controller.text.trim());
    _profitMarginTimers[subItemId]?.cancel();
    _profitMarginTimers.remove(subItemId);

    if (profitMargin == null || profitMargin == subItem.profitMargin) {
      return;
    }

    _saveSubItemProfitMargin(subItem, profitMargin);
  }

  Future<void> _saveSubItemProfitMargin(
    PricingSubItemModel subItem,
    double profitMargin,
  ) async {
    try {
      final updatedSubItem = await _apiDataSource.updateSubItemProfitMargin(
        widget.projectId,
        widget.version,
        widget.item.id,
        subItem.id,
        profitMargin,
      );

      if (mounted) {
        widget.onSubItemChanged?.call(updatedSubItem);
        widget.onItemChanged?.call(widget.item);
      }
    } catch (e) {
      if (mounted) {
        final controller = _profitControllers[subItem.id];
        if (controller != null) {
          controller.text = subItem.profitMargin.toStringAsFixed(2);
        }
        _profitMargins[subItem.id] = subItem.profitMargin;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل تحديث نسبة الربح: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _saveSubItemDescription(
    PricingSubItemModel subItem,
    String description,
  ) async {
    try {
      await _apiDataSource.updatePricingSubItem(
        widget.projectId,
        widget.version,
        widget.item.id,
        subItem.id,
        description: description,
      );

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل تحديث وصف البند الفرعية: ${e.toString()}'),
          ),
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
            content: Text('تم حذف البند الفرعية بنجاح'),
            duration: Duration(seconds: 2),
          ),
        );
        // Notify parent to refresh data
        widget.onSubItemDeleted?.call(subItemId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل حذف البند الفرعية: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _addLocalElement(String subItemId) {
    LocalElement? existingEmptyElement;
    for (final element in _localElements[subItemId] ?? <LocalElement>[]) {
      if (element.isEmpty && !element.isCompleted) {
        existingEmptyElement = element;
        break;
      }
    }

    if (existingEmptyElement != null) {
      setState(() {
        _expandedSubItems[subItemId] = true;
      });
      widget.onSubItemExpandedChanged?.call(
        Map<String, bool>.from(_expandedSubItems),
      );

      final focusNode = _localElementFocusNodes[existingEmptyElement.tempId];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && focusNode != null && focusNode.canRequestFocus) {
          focusNode.requestFocus();
        }
      });
      return;
    }

    final tempId = 'temp-${DateTime.now().microsecondsSinceEpoch}';
    final focusNode = FocusNode();
    setState(() {
      final newElement = LocalElement(tempId: tempId, subItemId: subItemId);
      _localElementFocusNodes[tempId] = focusNode;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    });
  }

  void _disposeLocalElementFocusNode(String tempId) {
    final focusNode = _localElementFocusNodes.remove(tempId);
    if (focusNode == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.dispose();
    });
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
      _disposeLocalElementFocusNode(tempId);
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
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل حذف العنصر: ${e.toString()}'),
          ),
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
            _disposeLocalElementFocusNode(localElement.tempId);
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
            _disposeLocalElementFocusNode(localElement.tempId);
          });
        }
      } catch (e) {
        // If refresh fails, still remove from local elements
        setState(() {
          _localElements[subItemId]?.removeWhere(
            (e) => e.tempId == localElement.tempId,
          );
          _savingElements.remove(localElement.tempId);
          _disposeLocalElementFocusNode(localElement.tempId);
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
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل حفظ العنصر: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _completeElementEditing({
    required PricingSubItemModel subItem,
    required PricingElementModel element,
    required bool isLocal,
    required LocalElement? localElement,
    required bool addNext,
  }) async {
    if (isLocal && localElement != null) {
      if (localElement.hasRequiredData && !localElement.isCompleted) {
        _saveTimers[element.id]?.cancel();
        _saveTimers.remove(element.id);
        await _saveElementToBackend(subItem.id, localElement);
      }

      if (addNext && localElement.hasRequiredData && mounted) {
        _addLocalElement(subItem.id);
      }
      return;
    }

    _updateTimers[element.id]?.cancel();
    _updateTimers.remove(element.id);
    final pendingItem = _pendingUpdates.remove(element.id);
    if (pendingItem != null) {
      await _updateSavedElement(
        subItem.id,
        element.id,
        pendingItem,
        element.costType,
      );
    }

    if (addNext && mounted) {
      _addLocalElement(subItem.id);
    }
  }

  void _scheduleUpdateElement(
    String subItemId,
    String elementId,
    PricingItem updatedItem,
    String currentCostType,
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
          _updateSavedElement(
            subItemId,
            elementId,
            pendingItem,
            currentCostType,
          );
        }
      }
    });
  }

  Future<void> _toggleSubItemVisibility(
    PricingSubItemModel subItem,
    bool isVisible,
  ) async {
    final newIsHidden = !isVisible;

    try {
      await _apiDataSource.toggleSubItemVisibility(
        widget.projectId,
        widget.version,
        widget.item.id,
        subItem.id,
        newIsHidden,
      );

      // Update local state
      setState(() {
        final updatedElements = subItem.elements
            ?.map((element) => element.copyWith(isHidden: newIsHidden))
            .toList();
        final subItemIndex = widget.item.subItems?.indexWhere(
          (s) => s.id == subItem.id,
        );
        if (subItemIndex != null && subItemIndex >= 0) {
          widget.item.subItems![subItemIndex] = PricingSubItemModel(
            id: subItem.id,
            pricingItemId: subItem.pricingItemId,
            name: subItem.name,
            description: subItem.description,
            notes: subItem.notes,
            images: subItem.images,
            profitMargin: subItem.profitMargin,
            profitAmount: subItem.profitAmount,
            totalCost: subItem.totalCost,
            totalPrice: subItem.totalPrice,
            isHidden: newIsHidden,
            order: subItem.order,
            createdAt: subItem.createdAt,
            updatedAt: subItem.updatedAt,
            elements: updatedElements,
          );
        }
      });

      // Notify parent of the change
      final updatedElements = subItem.elements
          ?.map((element) => element.copyWith(isHidden: newIsHidden))
          .toList();
      widget.onSubItemChanged?.call(
        PricingSubItemModel(
          id: subItem.id,
          pricingItemId: subItem.pricingItemId,
          name: subItem.name,
          description: subItem.description,
          notes: subItem.notes,
          images: subItem.images,
          profitMargin: subItem.profitMargin,
          profitAmount: subItem.profitAmount,
          totalCost: subItem.totalCost,
          totalPrice: subItem.totalPrice,
          isHidden: newIsHidden,
          order: subItem.order,
          createdAt: subItem.createdAt,
          updatedAt: subItem.updatedAt,
          elements: updatedElements,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل تحديث حالة الظهور: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _toggleElementVisibility(
    PricingSubItemModel subItem,
    PricingElementModel element,
    bool isVisible,
  ) async {
    final newIsHidden = !isVisible;

    try {
      await _apiDataSource.toggleElementVisibility(
        widget.projectId,
        widget.version,
        widget.item.id,
        subItem.id,
        element.id,
        newIsHidden,
      );

      final updatedVersion = await _apiDataSource.getPricingVersion(
        widget.projectId,
        widget.version,
      );
      final updatedItem = (updatedVersion.items ?? []).firstWhere(
        (item) => item.id == widget.item.id,
        orElse: () => widget.item,
      );
      final updatedSubItem = updatedItem.subItems?.firstWhere(
        (itemSubItem) => itemSubItem.id == subItem.id,
        orElse: () => subItem.copyWith(
          elements: (subItem.elements ?? [])
              .map(
                (e) =>
                    e.id == element.id ? e.copyWith(isHidden: newIsHidden) : e,
              )
              .toList(),
        ),
      );

      if (updatedSubItem != null) {
        widget.onSubItemChanged?.call(updatedSubItem);
      }
      widget.onItemChanged?.call(updatedItem);

      setState(() {
        _expandedSubItems[subItem.id] = true;
      });
      widget.onSubItemExpandedChanged?.call(
        Map<String, bool>.from(_expandedSubItems),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل تحديث حالة ظهور العنصر: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _toggleItemVisibility(bool isVisible) async {
    final newIsHidden = !isVisible;

    try {
      await _apiDataSource.toggleItemVisibility(
        widget.projectId,
        widget.version,
        widget.item.id,
        newIsHidden,
      );

      // Local state will be updated through parent callback
      // The parent component should handle updating the item list

      // Notify parent of the change
      final updatedSubItems = widget.item.subItems
          ?.map(
            (subItem) => subItem.copyWith(
              isHidden: newIsHidden,
              elements: subItem.elements
                  ?.map((element) => element.copyWith(isHidden: newIsHidden))
                  .toList(),
            ),
          )
          .toList();
      widget.onItemChanged?.call(
        PricingItemModel(
          id: widget.item.id,
          pricingVersionId: widget.item.pricingVersionId,
          name: widget.item.name,
          description: widget.item.description,
          isHidden: newIsHidden,
          profitMargin: widget.item.profitMargin,
          profitAmount: widget.item.profitAmount,
          totalCost: widget.item.totalCost,
          totalPrice: widget.item.totalPrice,
          order: widget.item.order,
          createdAt: widget.item.createdAt,
          updatedAt: widget.item.updatedAt,
          subItems: updatedSubItems,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل تحديث حالة الظهور: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _updateSavedElement(
    String subItemId,
    String elementId,
    PricingItem updatedItem,
    String currentCostType,
  ) async {
    // Cancel the timer since we're updating now
    _updateTimers[elementId]?.cancel();
    _updateTimers.remove(elementId);

    setState(() {
      _updatingElements[elementId] = true;
    });

    try {
      final newCostType = updatedItem.costType ?? currentCostType;

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
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل تحديث العنصر: ${e.toString()}'),
          ),
        );
      }
    }
  }

  List<PricingElementModel> _getAllElementsForSubItem(String subItemId) {
    final subItem = widget.item.subItems?.firstWhere(
      (si) => si.id == subItemId,
      orElse: () => widget.item.subItems?.first ?? widget.item.subItems!.first,
    );

    final savedElements = (subItem?.elements ?? []).toList();

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
    final headerContent = GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
        widget.onExpandedChanged?.call(_isExpanded);
      },
      child: PricingItemCardHeader(
        itemName: widget.item.name,
        itemIsHidden: widget.item.isHidden,
        onVisibilityChanged: (value) => _toggleItemVisibility(value),
        onToggleExpanded: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
          widget.onExpandedChanged?.call(_isExpanded);
        },
        onMenuPressed: _showItemContextMenu,
        isExpanded: _isExpanded,
        canShowFinancials: widget.showFinancials,
        showFinancials: widget.showFinancials,
        canViewFinancials: widget.canViewFinancials,
        totalCost: widget.item.totalCost,
        profitAmount: widget.item.profitAmount,
        pricingStatus: widget.pricingStatus,
      ),
    );

    return Container(
      clipBehavior: Clip.antiAlias,

      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C212B),
        border: Border.all(color: const Color(0xFF363C4A)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (widget.canReorderItem && widget.itemReorderIndex != null)
            ReorderableDelayedDragStartListener(
              index: widget.itemReorderIndex!,
              child: headerContent,
            )
          else
            headerContent,
          // Content (Collapsible)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PricingItemCardSubItemsList(
                    key: ValueKey('subitems-${widget.item.id}'),
                    item: widget.item,
                    showFinancials: widget.showFinancials,
                    canViewFinancials: widget.canViewFinancials,
                    canReorderSubItems: widget.canReorderSubItems,
                    canReorderElements: widget.canReorderElements,
                    expandedSubItems: _expandedSubItems,
                    localElements: _localElements,
                    savingElements: _savingElements,
                    updatingElements: _updatingElements,
                    uploadingImages: _uploadingImages,
                    deletingImages: _deletingImages,
                    selectedImageIndex: _selectedImageIndex,
                    localElementFocusNodes: _localElementFocusNodes,
                    subItemDescriptionControllers: _notesControllers,
                    subItemDescriptionFocusNodes: _notesFocusNodes,
                    subItemProfitControllers: widget.canViewFinancials
                        ? _profitControllers
                        : <String, TextEditingController>{},
                    onToggleSubItem: _toggleSubItem,
                    onToggleSubItemVisibility: _toggleSubItemVisibility,
                    onSubItemDescriptionChanged:
                        _scheduleSubItemDescriptionUpdate,
                    onSubItemProfitMarginChanged:
                        _scheduleSubItemProfitMarginUpdate,
                    onSubItemProfitMarginEditingComplete:
                        _flushSubItemProfitMargin,
                    onShowSubItemContextMenu: _showSubItemContextMenu,
                    onPickImages: _pickImages,
                    onPickImagesWithFilePicker: _pickImagesWithFilePicker,
                    onDeleteCurrentImage: (subItemId, imageUrl, imageIndex) =>
                        _deleteImage(subItemId, imageUrl),
                    onCropCurrentImage: (subItemId, imageUrl, imageIndex) =>
                        _cropExistingImage(subItemId, imageUrl, imageIndex),
                    onShowFullScreenImage: _showFullScreenImage,
                    onAddElement: _addLocalElement,
                    onReorderSubItems: _handleSubItemReorder,
                    onReorderElements: widget.onReorderElements,
                    onToggleElementVisibility: _toggleElementVisibility,
                    onDeleteElement: _deleteElement,
                    onElementChanged:
                        (
                          subItemId,
                          elementId,
                          element,
                          localElement,
                          isLocal,
                          updatedItem,
                        ) {
                          if (isLocal && localElement != null) {
                            String newCostType =
                                updatedItem.costType ?? localElement.costType;
                            if (updatedItem.quantity != null &&
                                updatedItem.unitPrice != null) {
                              newCostType = 'UNIT_BASED';
                            } else if (newCostType == 'TOTAL' &&
                                updatedItem.quantity == null &&
                                updatedItem.unitPrice == null) {
                              newCostType = 'TOTAL';
                            }

                            final updated = LocalElement(
                              tempId: localElement.tempId,
                              subItemId: localElement.subItemId,
                              name: updatedItem.description.trim(),
                              costType: newCostType,
                              unitCost: updatedItem.unitPrice,
                              quantity: updatedItem.quantity,
                              totalCost: newCostType == 'TOTAL'
                                  ? updatedItem.total
                                  : null,
                              isCompleted: localElement.isCompleted,
                            );
                            _updateLocalElement(subItemId, elementId, updated);
                          } else {
                            _pendingUpdates[element.id] = updatedItem;
                            _scheduleUpdateElement(
                              subItemId,
                              elementId,
                              updatedItem,
                              element.costType,
                            );
                          }
                        },
                    onElementFieldCompleted:
                        ({
                          required subItem,
                          required element,
                          required isLocal,
                          required localElement,
                          required addNext,
                        }) {
                          _completeElementEditing(
                            subItem: subItem,
                            element: element,
                            isLocal: isLocal,
                            localElement: localElement,
                            addNext: addNext,
                          );
                        },
                    onElementSubmitted:
                        ({
                          required subItem,
                          required element,
                          required isLocal,
                          required localElement,
                          required addNext,
                        }) {
                          _completeElementEditing(
                            subItem: subItem,
                            element: element,
                            isLocal: isLocal,
                            localElement: localElement,
                            addNext: addNext,
                          );
                        },
                    getAllElementsForSubItem: _getAllElementsForSubItem,
                  ),
                  PricingAddSubItemFooter(
                    showFinancials: widget.showFinancials,
                    canViewFinancials: widget.canViewFinancials,
                    totalCost: widget.item.totalCost,
                    totalPrice: widget.item.totalPrice,
                    onTap: widget.onAddSubItem ?? () {},
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

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.radius = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    _drawDashedPath(canvas, paint, path);
  }

  void _drawDashedPath(Canvas canvas, Paint paint, Path path) {
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final segmentLength = math.min(dashWidth, metric.length - distance);
        final segment = metric.extractPath(distance, distance + segmentLength);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
