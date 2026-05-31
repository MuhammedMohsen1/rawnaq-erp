import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/arabic_number_input_formatter.dart';
import '../../../settings/data/datasources/settings_api_datasource.dart';

class PricingExportOptions {
  final bool showDeductionBreakdown;
  final bool showLineItemPrices;

  const PricingExportOptions({
    required this.showDeductionBreakdown,
    required this.showLineItemPrices,
  });
}

class PricingSummarySidebar extends StatefulWidget {
  final double grandTotal;
  final double originalTotalAmount;
  final double deductionAmount;
  final double totalAmountAfterDeduction;
  final double? totalCost;
  final double? totalProfit;
  final int totalElements;
  final String? lastSaveTime;
  final VoidCallback? onSubmit;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onReturnToPricing;
  final VoidCallback? onAcceptPricing;
  final VoidCallback? onMakeProfit;
  final VoidCallback? onConfirmPricing;
  final ValueChanged<PricingExportOptions>? onExportPdf;
  final ValueChanged<PricingExportOptions>? onExportImages;
  final VoidCallback? onExportContractPdf;
  final VoidCallback? onConfirmContract;
  final VoidCallback? onReturnContractToPricing;
  final VoidCallback? onArchiveProject;
  final bool showReturnToPricing;
  final bool isAdminOrManager;
  final bool isPendingApproval;
  final bool isPendingSignature;
  final bool isApproved;
  final bool isProfitPending;
  final bool isDraft;
  final bool isUnderPricing;
  final String? pricingVersionNotes;
  final Function(String)? onUpdateNotes;
  final Function(double)? onBulkProfitMarginUpdate;
  final Function(double)? onDeductionAmountChanged;
  final Function(double)? onDeductionAmountApplied;
  final bool showFinancials;

  const PricingSummarySidebar({
    super.key,
    required this.grandTotal,
    required this.originalTotalAmount,
    required this.deductionAmount,
    required this.totalAmountAfterDeduction,
    this.totalCost,
    this.totalProfit,
    required this.totalElements,
    this.lastSaveTime,
    this.onSubmit,
    this.onSaveDraft,
    this.onReturnToPricing,
    this.onAcceptPricing,
    this.onMakeProfit,
    this.onConfirmPricing,
    this.onExportPdf,
    this.onExportImages,
    this.onExportContractPdf,
    this.onConfirmContract,
    this.onReturnContractToPricing,
    this.onArchiveProject,
    this.showReturnToPricing = false,
    this.isAdminOrManager = false,
    this.isPendingApproval = false,
    this.isApproved = false,
    this.isProfitPending = false,
    this.pricingVersionNotes,
    this.onUpdateNotes,
    this.onBulkProfitMarginUpdate,
    this.onDeductionAmountChanged,
    this.onDeductionAmountApplied,
    required this.isDraft,
    required this.isUnderPricing,
    required this.isPendingSignature,
    this.showFinancials = true,
  });

  @override
  State<PricingSummarySidebar> createState() => _PricingSummarySidebarState();
}

class _PricingSummarySidebarState extends State<PricingSummarySidebar> {
  final SettingsApiDataSource _settingsApi = SettingsApiDataSource();
  List<TextEditingController> _noteControllers = [];
  List<FocusNode> _noteFocusNodes = [];
  Timer? _notesSaveTimer;
  final TextEditingController _bulkProfitController = TextEditingController();
  final TextEditingController _deductionController = TextEditingController();
  final FocusNode _deductionFocusNode = FocusNode();
  Timer? _deductionSaveTimer;
  bool _isNotesExpanded = false;
  bool _isRefreshingDefaultNotes = false;
  bool _showDeductionBreakdownInPdf = false;
  bool _showLineItemPricesInPdf = true;

  @override
  void initState() {
    super.initState();
    _initializeNoteControllers();
    _deductionController.text = _formatPlainNumber(widget.deductionAmount);
  }

