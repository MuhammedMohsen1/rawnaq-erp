import 'dart:async';
import 'package:flutter/material.dart';
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
      return totalCost != null && 
             totalCost! > 0 &&
             totalCost!.isFinite;
    }
  }
}

class PricingItemCard extends StatefulWidget {
  final String projectId;
  final int version;
  final PricingItemModel item;
  final ValueChanged<PricingItemModel>? onItemChanged;
  final VoidCallback? onAddSubItem;
  final bool initialIsExpanded;
  final Map<String, bool> initialSubItemExpandedStates;
  final ValueChanged<bool>? onExpandedChanged;
  final ValueChanged<Map<String, bool>>? onSubItemExpandedChanged;

  const PricingItemCard({
    super.key,
    required this.projectId,
    required this.version,
    required this.item,
    this.onItemChanged,
    this.onAddSubItem,
    this.initialIsExpanded = true,
    this.initialSubItemExpandedStates = const {},
    this.onExpandedChanged,
    this.onSubItemExpandedChanged,
  });

  @override
  State<PricingItemCard> createState() => _PricingItemCardState();
}

class _PricingItemCardState extends State<PricingItemCard> {
  final _apiDataSource = PricingApiDataSource();
  late bool _isExpanded;
  final Map<String, bool> _expandedSubItems = {};
  final Map<String, List<LocalElement>> _localElements = {}; // subItemId -> List<LocalElement>
  final Map<String, bool> _savingElements = {}; // tempId -> isSaving
  final Map<String, Timer?> _saveTimers = {}; // tempId -> debounce timer
  final Map<String, bool> _updatingElements = {}; // elementId -> isUpdating
  final Map<String, Timer?> _updateTimers = {}; // elementId -> debounce timer
  final Map<String, PricingItem> _pendingUpdates = {}; // elementId -> latest PricingItem values
  bool _isRestoringState = false; // Flag to prevent state reset during restoration

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialIsExpanded;
    // Initialize sub-items from parent-provided states
    if (widget.item.subItems != null) {
      for (var subItem in widget.item.subItems!) {
        _expandedSubItems[subItem.id] = widget.initialSubItemExpandedStates[subItem.id] ?? false;
        _localElements[subItem.id] = [];
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
        final parentState = widget.initialSubItemExpandedStates[subItem.id] ?? false;
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

  void _toggleSubItem(String subItemId) {
    setState(() {
      _expandedSubItems[subItemId] = !(_expandedSubItems[subItemId] ?? false);
    });
    // Notify parent of state change
    widget.onSubItemExpandedChanged?.call(Map<String, bool>.from(_expandedSubItems));
  }

  void _addLocalElement(String subItemId) {
    setState(() {
      final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
      final newElement = LocalElement(
        tempId: tempId,
        subItemId: subItemId,
      );
      
      // Create new list with new element at the TOP (first position)
      final currentList = _localElements[subItemId] ?? [];
      _localElements[subItemId] = [newElement, ...currentList];
      
      // Auto-expand the sub-item when adding element
      _expandedSubItems[subItemId] = true;
    });
    // Notify parent of state change
    widget.onSubItemExpandedChanged?.call(Map<String, bool>.from(_expandedSubItems));
  }

  void _updateLocalElement(String subItemId, String tempId, LocalElement updatedElement) {
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

  Future<void> _deleteElement(String subItemId, String elementId, bool isLocal) async {
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
      widget.onSubItemExpandedChanged?.call(Map<String, bool>.from(_expandedSubItems));
      
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

  Future<void> _saveElementToBackend(String subItemId, LocalElement localElement) async {
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
      widget.onSubItemExpandedChanged?.call(Map<String, bool>.from(_expandedSubItems));
      
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
            _localElements[subItemId]?.removeWhere((e) => e.tempId == localElement.tempId);
            _savingElements.remove(localElement.tempId);
          });
          
          // Update the widget with new data - parent will preserve expanded states
          widget.onItemChanged?.call(updatedItem);
        } else {
          // If item not found, still remove from local elements
          setState(() {
            _localElements[subItemId]?.removeWhere((e) => e.tempId == localElement.tempId);
            _savingElements.remove(localElement.tempId);
          });
        }
      } catch (e) {
        // If refresh fails, still remove from local elements
        setState(() {
          _localElements[subItemId]?.removeWhere((e) => e.tempId == localElement.tempId);
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
    widget.onSubItemExpandedChanged?.call(Map<String, bool>.from(_expandedSubItems));
    
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
      } else if (updatedItem.total > 0 && updatedItem.quantity == null && updatedItem.unitPrice == null) {
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
    final savedElements = (subItem?.elements ?? [])
        .toList()
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
    final filteredLocalElements = localElements.where((e) => !savedElementIds.contains(e.id)).toList();

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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.item.totalPrice.toStringAsFixed(0).replaceAllMapped(
                        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      )} د.ك',
                      style: const TextStyle(
                        fontFamily: 'Menlo',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'التكلفة: ${widget.item.totalCost.toStringAsFixed(0).replaceAllMapped(
                        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      )} د.ك',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
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
                  if (widget.item.subItems != null && widget.item.subItems!.isNotEmpty)
                    ...widget.item.subItems!.map((subItem) {
                      final isSubItemExpanded = _expandedSubItems[subItem.id] ?? false;
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
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                                      isSubItemExpanded ? Icons.expand_less : Icons.expand_more,
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
                                    if (allElements.isNotEmpty) ...[
                                      Text(
                                        '${allElements.length} عنصر',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 18),
                                      onPressed: () => _addLocalElement(subItem.id),
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
                              if (allElements.isNotEmpty) ...[
                                // Table Header
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
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Elements as Table Rows
                                // Display in order: newest local elements first (at top), then saved elements
                                ...allElements.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final element = entry.value;
                                  final isLocal = element.id.startsWith('temp-');
                                  
                                  // Safely find local element
                                  LocalElement? localElement;
                                  if (isLocal) {
                                    try {
                                      localElement = _localElements[subItem.id]?.firstWhere(
                                        (e) => e.tempId == element.id,
                                      );
                                    } catch (e) {
                                      localElement = null;
                                    }
                                  }
                                  
                                  final isSaving = (isLocal && localElement != null && (_savingElements[element.id] == true)) ||
                                                   (!isLocal && _updatingElements[element.id] == true);

                                  // Convert element to PricingItem for table row
                                  final pricingItem = PricingItem(
                                    id: element.id,
                                    description: element.name,
                                    quantity: element.costType == 'UNIT_BASED' ? element.quantity : null,
                                    unitPrice: element.costType == 'UNIT_BASED' ? element.unitCost : null,
                                    total: element.calculatedCost,
                                  );
                                  
                                  return Stack(
                                    key: ValueKey('element-${subItem.id}-${element.id}-$index'),
                                    children: [
                                      PricingTableRow(
                                        item: pricingItem,
                                        isNewRow: isLocal && localElement != null && !localElement.hasRequiredData,
                                        onDelete: () => _deleteElement(subItem.id, element.id, isLocal),
                                        onChanged: (updatedItem) {
                                          if (isLocal && localElement != null) {
                                            // Determine cost type based on what's filled
                                            String newCostType = localElement.costType;
                                            if (updatedItem.quantity != null && updatedItem.unitPrice != null) {
                                              newCostType = 'UNIT_BASED';
                                            } else if (updatedItem.total > 0 && updatedItem.quantity == null && updatedItem.unitPrice == null) {
                                              newCostType = 'TOTAL';
                                            }
                                            
                                            // Update local element - only update name if it's not empty
                                            final updated = LocalElement(
                                              tempId: localElement.tempId,
                                              subItemId: localElement.subItemId,
                                              name: updatedItem.description.trim(),
                                              costType: newCostType,
                                              unitCost: updatedItem.unitPrice,
                                              quantity: updatedItem.quantity,
                                              totalCost: newCostType == 'TOTAL' ? updatedItem.total : null,
                                              isCompleted: localElement.isCompleted,
                                            );
                                            _updateLocalElement(subItem.id, element.id, updated);
                                          } else {
                                            // Store latest values and schedule update with debounce
                                            _pendingUpdates[element.id] = updatedItem;
                                            _scheduleUpdateElement(
                                              subItem.id,
                                              element.id,
                                              updatedItem,
                                            );
                                          }
                                        },
                                        onFieldCompleted: () {
                                          // Trigger immediate save when user finishes editing field (blur or submit)
                                          if (isLocal && localElement != null && localElement.hasRequiredData && !localElement.isCompleted) {
                                            // Cancel debounce timer and save immediately
                                            _saveTimers[element.id]?.cancel();
                                            _saveTimers.remove(element.id);
                                            _saveElementToBackend(subItem.id, localElement);
                                          } else if (!isLocal) {
                                            // Cancel debounce timer and update immediately with latest values
                                            _updateTimers[element.id]?.cancel();
                                            _updateTimers.remove(element.id);
                                            final pendingItem = _pendingUpdates[element.id];
                                            if (pendingItem != null) {
                                              _pendingUpdates.remove(element.id);
                                              _updateSavedElement(subItem.id, element.id, pendingItem);
                                            }
                                          }
                                        },
                                      ),
                                      if (isSaving)
                                        Positioned.fill(
                                          child: Container(
                                            color: Colors.black.withOpacity(0.3),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
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
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                      border: Border.all(
                        color: const Color(0xFF4B5563),
                      ),
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
                    padding: const EdgeInsets.symmetric(vertical: 17.22, horizontal: 20),
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
                              widget.item.totalPrice.toStringAsFixed(0).replaceAllMapped(
                                RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                              style: const TextStyle(
                                fontFamily: 'Menlo',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'KD',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 14,
                                color: const Color(0xFF6B7280),
                              ),
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
