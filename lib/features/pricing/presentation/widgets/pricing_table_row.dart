import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/pricing_item.dart';

class PricingTableRow extends StatefulWidget {
  final PricingItem item;
  final VoidCallback? onDelete;
  final ValueChanged<PricingItem>? onChanged;
  final VoidCallback? onFieldCompleted; // Called when user finishes editing (blur or submit)
  final bool isNewRow;

  const PricingTableRow({
    super.key,
    required this.item,
    this.onDelete,
    this.onChanged,
    this.onFieldCompleted,
    this.isNewRow = false,
  });

  @override
  State<PricingTableRow> createState() => _PricingTableRowState();
}

class _PricingTableRowState extends State<PricingTableRow> {
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _unitPriceController;
  late TextEditingController _totalController;
  bool _isUnitPriceMode =
      false; // false = direct total input, true = quantity × unitPrice
  DateTime? _lastTapTime;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.item.description,
    );
    _quantityController = TextEditingController(
      text: widget.item.quantity?.toString() ?? '',
    );
    _unitPriceController = TextEditingController(
      text: widget.item.unitPrice?.toString() ?? '',
    );
    _totalController = TextEditingController(
      text: widget.item.total > 0 ? widget.item.total.toStringAsFixed(3) : '',
    );
    // Check if item already has unit price mode (quantity and unitPrice exist)
    _isUnitPriceMode =
        widget.item.quantity != null && widget.item.unitPrice != null;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    if (_isUnitPriceMode) {
      // Calculate from quantity × unitPrice
      final quantity = double.tryParse(_quantityController.text) ?? 0.0;
      final unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
      final total = quantity * unitPrice;
      _totalController.text = total > 0 ? total.toStringAsFixed(3) : '';

      if (widget.onChanged != null) {
        widget.onChanged!(
          PricingItem(
            id: widget.item.id,
            description: _descriptionController.text,
            quantity: quantity > 0 ? quantity : null,
            unitPrice: unitPrice > 0 ? unitPrice : null,
            total: total,
          ),
        );
      }
    } else {
      // Direct total input
      final total = double.tryParse(_totalController.text) ?? 0.0;

      if (widget.onChanged != null) {
        widget.onChanged!(
          PricingItem(
            id: widget.item.id,
            description: _descriptionController.text,
            quantity: null,
            unitPrice: null,
            total: total,
          ),
        );
      }
    }
  }

  void _handleTripleTap() {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(milliseconds: 400)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTapTime = now;

    if (_tapCount == 3) {
      _tapCount = 0;
      // Toggle between direct total input and unit price mode
      setState(() {
        _isUnitPriceMode = !_isUnitPriceMode;
        if (_isUnitPriceMode) {
          // Switching to unit price mode - initialize if empty
          if (_quantityController.text.isEmpty &&
              widget.item.quantity != null) {
            _quantityController.text = widget.item.quantity.toString();
          }
          if (_unitPriceController.text.isEmpty &&
              widget.item.unitPrice != null) {
            _unitPriceController.text = widget.item.unitPrice.toString();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTripleTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 60.5,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: const Color(0xFF2A313D).withOpacity(0.3),
        ),
        child: Row(
          children: [
            SizedBox(width: 8),
            // Item Description
            Expanded(
              flex: 2,
              child: TextField(
                controller: _descriptionController,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '-',
                  hintStyle: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
                onChanged: (_) {
                  if (widget.onChanged != null) {
                    _updateTotal();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            // Cost (KD) - Direct total input or unit price mode
            Expanded(
              flex: 2,
              child: _isUnitPriceMode
                  ? Row(
                      children: [
                        // Quantity input
                        Expanded(
                          child: TextField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                              hintText: '-',
                              hintStyle: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 18,
                              ),
                              contentPadding: EdgeInsets.zero,
                              filled: false,
                            ),
                            onChanged: (_) => _updateTotal(),
                            onEditingComplete: () {
                              widget.onFieldCompleted?.call();
                            },
                            onSubmitted: (_) {
                              widget.onFieldCompleted?.call();
                            },
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
                          child: TextField(
                            controller: _unitPriceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '-',
                              hintStyle: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                              contentPadding: EdgeInsets.zero,
                              filled: false,
                            ),
                            onChanged: (_) => _updateTotal(),
                            onEditingComplete: () {
                              widget.onFieldCompleted?.call();
                            },
                            onSubmitted: (_) {
                              widget.onFieldCompleted?.call();
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '=',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Total display (read-only, calculated)
                        Expanded(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A313D),
                              border: Border.all(
                                color: const Color(0xFF363C4A),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  widget.item.total > 0
                                      ? widget.item.total.toStringAsFixed(3)
                                      : '-',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '=',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),

                        Expanded(
                          child: GestureDetector(
                            onTap: _handleTripleTap,
                            child: TextField(
                              controller: _totalController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*'),
                                ),
                              ],
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '-',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 18,
                                    ),
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                              ),
                              onChanged: (_) => _updateTotal(),
                              onEditingComplete: () {
                                widget.onFieldCompleted?.call();
                              },
                              onSubmitted: (_) {
                                widget.onFieldCompleted?.call();
                              },
                            ),
                          ),
                        ),
                      ],
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
                    color: AppColors.delete,
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