  void _initializeNoteControllers() {
    // Dispose existing controllers
    for (var controller in _noteControllers) {
      controller.dispose();
    }
    for (var focusNode in _noteFocusNodes) {
      focusNode.dispose();
    }

    // Parse notes into list of items
    final notes = widget.pricingVersionNotes ?? '';
    final noteItems = notes
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    // If no items, start with one empty item
    if (noteItems.isEmpty) {
      noteItems.add('');
    }

    // Create controllers for each item
    _noteControllers = noteItems
        .map((item) => TextEditingController(text: item))
        .toList();
    _noteFocusNodes = noteItems.map((_) => FocusNode()).toList();

    // Add listeners to all controllers
    for (var controller in _noteControllers) {
      controller.addListener(_onNoteItemChanged);
    }
  }

  @override
  void didUpdateWidget(PricingSummarySidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pricingVersionNotes != oldWidget.pricingVersionNotes) {
      final isEditingNotes = _noteFocusNodes.any((node) => node.hasFocus);
      if (!isEditingNotes) {
        _initializeNoteControllers();
      }
    }
    if (widget.deductionAmount != oldWidget.deductionAmount) {
      if (!_deductionFocusNode.hasFocus) {
        _deductionController.text = _formatPlainNumber(widget.deductionAmount);
      }
    }
  }

  @override
  void dispose() {
    _notesSaveTimer?.cancel();
    _deductionSaveTimer?.cancel();
    _bulkProfitController.dispose();
    _deductionController.dispose();
    _deductionFocusNode.dispose();
    for (var controller in _noteControllers) {
      controller.removeListener(_onNoteItemChanged);
      controller.dispose();
    }
    for (var focusNode in _noteFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onNoteItemChanged() {
    // Cancel previous timer
    _notesSaveTimer?.cancel();

    // Set up new debounced save timer
    _notesSaveTimer = Timer(const Duration(milliseconds: 800), () {
      _saveNotes();
    });
  }

  void _saveNotes() {
    if (widget.onUpdateNotes != null) {
      final notes = _noteControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .join('\n');
      widget.onUpdateNotes!(notes);
    }
  }

  void _addNoteItem() {
    setState(() {
      final newController = TextEditingController();
      newController.addListener(_onNoteItemChanged);
      _noteControllers.add(newController);
      _noteFocusNodes.add(FocusNode());
    });
  }

  void _removeNoteItem(int index) {
    if (_noteControllers.length > 1) {
      setState(() {
        _noteControllers[index].removeListener(_onNoteItemChanged);
        _noteControllers[index].dispose();
        _noteControllers.removeAt(index);
        _noteFocusNodes[index].dispose();
        _noteFocusNodes.removeAt(index);
        _saveNotes();
      });
    }
  }

  Future<void> _refreshDefaultNotes() async {
    if (_isRefreshingDefaultNotes || widget.onUpdateNotes == null) return;

    setState(() {
      _isRefreshingDefaultNotes = true;
      _isNotesExpanded = true;
    });

    try {
      final defaultNotes = await _settingsApi.getDefaultPricingNotes();
      if (!mounted) return;

      _notesSaveTimer?.cancel();
      widget.onUpdateNotes!(defaultNotes);

      setState(() {
        _isRefreshingDefaultNotes = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الملاحظات من الإعدادات'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRefreshingDefaultNotes = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحديث الملاحظات: ${e.toString()}')),
      );
    }
  }

  PricingExportOptions get _exportOptions => PricingExportOptions(
    showDeductionBreakdown: _showDeductionBreakdownInPdf,
    showLineItemPrices: _showLineItemPricesInPdf,
  );

  Widget _buildPdfOptionCheckbox({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
    required bool isMobile,
  }) {
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

  String _formatNumberWithDecimals(double value) {
    if (!widget.showFinancials) return '••••';

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

  String _formatPlainNumber(double value) {
    return value.toStringAsFixed(3);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C212B),
            border: Border.all(color: const Color(0xFF363C4A)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildExpandedContent(
              isMobile: isMobile,
              isTablet: isTablet,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrandTotalCard({
    required bool isMobile,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(
        isMobile
            ? 4
            : isTablet
            ? 5
            : 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF15181E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF363C4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'التقدير الإجمالي',
            style: AppTextStyles.caption.copyWith(
              fontSize: isMobile ? 7 : 8,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 1),
                child: Text(
                  'KD',
                  style: AppTextStyles.h4.copyWith(
                    fontSize: isMobile ? 9 : 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 3 : 4),
              Builder(
                builder: (context) {
                  final full = _formatNumberWithDecimals(
                    widget.isAdminOrManager
                        ? widget.grandTotal
                        : widget.totalCost ?? 0,
                  );
                  final dotIndex = full.indexOf('.');
                  final intPart = dotIndex >= 0
                      ? full.substring(0, dotIndex)
                      : full;
                  final decimalPart = dotIndex >= 0
                      ? full.substring(dotIndex)
                      : '';
                  return RichText(
                    text: TextSpan(
                      text: intPart,
                      style: TextStyle(
                        fontSize: isMobile
                            ? 14
                            : isTablet
                            ? 16
                            : 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      children: decimalPart.isNotEmpty
                          ? [
                              TextSpan(
                                text: decimalPart,
                                style: TextStyle(
                                  fontSize: isMobile
                                      ? 9
                                      : isTablet
                                      ? 10
                                      : 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ]
                          : [],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStatsLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildGrandTotalCard(isMobile: true, isTablet: false),
            ),
            if (((widget.totalCost != null && widget.totalProfit != null) ||
                    widget.isApproved ||
                    widget.isProfitPending) &&
                widget.isAdminOrManager) ...[
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15181E),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF363C4A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'التكلفة',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 7,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_formatNumberWithDecimals(widget.totalCost ?? 0.0)} KD',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15181E),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF363C4A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'الربح',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 7,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_formatNumberWithDecimals(widget.totalProfit ?? 0.0)} KD',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        _buildDeductionSummaryRow(isMobile: true, isTablet: false),
      ],
    );
  }

  Widget _buildDeductionSummaryRow({
    required bool isMobile,
    required bool isTablet,
  }) {
    final totalAfter = (widget.originalTotalAmount - widget.deductionAmount);
    final safeTotalAfter = totalAfter < 0 ? 0.0 : totalAfter;
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
                Text('الخصم', style: textStyle),
                const SizedBox(height: 4),
                Text(
                  '${_formatNumberWithDecimals(widget.deductionAmount)} KD',
                  style: valueStyle.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الإجمالي بعد الخصم', style: textStyle),
                const SizedBox(height: 4),
                Text(
                  '${_formatNumberWithDecimals(safeTotalAfter)} KD',
                  style: valueStyle.copyWith(color: const Color(0xFF10B981)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExpandedContent({
    required bool isMobile,
    required bool isTablet,
  }) {
    return [
      // Header - compact
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 10,
          vertical: isMobile ? 3 : 4,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C212B), Color(0xFF232936)],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calculate,
              color: const Color(0xFF135BEC),
              size: isMobile ? 12 : 14,
            ),
            SizedBox(width: isMobile ? 3 : 4),
            Text(
              'ملخص التسعير',
              style: AppTextStyles.h4.copyWith(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      // Main Summary Stats - Responsive Layout - compact
      Container(
        padding: EdgeInsets.all(
          isMobile
              ? 4
              : isTablet
              ? 5
              : 6,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isSmallTablet = screenWidth >= 600 && screenWidth < 900;
            final isLargeTablet = screenWidth >= 900 && screenWidth < 1200;

            if (isMobile) {
              return _buildMobileStatsLayout();
            }

            // For tablets and desktops, use adaptive layout
            if (isSmallTablet) {
              // Use same layout as larger screens but more compact
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side: Grand Total
                      Expanded(
                        flex: 3,
                        child: _buildGrandTotalCard(
                          isMobile: false,
                          isTablet: true,
                        ),
                      ),
                      // Cost and Profit (if available) - stacked vertically
                      if (((widget.totalCost != null &&
                                  widget.totalProfit != null) ||
                              widget.isApproved ||
                              widget.isProfitPending) &&
                          widget.isAdminOrManager) ...[
                        SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isTablet ? 4 : 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF15181E),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF363C4A),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'التكلفة',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: isTablet ? 7 : 8,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${_formatNumberWithDecimals(widget.totalCost ?? 0.0)} KD',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontSize: isTablet ? 10 : 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isTablet ? 4 : 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF15181E),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF363C4A),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'الربح',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: isTablet ? 7 : 8,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${_formatNumberWithDecimals(widget.totalProfit ?? 0.0)} KD',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontSize: isTablet ? 10 : 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildDeductionSummaryRow(isMobile: false, isTablet: true),
                ],
              );
            }

            if (isLargeTablet) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      spacing: 6,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildGrandTotalCard(
                            isMobile: false,
                            isTablet: true,
                          ),
                        ),
                        if (((widget.totalCost != null &&
                                    widget.totalProfit != null) ||
                                widget.isApproved ||
                                widget.isProfitPending) &&
                            widget.isAdminOrManager) ...[
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isTablet ? 4 : 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF15181E),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFF363C4A),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'التكلفة',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: isTablet ? 7 : 8,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '${_formatNumberWithDecimals(widget.totalCost ?? 0.0)} KD',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontSize: isTablet ? 10 : 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isTablet ? 4 : 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF15181E),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFF363C4A),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'الربح',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: isTablet ? 7 : 8,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '${_formatNumberWithDecimals(widget.totalProfit ?? 0.0)} KD',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontSize: isTablet ? 10 : 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF10B981),
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
                  const SizedBox(height: 8),
                  _buildDeductionSummaryRow(isMobile: false, isTablet: true),
                ],
              );
            }

            // For larger screens: Grand Total on left, Cost and Profit stacked on right
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicHeight(
                  child: Row(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side: Grand Total
                      Expanded(
                        child: _buildGrandTotalCard(
                          isMobile: false,
                          isTablet: isTablet,
                        ),
                      ),
                      // Cost and Profit (if available) - stacked vertically
                      if (((widget.totalCost != null &&
                                  widget.totalProfit != null) ||
                              widget.isApproved ||
                              widget.isProfitPending) &&
                          widget.isAdminOrManager) ...[
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isTablet ? 4 : 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF15181E),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF363C4A),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'التكلفة',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: isTablet ? 7 : 8,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '${_formatNumberWithDecimals(widget.totalCost ?? 0.0)} KD',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontSize: isTablet ? 10 : 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isTablet ? 4 : 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF15181E),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF363C4A),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الربح',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: isTablet ? 7 : 8,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '${_formatNumberWithDecimals(widget.totalProfit ?? 0.0)} KD',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontSize: isTablet ? 10 : 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF10B981),
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
                const SizedBox(height: 8),
                _buildDeductionSummaryRow(isMobile: false, isTablet: false),
              ],
            );
          },
        ),
      ),
      // Bulk Profit Margin Control (only for admins/managers when APPROVED or PENDING_SIGNATURE)
      if (widget.isAdminOrManager &&
          (widget.isApproved || widget.isProfitPending) &&
          widget.onBulkProfitMarginUpdate != null)
        Container(
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bulkProfitController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      ArabicNumberInputFormatter(),
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: isMobile ? 11 : 12,
                    ),
                    decoration: InputDecoration(
                      hintText: 'هامش ربح موحد %',
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
                  ),
                ),
                SizedBox(width: isMobile ? 4 : 6),
                ElevatedButton(
                  onPressed: () {
                    final value = double.tryParse(_bulkProfitController.text);
                    if (value != null && value >= 0) {
                      widget.onBulkProfitMarginUpdate!(value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم تطبيق نسبة الربح $value% على جميع الفئات الفرعية',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 10 : 12,
                      vertical: isMobile ? 6 : 8,
                    ),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    'تطبيق',
                    style: AppTextStyles.buttonLarge.copyWith(
                      fontSize: isMobile ? 11 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      if (widget.isAdminOrManager &&
          widget.onDeductionAmountChanged != null &&
          widget.onDeductionAmountApplied != null)
        Container(
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
                _buildPdfOptionCheckbox(
                  value: _showLineItemPricesInPdf,
                  onChanged: (value) {
                    setState(() {
                      _showLineItemPricesInPdf = value;
                    });
                  },
                  label: 'إظهار سعر كل بند في PDF',
                  isMobile: isMobile,
                ),
                // SizedBox(height: isMobile ? 4 : 6),
                // _buildPdfOptionCheckbox(
                //   value: _showDeductionBreakdownInPdf,
                //   onChanged: (value) {
                //     setState(() {
                //       _showDeductionBreakdownInPdf = value;
                //     });
                //   },
                //   label: 'إظهار الخصم في PDF',
                //   isMobile: isMobile,
                // ),
                SizedBox(height: isMobile ? 4 : 6),
                TextField(
                  controller: _deductionController,
                  focusNode: _deductionFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    ArabicNumberInputFormatter(),
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,3}'),
                    ),
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
                  onChanged: (value) {
                    if (value.trim().isEmpty) {
                      widget.onDeductionAmountChanged!(0.0);
                      _deductionSaveTimer?.cancel();
                      if (widget.onDeductionAmountApplied != null) {
                        _deductionSaveTimer = Timer(
                          const Duration(milliseconds: 600),
                          () => widget.onDeductionAmountApplied!(0.0),
                        );
                      }
                      return;
                    }
                    final parsed = double.tryParse(value) ?? 0.0;
                    widget.onDeductionAmountChanged!(parsed);

                    if (widget.onDeductionAmountApplied != null) {
                      _deductionSaveTimer?.cancel();
                      _deductionSaveTimer = Timer(
                        const Duration(milliseconds: 600),
                        () => widget.onDeductionAmountApplied!(parsed),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      // Pricing Version Notes (only for admins/managers) - Collapsible
      if (widget.isAdminOrManager && widget.onUpdateNotes != null)
        Container(
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // Collapsible header
                InkWell(
                  onTap: () {
                    setState(() {
                      _isNotesExpanded = !_isNotesExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isNotesExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: isMobile ? 14 : 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'ملاحظات',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 10 : 11,
                            ),
                          ),
                          // Show note count badge when collapsed
                          if (!_isNotesExpanded &&
                              _noteControllers.any(
                                (c) => c.text.trim().isNotEmpty,
                              )) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_noteControllers.where((c) => c.text.trim().isNotEmpty).length}',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 9,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (_isNotesExpanded)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: 'تحديث من ملاحظات الإعدادات',
                              child: InkWell(
                                onTap: _isRefreshingDefaultNotes
                                    ? null
                                    : _refreshDefaultNotes,
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: _isRefreshingDefaultNotes
                                      ? SizedBox(
                                          width: isMobile ? 12 : 14,
                                          height: isMobile ? 12 : 14,
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                        )
                                      : Icon(
                                          Icons.refresh,
                                          size: isMobile ? 14 : 16,
                                          color: AppColors.primary,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Tooltip(
                              message: 'إضافة ملاحظة',
                              child: InkWell(
                                onTap: _addNoteItem,
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
                    ],
                  ),
                ),
                // Expandable content
                if (_isNotesExpanded) ...[
                  SizedBox(height: isMobile ? 4 : 6),
                  ...List.generate(
                    _noteControllers.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: isMobile ? 4 : 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bullet point
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
                          // Text field
                          Expanded(
                            child: TextField(
                              controller: _noteControllers[index],
                              focusNode: _noteFocusNodes[index],
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
                          // Remove button
                          if (_noteControllers.length > 1)
                            InkWell(
                              onTap: () => _removeNoteItem(index),
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
        ),
      // Action Buttons Section - compact
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile
              ? 4
              : isTablet
              ? 6
              : 8,
          vertical: isMobile ? 4 : 6,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isLargeScreen = screenWidth >= 1200;

            final buttonHeight = isMobile ? 30.0 : 28.0;
            final buttonFontSize = isMobile ? 10.0 : 10.0;
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

            // Collect all buttons
            final buttons = <Widget>[];

            // // Export PDF Button
            // if (widget.isAdminOrManager &&
            //     widget.isProfitPending &&
            //     widget.onExportPdf != null) {
            //   buttons.add(
            //     buildButton(
            //       onPressed: widget.onExportPdf,
            //       backgroundColor: const Color(0xFF6366F1),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Icon(Icons.picture_as_pdf, size: iconSize),
            //           SizedBox(width: isMobile ? 6 : 8),
            //           Text(
            //             'تصدير PDF',
            //             style: AppTextStyles.buttonLarge.copyWith(
            //               fontSize: buttonFontSize,
            //               fontWeight: FontWeight.w700,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   );
            // }

            // // Export Images Button
            // if (widget.isAdminOrManager &&
            //     widget.isProfitPending &&
            //     widget.onExportImages != null) {
            //   buttons.add(
            //     buildButton(
            //       onPressed: widget.onExportImages,
            //       backgroundColor: const Color(0xFF10B981),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Icon(Icons.image, size: iconSize),
            //           SizedBox(width: isMobile ? 6 : 8),
            //           Text(
            //             'تصدير كصورة',
            //             style: AppTextStyles.buttonLarge.copyWith(
            //               fontSize: buttonFontSize,
            //               fontWeight: FontWeight.w700,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   );
            // }

            // // Move to Pending Signature Button
            // if (widget.isAdminOrManager &&
            //     widget.isApproved &&
            //     widget.onMakeProfit != null) {
            //   buttons.add(
            //     buildButton(
            //       onPressed: widget.onMakeProfit,
            //       backgroundColor: const Color(0xFF6366F1),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Icon(Icons.description, size: iconSize),
            //           SizedBox(width: isMobile ? 6 : 8),
            //           Text(
            //             'إعداد العقد والتوقيع',
            //             style: AppTextStyles.buttonLarge.copyWith(
            //               fontSize: buttonFontSize,
            //               fontWeight: FontWeight.w700,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   );
            // }

            // Contract-specific buttons
            if (widget.isProfitPending) {
              // if (widget.onExportContractPdf != null &&
              //     widget.isAdminOrManager) {
              //   buttons.add(
              //     buildButton(
              //       onPressed: widget.onExportContractPdf,
              //       backgroundColor: const Color(0xFF6366F1),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Icon(Icons.picture_as_pdf, size: iconSize),
              //           SizedBox(width: isMobile ? 6 : 8),
              //           Text(
              //             'تصدير عقد PDF',
              //             style: AppTextStyles.buttonLarge.copyWith(
              //               fontSize: buttonFontSize,
              //               fontWeight: FontWeight.w700,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   );
              // }

              if (widget.onConfirmPricing != null && widget.isAdminOrManager) {
                buttons.add(
                  buildButton(
                    onPressed: widget.onConfirmPricing,
                    backgroundColor: const Color(0xFF10B981),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: iconSize),
                        SizedBox(width: isMobile ? 6 : 8),
                        Text(
                          'تأكيد وإنشاء العقد',
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

              if (widget.onExportPdf != null) {
                buttons.add(
                  buildButton(
                    onPressed: () => widget.onExportPdf!(_exportOptions),
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

              if (widget.onExportImages != null) {
                buttons.add(
                  buildButton(
                    onPressed: () => widget.onExportImages!(_exportOptions),
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

            // Submit Button
            if (!widget.showReturnToPricing &&
                !(widget.isAdminOrManager && widget.isApproved) &&
                !widget.isProfitPending) {
              buttons.add(
                buildButton(
                  onPressed: widget.onSubmit,
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

            // Return to Pricing Button
            if (widget.showReturnToPricing &&
                widget.onReturnToPricing != null &&
                widget.isAdminOrManager) {
              buttons.add(
                buildButton(
                  onPressed: widget.onReturnToPricing,
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

            // Arrange buttons responsively
            if (widget.onArchiveProject != null) {
              buttons.add(
                buildButton(
                  onPressed: widget.onArchiveProject,
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

            // Arrange buttons responsively
            if (isMobile) {
              // Stack vertically on mobile
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

            // For larger screens, arrange buttons in a grid
            // Use Wrap for better responsiveness
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, btnConstraints) {
                    final availableWidth = btnConstraints.maxWidth;
                    final buttonsPerRow = isLargeScreen ? 3 : 2;
                    final buttonWidth =
                        (availableWidth -
                            (buttonSpacing * (buttonsPerRow - 1))) /
                        buttonsPerRow;

                    return Wrap(
                      spacing: buttonSpacing,
                      runSpacing: buttonSpacing,
                      alignment: WrapAlignment.start,
                      children: buttons.map((btn) {
                        return SizedBox(width: buttonWidth, child: btn);
                      }).toList(),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    ];
  }
}
