import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../data/mock_pricing_repository.dart';
import '../../domain/entities/pricing_data.dart';
import '../../domain/entities/pricing_item.dart';
import '../../domain/entities/wall_pricing.dart';
import '../widgets/expense_group_card.dart';
import '../widgets/wall_pricing_card.dart';
import '../widgets/pricing_summary_sidebar.dart';
import '../../domain/entities/expense_group.dart';

class UnderPricingPage extends StatefulWidget {
  final String projectId;

  const UnderPricingPage({super.key, required this.projectId});

  @override
  State<UnderPricingPage> createState() => _UnderPricingPageState();
}

class _UnderPricingPageState extends State<UnderPricingPage> {
  late PricingData _pricingData;
  final _mockRepository = MockPricingRepository();

  @override
  void initState() {
    super.initState();
    _pricingData = _mockRepository.getPricingData(widget.projectId);
  }

  void _updatePricingData(PricingData newData) {
    setState(() {
      // Recalculate all subtotals and grand total
      final updatedWalls = newData.walls.map((wall) {
        final updatedItems = wall.items.map((item) {
          return item.copyWith(total: item.calculateTotal());
        }).toList();
        return wall.copyWith(
          items: updatedItems,
          subtotal: updatedItems.fold<double>(
            0.0,
            (sum, item) => sum + item.total,
          ),
        );
      }).toList();

      final updatedExpenseGroups = newData.expenseGroups.map((group) {
        final updatedItems = group.items.map((item) {
          return item.copyWith(total: item.calculateTotal());
        }).toList();
        return group.copyWith(
          items: updatedItems,
          subtotal: updatedItems.fold<double>(
            0.0,
            (sum, item) => sum + item.total,
          ),
        );
      }).toList();

      final expenseGroupsTotal = updatedExpenseGroups.fold(
        0.0,
        (sum, group) => sum + group.subtotal,
      );
      final wallsTotal = updatedWalls.fold(
        0.0,
        (sum, wall) => sum + wall.subtotal,
      );
      final grandTotal = expenseGroupsTotal + wallsTotal;

      _pricingData = newData.copyWith(
        expenseGroups: updatedExpenseGroups,
        walls: updatedWalls,
        grandTotal: grandTotal,
      );
    });
  }

  void _addExpenseGroupItem(String groupId) {
    final groupIndex = _pricingData.expenseGroups.indexWhere(
      (g) => g.id == groupId,
    );
    if (groupIndex == -1) return;

    final group = _pricingData.expenseGroups[groupIndex];
    final newItem = PricingItem(
      id: 'group-$groupId-${DateTime.now().millisecondsSinceEpoch}',
      description: '',
      quantity: null,
      unitPrice: null,
      total: 0.0,
    );
    final newItems = [...group.items, newItem];
    final updatedGroup = group.copyWith(
      items: newItems,
      subtotal: group.calculateSubtotal(),
    );

    final newGroups = List<ExpenseGroup>.from(_pricingData.expenseGroups);
    newGroups[groupIndex] = updatedGroup;
    _updatePricingData(_pricingData.copyWith(expenseGroups: newGroups));
  }

  void _addWallItem(String wallId) {
    final wallIndex = _pricingData.walls.indexWhere((w) => w.id == wallId);
    if (wallIndex == -1) return;

    final wall = _pricingData.walls[wallIndex];
    final newItem = PricingItem(
      id: 'wall-$wallId-${DateTime.now().millisecondsSinceEpoch}',
      description: '',
      quantity: null,
      unitPrice: null,
      total: 0.0,
    );
    final newItems = [...wall.items, newItem];
    final updatedWall = wall.copyWith(
      items: newItems,
      subtotal: wall.calculateSubtotal(),
    );

    final newWalls = List<WallPricing>.from(_pricingData.walls);
    newWalls[wallIndex] = updatedWall;
    _updatePricingData(_pricingData.copyWith(walls: newWalls));
  }

