import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

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
  final bool showReturnToPricing;
  final bool isAdminOrManager;
  final bool isPendingApproval;
  final bool isApproved;
  final bool isProfitPending;

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
    this.showReturnToPricing = false,
    this.isAdminOrManager = false,
    this.isPendingApproval = false,
    this.isApproved = false,
    this.isProfitPending = false,
  });

  @override
  State<PricingSummarySidebar> createState() => _PricingSummarySidebarState();
}

class _PricingSummarySidebarState extends State<PricingSummarySidebar> {
  bool _isCollapsed = false;

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
        final maxHeight = constraints.maxHeight != double.infinity
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _isCollapsed ? 60 : 320,
          constraints: BoxConstraints(minHeight: 0, maxHeight: maxHeight),
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _isCollapsed
                ? SizedBox(
                    key: const ValueKey('collapsed'),
                    width: 60,
                    height: maxHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _buildCollapsedContent(),
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('expanded'),
                    width: 320,
                    height: maxHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildExpandedContent(),
                    ),
                  ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCollapsedContent() {
    return [
      // Header
      Container(
        height: 69,
        padding: const EdgeInsets.all(20),
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
        child: const Icon(Icons.calculate, color: Color(0xFF135BEC), size: 24),
      ),
      // Toggle button at bottom
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isCollapsed = !_isCollapsed;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.8),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.5),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                        key: ValueKey<bool>(_isCollapsed),
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildExpandedContent() {
    return [
      // Header
      Container(
        height: 69,
        padding: const EdgeInsets.all(20),
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
            const Icon(Icons.calculate, color: Color(0xFF135BEC), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'ملخص التسعير',
                style: AppTextStyles.h4.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      // Content
      Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grand Total Estimate Label
                Text(
                  'التقدير الإجمالي',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 4),
                // Grand Total Amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'KD',
                        style: AppTextStyles.h4.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    Builder(
                      builder: (context) {
                        final full = _formatNumberWithDecimals(
                          widget.grandTotal,
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
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.75,
                            ),
                            children: decimalPart.isNotEmpty
                                ? [
                                    TextSpan(
                                      text: decimalPart,
                                      style: const TextStyle(
                                        fontSize:
                                            18, // smaller font for decimals
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.4,
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
                const SizedBox(height: 16),
                // Cost, Profit, Total Breakdown (show when profit is calculated or status is APPROVED/PROFIT_PENDING)
                if ((widget.totalCost != null && widget.totalProfit != null) ||
                    widget.isApproved ||
                    widget.isProfitPending) ...[
                  // Total Cost
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15181E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF363C4A)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التكلفة الإجمالية',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${_formatNumberWithDecimals(widget.totalCost ?? 0.0)} KD',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Total Profit
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15181E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF363C4A)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الربح الإجمالي',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${_formatNumberWithDecimals(widget.totalProfit ?? 0.0)} KD',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Total Elements Count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15181E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF363C4A)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.layers_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'إجمالي العناصر: ',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${widget.totalElements}',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Note
                Text(
                  widget.totalCost != null && widget.totalProfit != null
                      ? 'تم حساب الربح بناءً على النسب المحددة لكل عنصر فرعي.'
                      : 'محسوب بناءً على الإدخالات الحالية. قد يختلف السعر النهائي بعد المراجعة.',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 16),
                // Last Save Time
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  decoration: const BoxDecoration(
                    color: Color(0xFF15181E),
                    border: Border(top: BorderSide(color: Color(0xFF363C4A))),
                  ),
                  child: Center(
                    child: Text(
                      widget.lastSaveTime != null
                          ? 'آخر حفظ: ${widget.lastSaveTime}'
                          : 'آخر حفظ: الآن',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Accept Pricing Button (only show for Admin/Manager when status is PENDING_APPROVAL)
                if (widget.isAdminOrManager &&
                    widget.isPendingApproval &&
                    widget.onAcceptPricing != null) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: widget.onAcceptPricing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        shadowColor: const Color(0xFF059669).withOpacity(0.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'قبول التسعير',
                            style: AppTextStyles.buttonLarge.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Export PDF and Return to Pricing Buttons (only show for Admin/Manager when status is APPROVED)
                if (widget.isAdminOrManager &&
                    widget.isApproved &&
                    widget.onExportPdf != null) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: widget.onExportPdf,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        shadowColor: const Color(0xFF4F46E5).withOpacity(0.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.picture_as_pdf, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'تصدير PDF',
                            style: AppTextStyles.buttonLarge.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.onReturnToPricing != null)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: widget.onReturnToPricing,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'إرجاع للتسعير',
                              style: AppTextStyles.buttonLarge.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
                // Confirm and Return to Pricing Buttons (only show for PROFIT_PENDING status)
                if (widget.isProfitPending) ...[
                  if (widget.onConfirmPricing != null)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: widget.onConfirmPricing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          shadowColor: const Color(0xFF059669).withOpacity(0.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'تأكيد وإنشاء العقد',
                              style: AppTextStyles.buttonLarge.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (widget.onExportPdf != null)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: widget.onExportPdf,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                          side: const BorderSide(color: Color(0xFF6366F1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.picture_as_pdf, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'تصدير PDF',
                              style: AppTextStyles.buttonLarge.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (widget.onReturnToPricing != null)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: widget.onReturnToPricing,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'إرجاع للتسعير',
                              style: AppTextStyles.buttonLarge.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
                // Submit Button (only show when NOT pending approval, NOT approved, NOT profit pending, and NOT Admin/Manager with pending approval)
                if (!widget.showReturnToPricing &&
                    !(widget.isAdminOrManager && widget.isPendingApproval) &&
                    !(widget.isAdminOrManager && widget.isApproved) &&
                    !widget.isProfitPending) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: widget.onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF135BEC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        shadowColor: const Color(0xFF1E3A8A).withOpacity(0.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'إرسال التسعير للمراجعة',
                            style: AppTextStyles.buttonLarge.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Return to Pricing Button (only show when status is PENDING_APPROVAL and NOT Admin/Manager)
                if (widget.showReturnToPricing &&
                    widget.onReturnToPricing != null &&
                    !(widget.isAdminOrManager && widget.isPendingApproval)) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: widget.onReturnToPricing,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_back, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'إرجاع للتسعير',
                            style: AppTextStyles.buttonLarge.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Save Draft Button (show for all statuses including PENDING_APPROVAL and PROFIT_PENDING)
                if (widget.onSaveDraft != null)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: widget.onSaveDraft,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD1D5DB),
                        side: const BorderSide(color: Color(0xFF363C4A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_outlined, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'حفظ كمسودة',
                            style: AppTextStyles.buttonLarge.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFD1D5DB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                // Tip Section
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.2),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF60A5FA),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'نصيحة: راجع جميع الإدخالات قبل الإرسال. يمكنك الحفظ كمسودة والمتابعة لاحقاً.',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFBFDBFE).withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Toggle button at bottom
      Container(
        padding: const EdgeInsets.all(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _isCollapsed = !_isCollapsed;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border.all(color: AppColors.border, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Icon(
                      _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                      key: ValueKey<bool>(_isCollapsed),
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }
}
