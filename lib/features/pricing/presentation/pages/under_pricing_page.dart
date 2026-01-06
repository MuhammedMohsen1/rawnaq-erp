import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../data/datasources/pricing_api_datasource.dart';
import '../../data/models/pricing_version_model.dart';
import '../widgets/pricing_summary_sidebar.dart';
import '../widgets/pricing_item_card.dart';

class UnderPricingPage extends StatefulWidget {
  final String projectId;

  const UnderPricingPage({super.key, required this.projectId});

  @override
  State<UnderPricingPage> createState() => _UnderPricingPageState();
}

class _UnderPricingPageState extends State<UnderPricingPage> {
  final _apiDataSource = PricingApiDataSource();
  PricingVersionModel? _pricingVersion;
  bool _isLoading = true;
  String? _errorMessage;
  String? _projectName;
  // Track expanded states for main items (itemId -> isExpanded)
  final Map<String, bool> _itemExpandedStates = {};
  // Track expanded states for sub-items (itemId -> {subItemId -> isExpanded})
  final Map<String, Map<String, bool>> _subItemExpandedStates = {};

  @override
  void initState() {
    super.initState();
    _loadPricingData();
  }

  Future<void> _loadPricingData() async {
    // Preserve existing expanded states before reloading
    final preservedItemStates = Map<String, bool>.from(_itemExpandedStates);
    final preservedSubItemStates = <String, Map<String, bool>>{};
    for (var entry in _subItemExpandedStates.entries) {
      preservedSubItemStates[entry.key] = Map<String, bool>.from(entry.value);
    }

    // Only show loading on initial load (when we don't have data yet)
    final isInitialLoad = _pricingVersion == null;
    setState(() {
      if (isInitialLoad) {
        _isLoading = true;
      }
      _errorMessage = null;
    });

    try {
      // Get all pricing versions
      final versions = await _apiDataSource.getPricingVersions(
        widget.projectId,
      );

      if (versions.isEmpty) {
        // Create a new pricing version if none exists
        _pricingVersion = await _apiDataSource.createPricingVersion(
          widget.projectId,
        );
      } else {
        // Get the latest version
        final latestVersion = versions.first;
        _pricingVersion = await _apiDataSource.getPricingVersion(
          widget.projectId,
          latestVersion.version,
        );
      }

      // Restore preserved states and initialize new items/sub-items
      setState(() {
        _itemExpandedStates.clear();
        _subItemExpandedStates.clear();

        if (_pricingVersion?.items != null) {
          for (var item in _pricingVersion!.items!) {
            // Restore item expanded state or default to true
            _itemExpandedStates[item.id] = preservedItemStates[item.id] ?? true;

            // Restore sub-item expanded states
            if (item.subItems != null) {
              final subItemStates = <String, bool>{};
              final preservedSubStates = preservedSubItemStates[item.id] ?? {};

              for (var subItem in item.subItems!) {
                // Restore sub-item expanded state or default to false
                subItemStates[subItem.id] =
                    preservedSubStates[subItem.id] ?? false;
              }
              _subItemExpandedStates[item.id] = subItemStates;
            }
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل بيانات التسعير: ${e.toString()}';
      });
    } finally {
      setState(() {
        if (isInitialLoad) {
          _isLoading = false;
        }
      });
    }
  }

  Future<void> _addItem() async {
    if (_pricingVersion == null) return;

    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة فئة جديدة'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم الفئة',
            hintText: 'أدخل اسم الفئة',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _apiDataSource.addPricingItem(
          widget.projectId,
          _pricingVersion!.version,
          name: result,
        );
        await _loadPricingData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم إضافة الفئة بنجاح')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل إضافة الفئة: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _addSubItem(String itemId) async {
    if (_pricingVersion == null) return;

    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة فئة فرعية جديدة'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم الفئة الفرعية',
            hintText: 'أدخل اسم الفئة الفرعية',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _apiDataSource.addPricingSubItem(
          widget.projectId,
          _pricingVersion!.version,
          itemId,
          name: result,
        );
        await _loadPricingData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة الفئة الفرعية بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل إضافة الفئة الفرعية: ${e.toString()}')),
          );
        }
      }
    }
  }

  String _getStatusText() {
    if (_pricingVersion == null) return 'قيد التسعير';

    switch (_pricingVersion!.status) {
      case 'DRAFT':
        return 'مسودة';
      case 'PROFIT_PENDING':
        return 'انتظار الربح';
      case 'PENDING_APPROVAL':
        return 'في انتظار الموافقة';
      case 'APPROVED':
        return 'موافق عليه';
      case 'REJECTED':
        return 'مرفوض';
      default:
        return 'قيد التسعير';
    }
  }

  Color _getStatusColor() {
    if (_pricingVersion == null) return AppColors.info;

    switch (_pricingVersion!.status) {
      case 'DRAFT':
        return AppColors.textMuted;
      case 'PROFIT_PENDING':
        return AppColors.warning;
      case 'PENDING_APPROVAL':
        return AppColors.warning;
      case 'APPROVED':
        return AppColors.statusCompleted;
      case 'REJECTED':
        return AppColors.statusDelayed;
      default:
        return AppColors.info;
    }
  }

  String? _formatLastSaveTime(DateTime? dateTime) {
    if (dateTime == null) return null;

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // If less than a minute ago, show "الآن" (Now)
    if (difference.inSeconds < 60) {
      return null; // Will show "الآن" in the UI
    }

    // If less than an hour ago, show minutes
    if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return 'منذ $minutes ${minutes == 1 ? 'دقيقة' : 'دقائق'}';
    }

    // If less than a day ago, show hours
    if (difference.inDays < 1) {
      final hours = difference.inHours;
      return 'منذ $hours ${hours == 1 ? 'ساعة' : 'ساعات'}';
    }

    // If less than a week ago, show days
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'منذ $days ${days == 1 ? 'يوم' : 'أيام'}';
    }

    // If less than a month ago, show weeks
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks ${weeks == 1 ? 'أسبوع' : 'أسابيع'}';
    }

    // Otherwise, show formatted date in Arabic format
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ar');
    return dateFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPricingData,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

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
          _buildItemsList(),
          const SizedBox(height: 24),
          _buildAddItemButton(),
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
                    _buildItemsList(),
                    const SizedBox(height: 24),
                    _buildAddItemButton(),
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
                    _buildItemsList(),
                    const SizedBox(height: 24),
                    _buildAddItemButton(),
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
          _projectName ?? 'المشروع',
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
                _projectName ?? 'المشروع',
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
        if (_pricingVersion != null) ...[
          const SizedBox(height: 8),
          Text(
            'الإصدار: ${_pricingVersion!.version}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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

  void _handleItemExpandedChanged(String itemId, bool isExpanded) {
    setState(() {
      _itemExpandedStates[itemId] = isExpanded;
    });
  }

  void _handleSubItemExpandedChanged(
    String itemId,
    Map<String, bool> subItemStates,
  ) {
    setState(() {
      _subItemExpandedStates[itemId] = Map<String, bool>.from(subItemStates);
    });
  }

  Widget _buildItemsList() {
    if (_pricingVersion == null ||
        _pricingVersion!.items == null ||
        _pricingVersion!.items!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.folder_outlined, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                'لا توجد فئات بعد',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ابدأ بإضافة فئة جديدة',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _pricingVersion!.items!.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PricingItemCard(
            key: ValueKey('pricing-item-${item.id}'),
            projectId: widget.projectId,
            version: _pricingVersion!.version,
            item: item,
            initialIsExpanded: _itemExpandedStates[item.id] ?? true,
            initialSubItemExpandedStates: _subItemExpandedStates[item.id] ?? {},
            onExpandedChanged: (isExpanded) =>
                _handleItemExpandedChanged(item.id, isExpanded),
            onSubItemExpandedChanged: (subItemStates) =>
                _handleSubItemExpandedChanged(item.id, subItemStates),
            onItemDeleted: () => _loadPricingData(),
            onSubItemDeleted: (_) => _loadPricingData(),
            onItemChanged: (_) {
              // Reload data but preserve widget state using keys
              _loadPricingData();
            },
            onAddSubItem: () => _addSubItem(item.id),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddItemButton() {
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
          onTap: _addItem,
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
                'إضافة فئة جديدة',
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
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
      ),
      child: PricingSummarySidebar(
        grandTotal: _pricingVersion?.totalPrice ?? 0.0,
        lastSaveTime: _formatLastSaveTime(_pricingVersion?.updatedAt),
        onSubmit: () async {
          if (_pricingVersion == null) return;

          try {
            // Check if we need to calculate profit first
            if (_pricingVersion!.status == 'DRAFT' &&
                _pricingVersion!.items != null &&
                _pricingVersion!.items!.isNotEmpty) {
              // Calculate profit for all items
              final items = _pricingVersion!.items!
                  .map(
                    (item) => {
                      'itemId': item.id,
                      'profitMargin': item.profitMargin,
                    },
                  )
                  .toList();

              await _apiDataSource.calculateProfit(
                widget.projectId,
                _pricingVersion!.version,
                items: items,
              );

              // Reload to get updated status
              await _loadPricingData();
            }

            // Submit for approval
            if (_pricingVersion!.status == 'PROFIT_PENDING') {
              await _apiDataSource.submitForApproval(
                widget.projectId,
                _pricingVersion!.version,
              );

              await _loadPricingData();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إرسال التسعير للمراجعة')),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى حساب الربح أولاً قبل الإرسال للمراجعة'),
                  ),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('فشل إرسال التسعير: ${e.toString()}')),
              );
            }
          }
        },
        onSaveDraft: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم حفظ المسودة')));
        },
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
