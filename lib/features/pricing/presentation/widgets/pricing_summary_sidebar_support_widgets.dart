import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/arabic_number_input_formatter.dart';
import 'pricing_summary_sidebar.dart';

class PricingSummaryMetricCard extends StatelessWidget {
  final String label;
  final String valueLabel;
  final Color? valueColor;
  final double fontSize;
  final bool compact;

  const PricingSummaryMetricCard({
    super.key,
    required this.label,
    required this.valueLabel,
    this.valueColor,
    this.fontSize = 12,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 4 : 6),
      decoration: BoxDecoration(
        color: const Color(0xFF15181E),
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
        border: Border.all(color: const Color(0xFF363C4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: compact ? 7 : 8,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            valueLabel,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class PricingSummaryDeductionSummaryRow extends StatelessWidget {
  final String deductionLabel;
  final String deductionValueLabel;
  final String totalAfterLabel;
  final String totalAfterValueLabel;
  final bool isMobile;
  final bool isTablet;

  const PricingSummaryDeductionSummaryRow({
    super.key,
    required this.deductionLabel,
    required this.deductionValueLabel,
    required this.totalAfterLabel,
    required this.totalAfterValueLabel,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.bodySmall.copyWith(
      fontSize: isMobile ? 9 : (isTablet ? 10 : 11),
      color: AppColors.textSecondary,
    );
    final valueStyle = AppTextStyles.bodyMedium.copyWith(
      fontSize: isMobile ? 10 : (isTablet ? 11 : 12),
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF15181E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF363C4A)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deductionLabel, style: textStyle),
                const SizedBox(height: 4),
                Text(deductionValueLabel, style: valueStyle),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(totalAfterLabel, style: textStyle),
                const SizedBox(height: 4),
                Text(
                  totalAfterValueLabel,
                  style: valueStyle.copyWith(color: const Color(0xFF10B981)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PricingSummaryNotesEditor extends StatelessWidget {
  final bool isAdminOrManager;
  final bool isMobile;
  final bool isNotesExpanded;
  final bool isRefreshingDefaultNotes;
  final List<TextEditingController> noteControllers;
  final List<FocusNode> noteFocusNodes;
  final VoidCallback onAddNote;
  final void Function(int index) onRemoveNote;
  final VoidCallback onToggleExpanded;
  final Future<void> Function() onRefreshDefaultNotes;

  const PricingSummaryNotesEditor({
    super.key,
    required this.isAdminOrManager,
    required this.isMobile,
    required this.isNotesExpanded,
    required this.isRefreshingDefaultNotes,
    required this.noteControllers,
    required this.noteFocusNodes,
    required this.onAddNote,
    required this.onRemoveNote,
    required this.onToggleExpanded,
    required this.onRefreshDefaultNotes,
  });

  @override
  Widget build(BuildContext context) {
    if (!isAdminOrManager) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 4 : 6,
        vertical: isMobile ? 2 : 3,
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 4 : 6),
        decoration: BoxDecoration(
          color: const Color(0xFF15181E),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF363C4A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'ملاحظات التسعير',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: isMobile ? 10 : 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (isRefreshingDefaultNotes)
                  SizedBox(
                    width: isMobile ? 10 : 12,
                    height: isMobile ? 10 : 12,
                    child: const CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                IconButton(
                  iconSize: isMobile ? 14 : 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onRefreshDefaultNotes,
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  iconSize: isMobile ? 14 : 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onToggleExpanded,
                  icon: Icon(
                    isNotesExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ),
                Tooltip(
                  message: 'إضافة ملاحظة',
                  child: InkWell(
                    onTap: onAddNote,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.add_circle_outline,
                        size: isMobile ? 14 : 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isNotesExpanded) ...[
              SizedBox(height: isMobile ? 4 : 6),
              ...List.generate(
                noteControllers.length,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: isMobile ? 4 : 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: isMobile ? 6 : 8,
                          right: isMobile ? 4 : 6,
                          left: 2,
                        ),
                        child: Text(
                          '•',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: isMobile ? 12 : 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: noteControllers[index],
                          focusNode: noteFocusNodes[index],
                          decoration: InputDecoration(
                            hintText: 'الملاحظة',
                            hintStyle: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: isMobile ? 10 : 11,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0F1217),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: Color(0xFF363C4A),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: Color(0xFF363C4A),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 8 : 10,
                              vertical: isMobile ? 6 : 8,
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          style: TextStyle(fontSize: isMobile ? 11 : 12),
                        ),
                      ),
                      if (noteControllers.length > 1)
                        InkWell(
                          onTap: () => onRemoveNote(index),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: isMobile ? 4 : 6,
                              left: 4,
                            ),
                            child: Icon(
                              Icons.remove_circle_outline,
                              size: isMobile ? 14 : 16,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PricingSummaryDeductionControl extends StatelessWidget {
  final bool isAdminOrManager;
  final bool isMobile;
  final TextEditingController deductionController;
  final FocusNode deductionFocusNode;
  final bool showLineItemPricesInPdf;
  final ValueChanged<bool> onShowLineItemPricesChanged;
  final ValueChanged<String> onDeductionChanged;

  const PricingSummaryDeductionControl({
    super.key,
    required this.isAdminOrManager,
    required this.isMobile,
    required this.deductionController,
    required this.deductionFocusNode,
    required this.showLineItemPricesInPdf,
    required this.onShowLineItemPricesChanged,
    required this.onDeductionChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!isAdminOrManager) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 4 : 6,
        vertical: isMobile ? 3 : 4,
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 4 : 6),
        decoration: BoxDecoration(
          color: const Color(0xFF15181E),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF363C4A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'قيمة الخصم',
              style: AppTextStyles.caption.copyWith(
                fontSize: isMobile ? 10 : 11,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: isMobile ? 4 : 6),
            _PdfOptionCheckbox(
              value: showLineItemPricesInPdf,
              onChanged: onShowLineItemPricesChanged,
              label: 'إظهار سعر كل بند في PDF',
              isMobile: isMobile,
            ),
            SizedBox(height: isMobile ? 4 : 6),
            TextField(
              controller: deductionController,
              focusNode: deductionFocusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                ArabicNumberInputFormatter(),
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
              ],
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: isMobile ? 11 : 12,
              ),
              decoration: InputDecoration(
                hintText: 'أدخل الخصم (KD)',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: isMobile ? 10 : 11,
                ),
                filled: true,
                fillColor: const Color(0xFF0F1217),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF363C4A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF363C4A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 10,
                  vertical: isMobile ? 6 : 8,
                ),
              ),
              onChanged: onDeductionChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class PricingSummaryExportActions extends StatelessWidget {
  final bool isMobile;
  final bool showReturnToPricing;
  final bool isAdminOrManager;
  final bool isApproved;
  final bool isProfitPending;
  final bool isUnderPricing;
  final bool isDraft;
  final VoidCallback? onSubmit;
  final VoidCallback? onReturnToPricing;
  final VoidCallback? onArchiveProject;
  final VoidCallback? onConfirmPricing;
  final ValueChanged<PricingExportOptions>? onExportPdf;
  final ValueChanged<PricingExportOptions>? onExportImages;
  final VoidCallback? onExportContractPdf;
  final VoidCallback? onConfirmContract;
  final VoidCallback? onReturnContractToPricing;
  final PricingExportOptions exportOptions;

  const PricingSummaryExportActions({
    super.key,
    required this.isMobile,
    required this.showReturnToPricing,
    required this.isAdminOrManager,
    required this.isApproved,
    required this.isProfitPending,
    required this.isUnderPricing,
    required this.isDraft,
    required this.onSubmit,
    required this.onReturnToPricing,
    required this.onArchiveProject,
    required this.onConfirmPricing,
    required this.onExportPdf,
    required this.onExportImages,
    required this.onExportContractPdf,
    required this.onConfirmContract,
    required this.onReturnContractToPricing,
    required this.exportOptions,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];
    final buttonHeight = isMobile ? 30.0 : 28.0;
    final buttonFontSize = 10.0;
    final iconSize = isMobile ? 14.0 : 12.0;
    final buttonSpacing = isMobile ? 3.0 : 4.0;

    Widget buildButton({
      required Widget child,
      required VoidCallback? onPressed,
      required Color backgroundColor,
      Color? foregroundColor,
      double? height,
      bool isOutlined = false,
      Color? borderColor,
    }) {
      final btnHeight = height ?? buttonHeight;
      return isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: foregroundColor ?? backgroundColor,
                side: BorderSide(color: borderColor ?? backgroundColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                minimumSize: Size(double.infinity, btnHeight),
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor ?? Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
                minimumSize: Size(double.infinity, btnHeight),
              ),
              child: child,
            );
    }

    if (isProfitPending) {
      if (onExportContractPdf != null && isAdminOrManager) {
        buttons.add(
          buildButton(
            onPressed: onExportContractPdf,
            backgroundColor: const Color(0xFF6366F1),
            isOutlined: true,
            borderColor: const Color(0xFF6366F1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.picture_as_pdf, size: iconSize),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  'تصدير العقد',
                  style: AppTextStyles.buttonLarge.copyWith(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      if (onConfirmContract != null && isAdminOrManager) {
        buttons.add(
          buildButton(
            onPressed: onConfirmContract,
            backgroundColor: const Color(0xFF10B981),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: iconSize),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  'تأكيد العقد',
                  style: AppTextStyles.buttonLarge.copyWith(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (onExportPdf != null) {
        buttons.add(
          buildButton(
            onPressed: () => onExportPdf!(exportOptions),
            backgroundColor: const Color(0xFF6366F1),
            isOutlined: true,
            borderColor: const Color(0xFF6366F1),
            height: buttonHeight - 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.picture_as_pdf, size: iconSize),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  'تصدير PDF',
                  style: AppTextStyles.buttonLarge.copyWith(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      if (onExportImages != null) {
        buttons.add(
          buildButton(
            onPressed: () => onExportImages!(exportOptions),
            backgroundColor: const Color(0xFF10B981),
            isOutlined: true,
            borderColor: const Color(0xFF10B981),
            height: buttonHeight - 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: iconSize),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  'تصدير كصورة',
                  style: AppTextStyles.buttonLarge.copyWith(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (!showReturnToPricing &&
        !(isAdminOrManager && isApproved) &&
        !isProfitPending) {
      buttons.add(
        buildButton(
          onPressed: onSubmit,
          backgroundColor: const Color(0xFF135BEC),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send, size: iconSize),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                'إرسال التسعير للتوقيع',
                style: AppTextStyles.buttonLarge.copyWith(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (showReturnToPricing && onReturnToPricing != null && isAdminOrManager) {
      buttons.add(
        buildButton(
          onPressed: onReturnToPricing,
          backgroundColor: AppColors.error,
          isOutlined: true,
          borderColor: AppColors.error,
          height: buttonHeight - 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, size: iconSize),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                'إرجاع للتسعير',
                style: AppTextStyles.buttonLarge.copyWith(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (onArchiveProject != null) {
      buttons.add(
        buildButton(
          onPressed: onArchiveProject,
          backgroundColor: AppColors.error,
          isOutlined: true,
          borderColor: AppColors.error,
          height: buttonHeight - 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.archive_outlined, size: iconSize),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                'أرشفة المشروع',
                style: AppTextStyles.buttonLarge.copyWith(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...buttons.map(
            (btn) => Padding(
              padding: EdgeInsets.only(bottom: buttonSpacing),
              child: btn,
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, btnConstraints) {
        final availableWidth = btnConstraints.maxWidth;
        final buttonsPerRow = availableWidth >= 1200 ? 3 : 2;
        final buttonWidth =
            (availableWidth - (buttonSpacing * (buttonsPerRow - 1))) /
            buttonsPerRow;

        return Wrap(
          spacing: buttonSpacing,
          runSpacing: buttonSpacing,
          alignment: WrapAlignment.start,
          children: buttons
              .map((btn) => SizedBox(width: buttonWidth, child: btn))
              .toList(),
        );
      },
    );
  }
}

class _PdfOptionCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final bool isMobile;

  const _PdfOptionCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          SizedBox(
            width: isMobile ? 18 : 20,
            height: isMobile ? 18 : 20,
            child: Checkbox(
              value: value,
              onChanged: (nextValue) => onChanged(nextValue ?? false),
              activeColor: AppColors.background,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontSize: isMobile ? 10 : 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
