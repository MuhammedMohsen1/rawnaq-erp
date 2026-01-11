import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/arabic_number_input_formatter.dart';

class PricingSummarySidebar extends StatefulWidget {
  final double grandTotal;
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
  final VoidCallback? onExportPdf;
  final VoidCallback? onExportImages;
  final VoidCallback? onExportContractPdf;
  final VoidCallback? onConfirmContract;
  final VoidCallback? onReturnContractToPricing;
  final bool showReturnToPricing;
  final bool isAdminOrManager;
  final bool isPendingApproval;
  final bool isApproved;
  final bool isProfitPending;
  final bool isDraft;
  final bool isUnderPricing;
  final String? pricingVersionNotes;
  final Function(String)? onUpdateNotes;
  final Function(double)? onBulkProfitMarginUpdate;

  const PricingSummarySidebar({
    super.key,
    required this.grandTotal,
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
    this.showReturnToPricing = false,
    this.isAdminOrManager = false,
    this.isPendingApproval = false,
    this.isApproved = false,
    this.isProfitPending = false,
    this.pricingVersionNotes,
    this.onUpdateNotes,
    this.onBulkProfitMarginUpdate,
    required this.isDraft,
    required this.isUnderPricing,
  });

  @override
  State<PricingSummarySidebar> createState() => _PricingSummarySidebarState();
}

