import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/pricing_item.dart';

class PricingTableRow extends StatefulWidget {
  final PricingItem item;
  final VoidCallback? onDelete;
  final ValueChanged<PricingItem>? onChanged;
  final bool isNewRow;

  const PricingTableRow({
    super.key,
    required this.item,
    this.onDelete,
    this.onChanged,
    this.isNewRow = false,
  });

  @override
  State<PricingTableRow> createState() => _PricingTableRowState();
}

class _PricingTableRowState extends State<PricingTableRow> {
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _unitPriceController;
  bool _hasUnitPrice = false;
  bool _isEditingUnitPrice = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.item.description);
    _quantityController = TextEditingController(
      text: widget.item.quantity?.toString() ?? '',
    );
    _unitPriceController = TextEditingController(
      text: widget.item.unitPrice?.toString() ?? '',
    );
    // New rows start without unit price (no quantity and no unitPrice)
    _hasUnitPrice = !widget.isNewRow && 
                    widget.item.quantity != null && 
                    widget.item.unitPrice != null;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
    final total = quantity * unitPrice;
    
    if (widget.onChanged != null) {
      widget.onChanged!(PricingItem(
        id: widget.item.id,
        description: _descriptionController.text,
        quantity: quantity > 0 ? quantity : null,
        unitPrice: unitPrice > 0 ? unitPrice : null,
        total: total,
      ));
    }
  }

  void _handleDoubleTap() {
    if (!_hasUnitPrice) {
      setState(() {
        _hasUnitPrice = true;
        _isEditingUnitPrice = true;
      });
    } else if (!_isEditingUnitPrice) {
      // If already has unit price, allow editing again on double tap
      setState(() {
        _isEditingUnitPrice = true;
      });
    }
  }

  String _getCostDisplay() {
    if (!_hasUnitPrice) {
      return '= -';
    }

    final quantity = double.tryParse(_quantityController.text);
    final unitPrice = double.tryParse(_unitPriceController.text);

    if (quantity == null || quantity == 0 || unitPrice == null || unitPrice == 0) {
      return '= -';
    }

    final total = quantity * unitPrice;
    return '${quantity.toStringAsFixed(0)} × ${unitPrice.toStringAsFixed(3)} = ${total.toStringAsFixed(3)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: Container(
        height: 60.5,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Item Description
            Expanded(
              flex: 2,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A313D).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: _descriptionController,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '-',
                    hintStyle: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  onChanged: (_) {
                    if (widget.onChanged != null) {
                      _updateTotal();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Cost (KD) - Shows calculation or editable unit price
            Expanded(
              flex: 2,
              child: _isEditingUnitPrice
                  ? Row(
                      children: [
                        // Quantity input
                        Expanded(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A313D),
                              border: Border.all(color: const Color(0xFF363C4A)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextField(
                              controller: _quantityController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '-',
                                hintStyle: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 16,
                                ),
                              ),
                              onChanged: (_) {
                                setState(() {
                                  _isEditingUnitPrice = false;
                                });
                                _updateTotal();
                              },
                              onSubmitted: (_) {
                                setState(() {
                                  _isEditingUnitPrice = false;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '×',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Unit price input
                        Expanded(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A313D),
                              border: Border.all(color: const Color(0xFF363C4A)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextField(
                              controller: _unitPriceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                              autofocus: true,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '-',
                                hintStyle: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 16,
                                ),
                              ),
                              onChanged: (_) {
                                setState(() {
                                  _isEditingUnitPrice = false;
                                });
                                _updateTotal();
                              },
                              onSubmitted: (_) {
                                setState(() {
                                  _isEditingUnitPrice = false;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onDoubleTap: _handleDoubleTap,
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A313D),
                          border: Border.all(color: const Color(0xFF363C4A)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            _getCostDisplay(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            // Delete Button
            if (widget.onDelete != null)
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
