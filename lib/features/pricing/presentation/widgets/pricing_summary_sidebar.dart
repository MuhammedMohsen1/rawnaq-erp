import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/arabic_number_input_formatter.dart';
import '../../../settings/data/datasources/settings_api_datasource.dart';
import 'pricing_summary_sidebar_support_widgets.dart';

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
  final bool showCostOnlySummary;

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
    this.showCostOnlySummary = false,
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
  String? _displayNotes;

  @override
  void initState() {
    super.initState();
    _syncDisplayedNotes();
    _deductionController.text = _formatPlainNumber(widget.deductionAmount);
  }

  @override
  void didUpdateWidget(covariant PricingSummarySidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pricingVersionNotes != oldWidget.pricingVersionNotes) {
      final isEditingNotes = _noteFocusNodes.any((node) => node.hasFocus);
      if (!isEditingNotes) {
        _syncDisplayedNotes();
      }
    }
    if (widget.deductionAmount != oldWidget.deductionAmount &&
        !_deductionFocusNode.hasFocus) {
      _deductionController.text = _formatPlainNumber(widget.deductionAmount);
    }
  }

  @override
  void dispose() {
    _notesSaveTimer?.cancel();
    _deductionSaveTimer?.cancel();
    _bulkProfitController.dispose();
    _deductionController.dispose();
    _deductionFocusNode.dispose();
    for (final controller in _noteControllers) {
      controller.removeListener(_onNoteItemChanged);
      controller.dispose();
    }
    for (final focusNode in _noteFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _syncDisplayedNotes() async {
    final pricingNotes = widget.pricingVersionNotes?.trim();
    if (pricingNotes != null && pricingNotes.isNotEmpty) {
      _displayNotes = pricingNotes;
      _initializeNoteControllers(pricingNotes);
      return;
    }

    try {
      final defaultNotes = await _settingsApi.getDefaultPricingNotes();
      if (!mounted) return;
      _displayNotes = defaultNotes.trim();
      _initializeNoteControllers(_displayNotes ?? '');
    } catch (_) {
      if (!mounted) return;
      _displayNotes = '';
      _initializeNoteControllers('');
    }
  }

  void _initializeNoteControllers(String notes) {
    for (final controller in _noteControllers) {
      controller.dispose();
    }
    for (final focusNode in _noteFocusNodes) {
      focusNode.dispose();
    }

    final noteItems = notes
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (noteItems.isEmpty) {
      noteItems.add('');
    }

    _noteControllers = noteItems
        .map((item) => TextEditingController(text: item))
        .toList();
    _noteFocusNodes = noteItems.map((_) => FocusNode()).toList();

    for (final controller in _noteControllers) {
      controller.addListener(_onNoteItemChanged);
    }
  }

  void _onNoteItemChanged() {
    _notesSaveTimer?.cancel();
    _notesSaveTimer = Timer(const Duration(milliseconds: 800), _saveNotes);
  }

  void _saveNotes() {
    if (widget.onUpdateNotes == null) return;
    final notes = _noteControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n');
    widget.onUpdateNotes!(notes);
  }

  void _addNoteItem() {
    setState(() {
      final controller = TextEditingController();
      controller.addListener(_onNoteItemChanged);
      _noteControllers.add(controller);
      _noteFocusNodes.add(FocusNode());
    });
  }

  void _removeNoteItem(int index) {
    if (_noteControllers.length <= 1) return;
    setState(() {
      _noteControllers[index].removeListener(_onNoteItemChanged);
      _noteControllers[index].dispose();
      _noteControllers.removeAt(index);
      _noteFocusNodes[index].dispose();
      _noteFocusNodes.removeAt(index);
      _saveNotes();
    });
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
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('فشل تحديث الملاحظات: ${e.toString()}'),
        ),
      );
    }
  }

  PricingExportOptions get _exportOptions => PricingExportOptions(
    showDeductionBreakdown: _showDeductionBreakdownInPdf,
    showLineItemPrices: _showLineItemPricesInPdf,
  );

  String _formatNumberWithDecimals(double value) {
    if (!widget.showFinancials) return '••••';
    final parts = value.toStringAsFixed(3).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];
    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$formattedInteger.$decimalPart';
  }

  String _formatPlainNumber(double value) => value.toStringAsFixed(3);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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

  List<Widget> _buildExpandedContent({
    required bool isMobile,
    required bool isTablet,
  }) {
    final primarySummaryLabel = widget.showCostOnlySummary
        ? 'التكلفة'
        : 'التقدير الإجمالي';
    final grandTotalValue =
        '${_formatNumberWithDecimals(widget.showCostOnlySummary ? (widget.totalCost ?? 0) : widget.grandTotal)} KD';
    final totalCostValue =
        '${_formatNumberWithDecimals(widget.totalCost ?? 0.0)} KD';
    final totalProfitValue =
        '${_formatNumberWithDecimals(widget.totalProfit ?? 0.0)} KD';
    final deductionValue =
        '${_formatNumberWithDecimals(widget.deductionAmount)} KD';
    final safeTotalAfter =
        (widget.originalTotalAmount - widget.deductionAmount) < 0
        ? 0.0
        : (widget.originalTotalAmount - widget.deductionAmount);
    final totalAfterValue = '${_formatNumberWithDecimals(safeTotalAfter)} KD';
    final showStats =
        ((widget.totalCost != null && widget.totalProfit != null) ||
            widget.isApproved ||
            widget.isProfitPending) &&
        widget.isAdminOrManager;

    return [
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
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.all(
          isMobile
              ? 4
              : isTablet
              ? 5
              : 6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: PricingSummaryMetricCard(
                      label: primarySummaryLabel,
                      valueLabel: grandTotalValue,
                      fontSize: 14,
                      compact: true,
                    ),
                  ),
                  if (!widget.showCostOnlySummary && showStats) ...[
                    const SizedBox(width: 4),
                    Expanded(
                      child: PricingSummaryMetricCard(
                        label: 'التكلفة',
                        valueLabel: totalCostValue,
                        fontSize: 10,
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: PricingSummaryMetricCard(
                        label: 'الربح',
                        valueLabel: totalProfitValue,
                        valueColor: const Color(0xFF10B981),
                        fontSize: 10,
                        compact: true,
                      ),
                    ),
                  ],
                ],
              )
            else
              IntrinsicHeight(
                child: Row(
                  spacing: isTablet ? 6 : 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: isTablet ? 3 : 1,
                      child: PricingSummaryMetricCard(
                        label: primarySummaryLabel,
                        valueLabel: grandTotalValue,
                        fontSize: isTablet ? 16 : 18,
                        compact: true,
                      ),
                    ),
                    if (!widget.showCostOnlySummary && showStats) ...[
                      Expanded(
                        child: PricingSummaryMetricCard(
                          label: 'التكلفة',
                          valueLabel: totalCostValue,
                          fontSize: isTablet ? 10 : 11,
                          compact: true,
                        ),
                      ),
                      Expanded(
                        child: PricingSummaryMetricCard(
                          label: 'الربح',
                          valueLabel: totalProfitValue,
                          valueColor: const Color(0xFF10B981),
                          fontSize: isTablet ? 10 : 11,
                          compact: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            if (!widget.showCostOnlySummary) ...[
              SizedBox(height: isMobile ? 6 : 8),
              PricingSummaryDeductionSummaryRow(
                deductionLabel: 'الخصم',
                deductionValueLabel: deductionValue,
                totalAfterLabel: 'الإجمالي بعد الخصم',
                totalAfterValueLabel: totalAfterValue,
                isMobile: isMobile,
                isTablet: isTablet,
              ),
            ],
          ],
        ),
      ),
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
                    style: TextStyle(fontSize: isMobile ? 11 : 12),
                    decoration: InputDecoration(
                      hintText: 'هامش ربح موحد %',
                      hintStyle: TextStyle(
                        color: Theme.of(context).hintColor,
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
                        borderSide: const BorderSide(color: Color(0xFF135BEC)),
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
                    style: TextStyle(
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
        PricingSummaryDeductionControl(
          isAdminOrManager: widget.isAdminOrManager,
          isMobile: isMobile,
          deductionController: _deductionController,
          deductionFocusNode: _deductionFocusNode,
          showLineItemPricesInPdf: _showLineItemPricesInPdf,
          onShowLineItemPricesChanged: (value) {
            setState(() {
              _showLineItemPricesInPdf = value;
            });
          },
          onDeductionChanged: (value) {
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
      if (widget.isAdminOrManager && widget.onUpdateNotes != null)
        PricingSummaryNotesEditor(
          isAdminOrManager: widget.isAdminOrManager,
          isMobile: isMobile,
          isNotesExpanded: _isNotesExpanded,
          isRefreshingDefaultNotes: _isRefreshingDefaultNotes,
          noteControllers: _noteControllers,
          noteFocusNodes: _noteFocusNodes,
          onAddNote: _addNoteItem,
          onRemoveNote: _removeNoteItem,
          onToggleExpanded: () {
            setState(() {
              _isNotesExpanded = !_isNotesExpanded;
            });
          },
          onRefreshDefaultNotes: _refreshDefaultNotes,
        ),
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile
              ? 4
              : isTablet
              ? 6
              : 8,
          vertical: isMobile ? 4 : 6,
        ),
        child: PricingSummaryExportActions(
          isMobile: isMobile,
          showReturnToPricing: widget.showReturnToPricing,
          isAdminOrManager: widget.isAdminOrManager,
          isApproved: widget.isApproved,
          isProfitPending: widget.isProfitPending,
          isUnderPricing: widget.isUnderPricing,
          isDraft: widget.isDraft,
          onSubmit: widget.onSubmit,
          onReturnToPricing: widget.onReturnToPricing,
          onArchiveProject: widget.onArchiveProject,
          onConfirmPricing: widget.onConfirmPricing,
          onExportPdf: widget.onExportPdf,
          onExportImages: widget.onExportImages,
          onExportContractPdf: widget.onExportContractPdf,
          onConfirmContract: widget.onConfirmContract,
          onReturnContractToPricing: widget.onReturnContractToPricing,
          exportOptions: _exportOptions,
        ),
      ),
    ];
  }
}
