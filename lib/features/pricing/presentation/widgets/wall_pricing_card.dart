import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/pricing_item.dart';
import '../../domain/entities/wall_pricing.dart';
import 'pricing_table_row.dart';
import 'image_gallery_widget.dart';

class WallPricingCard extends StatefulWidget {
  final WallPricing wall;
  final ValueChanged<WallPricing>? onWallChanged;
  final VoidCallback? onAddItem;
  final VoidCallback? onAddImage;

  const WallPricingCard({
    super.key,
    required this.wall,
    this.onWallChanged,
    this.onAddItem,
    this.onAddImage,
  });

  @override
  State<WallPricingCard> createState() => _WallPricingCardState();
}

class _WallPricingCardState extends State<WallPricingCard> {
  late int _selectedImageIndex;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _selectedImageIndex = 0;
    _isExpanded = widget.wall.isExpanded;
  }

  String _getStatusText(WallStatus status) {
    switch (status) {
      case WallStatus.inProgress:
        return 'قيد التنفيذ';
      case WallStatus.completed:
        return 'مكتمل';
      case WallStatus.underPricing:
        return 'قيد التسعير';
    }
  }

  Color _getStatusColor(WallStatus status) {
    switch (status) {
      case WallStatus.inProgress:
        return const Color(0xFF4ADE80);
      case WallStatus.completed:
        return const Color(0xFF60A5FA);
      case WallStatus.underPricing:
        return AppColors.statusOnHold;
    }
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
                  child: Text(
                    widget.wall.name,
                    style: AppTextStyles.h4.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A313D),
                    border: Border.all(color: const Color(0xFF363C4A)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.wall.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStatusColor(widget.wall.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(widget.wall.status),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _getStatusColor(widget.wall.status),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Status',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                    if (widget.onWallChanged != null) {
                      widget.onWallChanged!(widget.wall.copyWith(isExpanded: _isExpanded));
                    }
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Left: Image Gallery
                Expanded(
                  flex: 2,
                  child: ImageGalleryWidget(
                    imageUrls: widget.wall.imageUrls,
                    selectedIndex: _selectedImageIndex,
                    onImageSelected: (index) {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    onAddImage: widget.onAddImage,
                  ),
                ),
                const SizedBox(width: 16),
                // Right: Pricing Table
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      // Table Rows
                      ...widget.wall.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return PricingTableRow(
                          item: item,
                          isNewRow: item.unitPrice == null && item.quantity == null,
                          onDelete: () {
                            final newItems = List<PricingItem>.from(widget.wall.items);
                            newItems.removeAt(index);
                            final updatedWall = widget.wall.copyWith(
                              items: newItems,
                              subtotal: widget.wall.calculateSubtotal(),
                            );
                            widget.onWallChanged?.call(updatedWall);
                          },
                          onChanged: (updatedItem) {
                            final newItems = List<PricingItem>.from(widget.wall.items);
                            newItems[index] = updatedItem.copyWith(
                              total: updatedItem.calculateTotal(),
                            );
                            final subtotal = newItems.fold<double>(0.0, (sum, item) => sum + item.total);
                            final updatedWall = widget.wall.copyWith(
                              items: newItems,
                              subtotal: subtotal,
                            );
                            widget.onWallChanged?.call(updatedWall);
                          },
                        );
                      }),
                      // Add Item Row Button
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
                          onTap: widget.onAddItem,
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
                              'إضافة صف',
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
                                  widget.wall.subtotal.toStringAsFixed(0).replaceAllMapped(
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

