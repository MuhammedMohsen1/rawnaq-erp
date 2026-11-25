import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/financial_summary_model.dart';
import 'financial_formatters.dart';
import 'package:rawnaq/core/utils/arabic_number_transformer.dart';

class FinancialKpiGrid extends StatelessWidget {
  final FinancialTotalsModel totals;

  const FinancialKpiGrid({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiCardData(
        title: 'قيمة العقود',
        value: formatKwd(totals.totalContractValue),
        icon: Icons.receipt_long_outlined,
        color: AppColors.of(context).info,
      ),
      _KpiCardData(
        title: 'التكلفة المتوقعة',
        value: formatKwd(totals.totalCost),
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.of(context).warning,
      ),
      _KpiCardData(
        title: 'المحصل',
        value: formatKwd(totals.totalReceived),
        icon: Icons.trending_up,
        color: AppColors.of(context).success,
      ),
      _KpiCardData(
        title: 'المصروفات',
        value: formatKwd(totals.totalExpenses),
        icon: Icons.trending_down,
        color: AppColors.of(context).error,
      ),
      _KpiCardData(
        title: 'صافي التدفق النقدي',
        value: formatKwd(totals.netCashFlow),
        icon: Icons.payments_outlined,
        color: totals.netCashFlow >= 0
            ? AppColors.of(context).success
            : AppColors.of(context).error,
      ),
      _KpiCardData(
        title: 'الربح المتوقع',
        value: formatKwd(totals.expectedProfit),
        icon: Icons.show_chart,
        color: AppColors.of(context).secondary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width < 620
            ? 1
            : width < 980
            ? 2
            : 3;
        final spacing = width < 620 ? 12.0 : 16.0;
        final itemWidth = (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards)
              SizedBox(
                width: itemWidth,
                child: _FinancialKpiCard(data: card),
              ),
          ],
        );
      },
    );
  }
}

class _FinancialKpiCard extends StatelessWidget {
  final _KpiCardData data;

  const _FinancialKpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.of(context).cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ArabicNumberTransformer.transform(data.title),
                  style: AppTextStyles.of(context).statLabel,
                ),
                const SizedBox(height: 6),
                Text(
                  ArabicNumberTransformer.transform(data.value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(context).h5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}