  void _addWallImage(String wallId) {
    // Placeholder for adding image
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('إضافة صورة - قريباً')));
  }

  String _getStatusText() {
    return 'قيد التسعير';
  }

  Color _getStatusColor() {
    return AppColors.statusOnHold;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreadcrumb(),
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSectionTitle(),
          const SizedBox(height: 16),
          // Expense Groups (without images)
          ..._pricingData.expenseGroups.map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildExpenseGroupCard(group),
            ),
          ),
          const SizedBox(height: 24),
          // Walls (with images)
          ..._pricingData.walls.map(
            (wall) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildWallCard(wall),
            ),
          ),
          const SizedBox(height: 24),
          _buildAddNewExpensesButton(),
          const SizedBox(height: 24),
          _buildSidebar(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreadcrumb(),
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(),
                    const SizedBox(height: 16),
                    // Expense Groups (without images)
                    ..._pricingData.expenseGroups.map(
                      (group) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildExpenseGroupCard(group),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Walls (with images)
                    ..._pricingData.walls.map(
                      (wall) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildWallCard(wall),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAddNewExpensesButton(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              _buildSidebar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreadcrumb(),
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(),
                    const SizedBox(height: 16),
                    // Expense Groups (without images)
                    ..._pricingData.expenseGroups.map(
                      (group) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildExpenseGroupCard(group),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Walls (with images)
                    ..._pricingData.walls.map(
                      (wall) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildWallCard(wall),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAddNewExpensesButton(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              _buildSidebar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go(AppRoutes.projects),
          child: Text(
            'المشاريع',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.chevron_left,
          color: AppColors.textSecondary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          _pricingData.projectName,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.chevron_left,
          color: AppColors.textSecondary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          'التسعير',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _pricingData.projectName,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.75,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                border: Border.all(color: _getStatusColor().withOpacity(0.2)),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'العميل: ${_pricingData.clientName} • ${_pricingData.startDate}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return Text(
      'تسعير الجدران',
      style: AppTextStyles.h3.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildExpenseGroupCard(ExpenseGroup group) {
    return ExpenseGroupCard(
      group: group,
      onGroupChanged: (updatedGroup) {
        final newGroups = List<ExpenseGroup>.from(_pricingData.expenseGroups);
        final index = newGroups.indexWhere((g) => g.id == group.id);
        if (index != -1) {
          newGroups[index] = updatedGroup;
          _updatePricingData(_pricingData.copyWith(expenseGroups: newGroups));
        }
      },
      onAddItem: () => _addExpenseGroupItem(group.id),
    );
  }

  Widget _buildWallCard(WallPricing wall) {
    return WallPricingCard(
      wall: wall,
      onWallChanged: (updatedWall) {
        final newWalls = List<WallPricing>.from(_pricingData.walls);
        final index = newWalls.indexWhere((w) => w.id == wall.id);
        if (index != -1) {
          newWalls[index] = updatedWall;
          _updatePricingData(_pricingData.copyWith(walls: newWalls));
        }
      },
      onAddItem: () => _addWallItem(wall.id),
      onAddImage: () => _addWallImage(wall.id),
    );
  }

  Widget _buildAddNewExpensesButton() {
    return Container(
      width: double.infinity,
      height: 152,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: const Color(0xFF4B5563),
          strokeWidth: 2,
        ),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('إضافة مصروفات جديدة - قريباً')),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A313D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'إضافة مصروفات جديدة',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return PricingSummarySidebar(
      grandTotal: _pricingData.grandTotal,
      lastSaveTime: _pricingData.lastSaveTime,
      onSubmit: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال التسعير للمراجعة')),
        );
      },
      onSaveDraft: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حفظ المسودة')));
      },
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
        final segmentLength = min(dashWidth, metric.length - distance);
        final segment = metric.extractPath(distance, distance + segmentLength);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
