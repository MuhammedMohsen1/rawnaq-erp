import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../data/models/dashboard_summary_model.dart';

final _kwd = NumberFormat.currency(
  locale: 'en',
  symbol: 'KD ',
  decimalDigits: 3,
);

class DashboardContent extends StatelessWidget {
  final DashboardSummaryModel summary;
  final ValueChanged<String> onPeriodChanged;
  final VoidCallback onUsersPressed, onFinancialPressed;
  const DashboardContent({
    super.key,
    required this.summary,
    required this.onPeriodChanged,
    required this.onUsersPressed,
    required this.onFinancialPressed,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProjectStats(stats: summary.projectStats),
        const SizedBox(height: 24),
        _FinancialSection(
          summary: summary,
          onPeriodChanged: onPeriodChanged,
          onPressed: onFinancialPressed,
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (_, c) => c.maxWidth < 900
              ? Column(
                  children: [
                    _RecentUsers(
                      users: summary.recentUsers,
                      onPressed: onUsersPressed,
                    ),
                    const SizedBox(height: 24),
                    _RecentActivities(activities: summary.recentActivities),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _RecentUsers(
                        users: summary.recentUsers,
                        onPressed: onUsersPressed,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: _RecentActivities(
                        activities: summary.recentActivities,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    ),
  );
}

class _ProjectStats extends StatelessWidget {
  final DashboardProjectStats stats;
  const _ProjectStats({required this.stats});
  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        'إجمالي المشاريع',
        stats.total,
        Icons.folder_copy,
        const Color(0xff3b82f6),
      ),
      (
        'مشاريع التصميم',
        stats.design,
        Icons.design_services,
        const Color(0xff06b6d4),
      ),
      (
        'مشاريع التنفيذ',
        stats.execution,
        Icons.engineering,
        const Color(0xfff59e0b),
      ),
      (
        'المشاريع المكتملة',
        stats.completed,
        Icons.check_circle,
        const Color(0xff22c55e),
      ),
    ];
    return Column(
      children: [
        LayoutBuilder(
          builder: (_, c) => Wrap(
            spacing: 16,
            runSpacing: 16,
            children: cards
                .map(
                  (item) => SizedBox(
                    width: c.maxWidth < 600
                        ? c.maxWidth
                        : (c.maxWidth - (c.maxWidth < 1000 ? 16 : 48)) /
                              (c.maxWidth < 1000 ? 2 : 4),
                    child: _MetricCard(
                      title: item.$1,
                      value: '${item.$2}',
                      icon: item.$3,
                      color: item.$4,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        _Panel(
          child: Wrap(
            spacing: 24,
            runSpacing: 8,
            children:
                [
                      ('مسودة', stats.draft),
                      ('قيد التسعير', stats.underPricing),
                      ('بانتظار التوقيع', stats.pendingSignature),
                    ]
                    .map(
                      (item) => Text(
                        '${item.$1}: ${item.$2}',
                        style: const TextStyle(color: Color(0xffc9d1d9)),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 16),
        Text(
          value,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        Text(title, style: const TextStyle(color: Color(0xff8b949e))),
      ],
    ),
  );
}

class _FinancialSection extends StatelessWidget {
  final DashboardSummaryModel summary;
  final ValueChanged<String> onPeriodChanged;
  final VoidCallback onPressed;
  const _FinancialSection({
    required this.summary,
    required this.onPeriodChanged,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    final f = summary.financialStats;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'نظرة عامة مالية',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: onPressed,
                child: const Text('التفاصيل المالية'),
              ),
            ],
          ),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children:
                [
                      ('قيمة العقود', f.totalContractValue),
                      ('المحصل', f.totalReceived),
                      ('المصروفات', f.totalExpenses),
                      ('صافي التدفق', f.netCashFlow),
                    ]
                    .map(
                      (item) => SizedBox(
                        width: 180,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$1,
                              style: const TextStyle(color: Color(0xff8b949e)),
                            ),
                            Text(
                              _kwd.format(item.$2),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [('WEEK', 'أسبوع'), ('MONTH', 'شهر'), ('YEAR', 'سنة')]
                .map(
                  (item) => ChoiceChip(
                    label: Text(item.$2),
                    selected: summary.period == item.$1,
                    onSelected: (_) => onPeriodChanged(item.$1),
                  ),
                )
                .toList(),
          ),
          SizedBox(
            height: 260,
            child: summary.cashFlowSeries.isEmpty
                ? const Center(child: Text('لا توجد حركة مالية خلال الفترة'))
                : SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      interval: summary.period == 'MONTH' ? 7 : 1,
                      intervalType: summary.period == 'YEAR'
                          ? DateTimeIntervalType.months
                          : DateTimeIntervalType.days,
                      dateFormat: summary.period == 'YEAR'
                          ? DateFormat('MMM yyyy')
                          : DateFormat('dd MMM'),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    trackballBehavior: TrackballBehavior(
                      enable: true,
                      activationMode: ActivationMode.singleTap,
                      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
                      markerSettings: const TrackballMarkerSettings(
                        markerVisibility: TrackballVisibilityMode.visible,
                      ),
                    ),
                    series: <CartesianSeries<DashboardCashFlowPoint, DateTime>>[
                      SplineAreaSeries(
                        dataSource: summary.cashFlowSeries,
                        xValueMapper: (p, _) => DateTime.parse(p.label),
                        yValueMapper: (p, _) => p.expenses,
                        name: 'المصروفات',
                        color: const Color(0xffef4444),
                        opacity: 0.22,
                        borderColor: const Color(0xffef4444),
                        borderWidth: 2,
                        splineType: SplineType.monotonic,
                        enableTooltip: true,
                      ),
                      SplineAreaSeries(
                        dataSource: summary.cashFlowSeries,
                        xValueMapper: (p, _) => DateTime.parse(p.label),
                        yValueMapper: (p, _) => p.income,
                        name: 'المحصل',
                        color: const Color(0xff22c55e),
                        opacity: 0.28,
                        borderColor: const Color(0xff22c55e),
                        borderWidth: 2,
                        splineType: SplineType.monotonic,
                        enableTooltip: true,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _RecentUsers extends StatelessWidget {
  final List<DashboardUser> users;
  final VoidCallback onPressed;
  const _RecentUsers({required this.users, required this.onPressed});
  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'المستخدمون الأخيرون',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(onPressed: onPressed, child: const Text('عرض الكل')),
          ],
        ),
        if (users.isEmpty)
          const Text('لا يوجد مستخدمون')
        else
          ...users.map(
            (u) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(u.name),
              subtitle: Text(u.email),
              trailing: Text(u.role),
            ),
          ),
      ],
    ),
  );
}

class _RecentActivities extends StatelessWidget {
  final List<DashboardActivity> activities;
  const _RecentActivities({required this.activities});
  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'النشاط الأخير',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (activities.isEmpty)
          const Text('لا يوجد نشاط حديث')
        else
          ...activities.map(
            (a) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, color: Color(0xff58a6ff)),
              title: Text(a.title),
              subtitle: Text(a.description),
            ),
          ),
      ],
    ),
  );
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xff161b22),
      border: Border.all(color: const Color(0xff30363d)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
}
