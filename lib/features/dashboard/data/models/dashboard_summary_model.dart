import 'package:equatable/equatable.dart';

double _double(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
int _int(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;

class DashboardProjectStats extends Equatable {
  final int total,
      design,
      execution,
      completed,
      draft,
      underPricing,
      pendingSignature;
  const DashboardProjectStats({
    required this.total,
    required this.design,
    required this.execution,
    required this.completed,
    required this.draft,
    required this.underPricing,
    required this.pendingSignature,
  });
  factory DashboardProjectStats.fromJson(Map<String, dynamic> json) =>
      DashboardProjectStats(
        total: _int(json['total']),
        design: _int(json['design']),
        execution: _int(json['execution']),
        completed: _int(json['completed']),
        draft: _int(json['draft']),
        underPricing: _int(json['underPricing']),
        pendingSignature: _int(json['pendingSignature']),
      );
  @override
  List<Object?> get props => [
    total,
    design,
    execution,
    completed,
    draft,
    underPricing,
    pendingSignature,
  ];
}

class DashboardFinancialStats extends Equatable {
  final double totalContractValue, totalReceived, totalExpenses, netCashFlow;
  const DashboardFinancialStats({
    required this.totalContractValue,
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
  });
  factory DashboardFinancialStats.fromJson(Map<String, dynamic> json) =>
      DashboardFinancialStats(
        totalContractValue: _double(json['totalContractValue']),
        totalReceived: _double(json['totalReceived']),
        totalExpenses: _double(json['totalExpenses']),
        netCashFlow: _double(json['netCashFlow']),
      );
  @override
  List<Object?> get props => [
    totalContractValue,
    totalReceived,
    totalExpenses,
    netCashFlow,
  ];
}

class DashboardCashFlowPoint extends Equatable {
  final String label;
  final double income, expenses, net;
  const DashboardCashFlowPoint({
    required this.label,
    required this.income,
    required this.expenses,
    required this.net,
  });
  factory DashboardCashFlowPoint.fromJson(Map<String, dynamic> json) =>
      DashboardCashFlowPoint(
        label: '${json['label']}',
        income: _double(json['income']),
        expenses: _double(json['expenses']),
        net: _double(json['net']),
      );
  @override
  List<Object?> get props => [label, income, expenses, net];
}

class DashboardUser extends Equatable {
  final String name, email, role, status;
  const DashboardUser({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });
  factory DashboardUser.fromJson(Map<String, dynamic> json) => DashboardUser(
    name: '${json['name']}',
    email: '${json['email']}',
    role: '${json['role']}',
    status: '${json['accountStatus']}',
  );
  @override
  List<Object?> get props => [name, email, role, status];
}

class DashboardActivity extends Equatable {
  final String type, title, description;
  final DateTime createdAt;
  const DashboardActivity({
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
  });
  factory DashboardActivity.fromJson(Map<String, dynamic> json) =>
      DashboardActivity(
        type: '${json['type']}',
        title: '${json['title']}',
        description: '${json['description']}',
        createdAt: DateTime.tryParse('${json['createdAt']}') ?? DateTime.now(),
      );
  @override
  List<Object?> get props => [type, title, description, createdAt];
}

class DashboardSummaryModel extends Equatable {
  final String period;
  final DashboardProjectStats projectStats;
  final DashboardFinancialStats financialStats;
  final List<DashboardCashFlowPoint> cashFlowSeries;
  final List<DashboardUser> recentUsers;
  final List<DashboardActivity> recentActivities;
  const DashboardSummaryModel({
    required this.period,
    required this.projectStats,
    required this.financialStats,
    required this.cashFlowSeries,
    required this.recentUsers,
    required this.recentActivities,
  });
  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) =>
      DashboardSummaryModel(
        period: '${json['period'] ?? 'YEAR'}',
        projectStats: DashboardProjectStats.fromJson(
          json['projectStats'] as Map<String, dynamic>? ?? {},
        ),
        financialStats: DashboardFinancialStats.fromJson(
          json['financialStats'] as Map<String, dynamic>? ?? {},
        ),
        cashFlowSeries: (json['cashFlowSeries'] as List? ?? [])
            .map(
              (e) => DashboardCashFlowPoint.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        recentUsers: (json['recentUsers'] as List? ?? [])
            .map((e) => DashboardUser.fromJson(e as Map<String, dynamic>))
            .toList(),
        recentActivities: (json['recentActivities'] as List? ?? [])
            .map((e) => DashboardActivity.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
  @override
  List<Object?> get props => [
    period,
    projectStats,
    financialStats,
    cashFlowSeries,
    recentUsers,
    recentActivities,
  ];
}
