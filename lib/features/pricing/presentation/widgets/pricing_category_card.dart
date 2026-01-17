import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/datasources/pricing_api_datasource.dart';
import '../../data/models/pricing_version_model.dart';

class PricingCategoryCard extends StatefulWidget {
  final String projectId;
  final int version;
  final PricingItemModel item;
  final VoidCallback onItemChanged;

  const PricingCategoryCard({
    super.key,
    required this.projectId,
    required this.version,
    required this.item,
    required this.onItemChanged,
  });

  @override
  State<PricingCategoryCard> createState() => _PricingCategoryCardState();
}

class _PricingCategoryCardState extends State<PricingCategoryCard> {
  final _apiDataSource = PricingApiDataSource();
  final Map<String, bool> _expandedSubItems = {};

  @override
  void initState() {
    super.initState();
    // Initialize all sub-items as collapsed
    if (widget.item.subItems != null) {
      for (var subItem in widget.item.subItems!) {
        _expandedSubItems[subItem.id] = false;
      }
    }
  }

  Future<void> _addSubItem() async {
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة عنصر جديد'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم عنصر جديد',
            hintText: 'أدخل اسم عنصر جديد',
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
          widget.version,
          widget.item.id,
          name: result,
        );
        widget.onItemChanged();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة البند الفرعية بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل إضافة البند الفرعية: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _addElement(String subItemId) async {
    final nameController = TextEditingController();
    final costTypeController = TextEditingController(text: 'UNIT_BASED');
    final unitCostController = TextEditingController();
    final quantityController = TextEditingController();
    final totalCostController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة عنصر جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم العنصر',
                    hintText: 'أدخل اسم العنصر',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: costTypeController.text,
                  decoration: const InputDecoration(labelText: 'نوع التكلفة'),
                  items: const [
                    DropdownMenuItem(
                      value: 'UNIT_BASED',
                      child: Text('حسب الوحدة'),
                    ),
                    DropdownMenuItem(value: 'TOTAL', child: Text('إجمالي')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      costTypeController.text = value ?? 'UNIT_BASED';
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (costTypeController.text == 'UNIT_BASED') ...[
                  TextField(
                    controller: unitCostController,
                    decoration: const InputDecoration(
                      labelText: 'تكلفة الوحدة',
                      hintText: '0.0',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'الكمية',
                      hintText: '0.0',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ] else ...[
                  TextField(
                    controller: totalCostController,
                    decoration: const InputDecoration(
                      labelText: 'التكلفة الإجمالية',
                      hintText: '0.0',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'costType': costTypeController.text,
                  'unitCost': unitCostController.text.isNotEmpty
                      ? double.tryParse(unitCostController.text)
                      : null,
                  'quantity': quantityController.text.isNotEmpty
                      ? double.tryParse(quantityController.text)
                      : null,
                  'totalCost': totalCostController.text.isNotEmpty
                      ? double.tryParse(totalCostController.text)
                      : null,
                });
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );

    if (result != null &&
        result['name'] != null &&
        result['name'].toString().isNotEmpty) {
      try {
        await _apiDataSource.addPricingElement(
          widget.projectId,
          widget.version,
          widget.item.id,
          subItemId,
          name: result['name'].toString(),
          costType: result['costType'].toString(),
          unitCost: result['unitCost'] as double?,
          quantity: result['quantity'] as double?,
          totalCost: result['totalCost'] as double?,
        );
        widget.onItemChanged();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة العنصر بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل إضافة العنصر: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _toggleSubItem(String subItemId) {
    setState(() {
      _expandedSubItems[subItemId] = !(_expandedSubItems[subItemId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.item.totalPrice.toStringAsFixed(2)} د.ك',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'التكلفة: ${widget.item.totalCost.toStringAsFixed(2)} د.ك',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Sub-Items List
          if (widget.item.subItems != null &&
              widget.item.subItems!.isNotEmpty) ...[
            ...widget.item.subItems!.map((subItem) {
              final isExpanded = _expandedSubItems[subItem.id] ?? false;
              return Column(
                children: [
                  // Sub-Item Header (Foldable)
                  InkWell(
                    onTap: () => _toggleSubItem(subItem.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.border.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
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
                          if (subItem.elements != null &&
                              subItem.elements!.isNotEmpty) ...[
                            Text(
                              '${subItem.elements!.length} عنصر',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () => _addElement(subItem.id),
                            tooltip: 'إضافة عنصر',
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Elements List (Expandable)
                  if (isExpanded) ...[
                    if (subItem.elements != null &&
                        subItem.elements!.isNotEmpty)
                      ...subItem.elements!.map((element) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldBackground,
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.border.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      element.name,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (element.description != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        element.description!,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (element.costType ==
                                            'UNIT_BASED') ...[
                                          Text(
                                            'الوحدة: ${element.unitCost?.toStringAsFixed(2) ?? '0.00'} د.ك',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            'الكمية: ${element.quantity?.toStringAsFixed(2) ?? '0.00'}',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ] else ...[
                                          Text(
                                            'التكلفة الإجمالية: ${element.totalCost?.toStringAsFixed(2) ?? '0.00'} د.ك',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${element.calculatedCost.toStringAsFixed(2)} د.ك',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                    else
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
              );
            }),
          ] else ...[
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
            child: InkWell(
              onTap: _addSubItem,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'إضافة عنصر',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