class _PricingSummarySidebarState extends State<PricingSummarySidebar> {
  List<TextEditingController> _noteControllers = [];
  Timer? _notesSaveTimer;
  final TextEditingController _bulkProfitController = TextEditingController();
  bool _isNotesExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeNoteControllers();
  }

  void _initializeNoteControllers() {
    // Dispose existing controllers
    for (var controller in _noteControllers) {
      controller.dispose();
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

    // Add listeners to all controllers
    for (var controller in _noteControllers) {
      controller.addListener(_onNoteItemChanged);
    }
  }

  @override
  void didUpdateWidget(PricingSummarySidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pricingVersionNotes != oldWidget.pricingVersionNotes) {
      _initializeNoteControllers();
    }
  }

  @override
  void dispose() {
    _notesSaveTimer?.cancel();
    _bulkProfitController.dispose();
    for (var controller in _noteControllers) {
      controller.removeListener(_onNoteItemChanged);
      controller.dispose();
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
    });
  }

  void _removeNoteItem(int index) {
    if (_noteControllers.length > 1) {
      setState(() {
        _noteControllers[index].removeListener(_onNoteItemChanged);
        _noteControllers[index].dispose();
        _noteControllers.removeAt(index);
        _saveNotes();
      });
    }
  }

  String _formatNumberWithDecimals(double value) {
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        return Container(
          width: double.infinity,
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
      padding: EdgeInsets.all(isMobile ? 4 : isTablet ? 5 : 6),
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
                  final full = _formatNumberWithDecimals(widget.grandTotal);
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
                        fontSize: isMobile ? 14 : isTablet ? 16 : 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      children: decimalPart.isNotEmpty
                          ? [
                              TextSpan(
                                text: decimalPart,
                                style: TextStyle(
                                  fontSize: isMobile ? 9 : isTablet ? 10 : 11,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grand Total
        Expanded(
          flex: 3,
          child: _buildGrandTotalCard(isMobile: true, isTablet: false),
        ),
        // Cost and Profit (if available) - stacked vertically
        if ((widget.totalCost != null && widget.totalProfit != null) ||
            widget.isApproved ||
            widget.isProfitPending) ...[
          const SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cost
                Container(
                  width: double.infinity,
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
                const SizedBox(height: 2),
                // Profit
                Container(
                  width: double.infinity,
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
              ],
            ),
          ),
        ],
      ],
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
          isMobile ? 4 : isTablet ? 5 : 6,
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
              return Row(
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
                  if ((widget.totalCost != null &&
                          widget.totalProfit != null) ||
                      widget.isApproved ||
                      widget.isProfitPending) ...[
                    SizedBox(width: 4),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Cost
                          Container(
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
                          SizedBox(height: 2),
                          // Profit
                          Container(
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
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }

            // For larger screens: Grand Total on left, Cost and Profit stacked on right
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Grand Total
                Expanded(
                  flex: isLargeTablet ? 2 : 3,
                  child: _buildGrandTotalCard(
                    isMobile: false,
                    isTablet: isTablet,
                  ),
                ),
                // Cost and Profit (if available) - stacked vertically
                if ((widget.totalCost != null && widget.totalProfit != null) ||
                    widget.isApproved ||
                    widget.isProfitPending) ...[
                  SizedBox(width: isTablet ? 4 : 6),
                  Expanded(
                    flex: isLargeTablet ? 1 : 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Cost
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isTablet ? 4 : 5),
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
                        SizedBox(height: 2),
                        // Profit
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isTablet ? 4 : 5),
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
                      ],
                    ),
                  ),
                ],
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
                            _isNotesExpanded ? Icons.expand_less : Icons.expand_more,
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
                          if (!_isNotesExpanded && _noteControllers.any((c) => c.text.trim().isNotEmpty)) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                        InkWell(
                          onTap: _addNoteItem,
                          borderRadius: BorderRadius.circular(4),
                          child: Icon(
                            Icons.add_circle_outline,
                            size: isMobile ? 14 : 16,
                            color: AppColors.primary,
                          ),
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
          horizontal: isMobile ? 4 : isTablet ? 6 : 8,
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

            // Accept Pricing Button
            if (widget.isAdminOrManager &&
                widget.isPendingApproval &&
                widget.onAcceptPricing != null) {
              buttons.add(
                buildButton(
                  onPressed: widget.onAcceptPricing,
                  backgroundColor: const Color(0xFF10B981),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: iconSize),
                      SizedBox(width: isMobile ? 6 : 8),
                      Text(
                        'قبول التسعير',
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

            // Collect all buttons
            // Export PDF Button
            if (widget.isAdminOrManager &&
                widget.isApproved &&
                widget.onExportPdf != null) {
              buttons.add(
                buildButton(
                  onPressed: widget.onExportPdf,
                  backgroundColor: const Color(0xFF6366F1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, size: iconSize),
                      SizedBox(width: isMobile ? 6 : 8),
                      Text(
                        'تصدير PDF',
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

            // Export Images Button
            if (widget.isAdminOrManager &&
                widget.isApproved &&
                widget.onExportImages != null) {
              buttons.add(
                buildButton(
                  onPressed: widget.onExportImages,
                  backgroundColor: const Color(0xFF10B981),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: iconSize),
                      SizedBox(width: isMobile ? 6 : 8),
                      Text(
                        'تصدير كصورة',
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

            // Move to Pending Signature Button
            if (widget.isAdminOrManager &&
                widget.isApproved &&
                widget.onMakeProfit != null) {
              buttons.add(
                buildButton(
                  onPressed: widget.onMakeProfit,
                  backgroundColor: const Color(0xFF6366F1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, size: iconSize),
                      SizedBox(width: isMobile ? 6 : 8),
                      Text(
                        'إعداد العقد والتوقيع',
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

            // Contract-specific buttons
            if (widget.isProfitPending) {
              if (widget.onExportContractPdf != null) {
                buttons.add(
                  buildButton(
                    onPressed: widget.onExportContractPdf,
                    backgroundColor: const Color(0xFF6366F1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, size: iconSize),
                        SizedBox(width: isMobile ? 6 : 8),
                        Text(
                          'تصدير عقد PDF',
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

              if (widget.onConfirmContract != null) {
                buttons.add(
                  buildButton(
                    onPressed: widget.onConfirmContract,
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

              if (widget.onReturnContractToPricing != null) {
                buttons.add(
                  buildButton(
                    onPressed: widget.onReturnContractToPricing,
                    backgroundColor: Colors.orange,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: iconSize),
                        SizedBox(width: isMobile ? 6 : 8),
                        Text(
                          'إرجاع للتسعير',
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

              if (widget.onConfirmPricing != null) {
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
                    onPressed: widget.onExportPdf,
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
                    onPressed: widget.onExportImages,
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
                !(widget.isAdminOrManager && widget.isPendingApproval) &&
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
                        'إرسال التسعير للمراجعة',
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
                !(widget.isAdminOrManager && widget.isPendingApproval)) {
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

            // Save Draft Button
            if (widget.onSaveDraft != null &&
                !(widget.isApproved ||
                    widget.isProfitPending ||
                    widget.isDraft)) {
              buttons.add(
                buildButton(
                  onPressed: widget.onSaveDraft,
                  backgroundColor: const Color(0xFFD1D5DB),
                  isOutlined: true,
                  borderColor: const Color(0xFF363C4A),
                  height: buttonHeight - 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, size: iconSize),
                      SizedBox(width: isMobile ? 6 : 8),
                      Text(
                        'حفظ كمسودة',
                        style: AppTextStyles.buttonLarge.copyWith(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD1D5DB),
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
