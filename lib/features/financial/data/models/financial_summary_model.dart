import 'package:equatable/equatable.dart';

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class FinancialTotalsModel extends Equatable {
  final double totalContractValue;
  final double totalCost;
  final double totalReceived;
  final double totalExpenses;
  final double netCashFlow;
  final double expectedProfit;
  final double remainingBudget;
  final int projectCount;

  const FinancialTotalsModel({
    required this.totalContractValue,
    required this.totalCost,
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.expectedProfit,
    required this.remainingBudget,
    required this.projectCount,
  });

  factory FinancialTotalsModel.fromJson(Map<String, dynamic> json) {
    return FinancialTotalsModel(
      totalContractValue: _toDouble(json['totalContractValue']),
      totalCost: _toDouble(json['totalCost']),
      totalReceived: _toDouble(json['totalReceived']),
      totalExpenses: _toDouble(json['totalExpenses']),
      netCashFlow: _toDouble(json['netCashFlow']),
      expectedProfit: _toDouble(json['expectedProfit']),
      remainingBudget: _toDouble(json['remainingBudget']),
      projectCount: _toInt(json['projectCount']),
    );
  }

  @override
  List<Object?> get props => [
    totalContractValue,
    totalCost,
    totalReceived,
    totalExpenses,
    netCashFlow,
    expectedProfit,
    remainingBudget,
    projectCount,
  ];
}

class CompanyProfitModel extends Equatable {
  final int completedProjectCount;
  final double completedProjectContractValue;
  final double completedProjectCost;
  final double projectProfit;
  final double companyExpenses;
  final double netCompanyProfit;

  const CompanyProfitModel({
    required this.completedProjectCount,
    required this.completedProjectContractValue,
    required this.completedProjectCost,
    required this.projectProfit,
    required this.companyExpenses,
    required this.netCompanyProfit,
  });

  factory CompanyProfitModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfitModel(
      completedProjectCount: _toInt(json['completedProjectCount']),
      completedProjectContractValue: _toDouble(
        json['completedProjectContractValue'],
      ),
      completedProjectCost: _toDouble(json['completedProjectCost']),
      projectProfit: _toDouble(json['projectProfit']),
      companyExpenses: _toDouble(json['companyExpenses']),
      netCompanyProfit: _toDouble(json['netCompanyProfit']),
    );
  }

  @override
  List<Object?> get props => [
    completedProjectCount,
    completedProjectContractValue,
    completedProjectCost,
    projectProfit,
    companyExpenses,
    netCompanyProfit,
  ];
}

class CompanyExpenseModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final double amount;
  final DateTime transactionDate;

  const CompanyExpenseModel({
    required this.id,
    required this.title,
    this.description,
    this.category,
    required this.amount,
    required this.transactionDate,
  });

  factory CompanyExpenseModel.fromJson(Map<String, dynamic> json) {
    return CompanyExpenseModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      amount: _toDouble(json['amount']),
      transactionDate:
          DateTime.tryParse(json['transactionDate']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    amount,
    transactionDate,
  ];
}

class FinancialProjectModel extends Equatable {
  final String projectId;
  final String projectName;
  final String status;
  final String? projectType;
  final String? clientName;
  final double totalContractValue;
  final double totalCost;
  final double totalReceived;
  final double totalExpenses;
  final double netCashFlow;
  final double remainingBudget;
  final double budgetUsagePercentage;

  const FinancialProjectModel({
    required this.projectId,
    required this.projectName,
    required this.status,
    this.projectType,
    this.clientName,
    required this.totalContractValue,
    required this.totalCost,
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.remainingBudget,
    required this.budgetUsagePercentage,
  });

  factory FinancialProjectModel.fromJson(Map<String, dynamic> json) {
    return FinancialProjectModel(
      projectId: json['projectId']?.toString() ?? '',
      projectName: json['projectName']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      projectType: (json['projectType'] ?? json['type'])?.toString(),
      clientName: json['clientName']?.toString(),
      totalContractValue: _toDouble(json['totalContractValue']),
      totalCost: _toDouble(json['totalCost']),
      totalReceived: _toDouble(json['totalReceived']),
      totalExpenses: _toDouble(json['totalExpenses']),
      netCashFlow: _toDouble(json['netCashFlow']),
      remainingBudget: _toDouble(json['remainingBudget']),
      budgetUsagePercentage: _toDouble(json['budgetUsagePercentage']),
    );
  }

  bool get isDesignProject => projectType?.toUpperCase() == 'DESIGN';

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    status,
    projectType,
    clientName,
    totalContractValue,
    totalCost,
    totalReceived,
    totalExpenses,
    netCashFlow,
    remainingBudget,
    budgetUsagePercentage,
  ];
}

class FinancialSummaryModel extends Equatable {
  final FinancialTotalsModel totals;
  final CompanyProfitModel companyProfit;
  final List<FinancialProjectModel> projects;

  const FinancialSummaryModel({
    required this.totals,
    required this.companyProfit,
    required this.projects,
  });

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    final projectsJson = json['projects'] as List? ?? [];
    return FinancialSummaryModel(
      totals: FinancialTotalsModel.fromJson(
        json['totals'] as Map<String, dynamic>? ?? const {},
      ),
      companyProfit: CompanyProfitModel.fromJson(
        json['companyProfit'] as Map<String, dynamic>? ?? const {},
      ),
      projects: projectsJson
          .map(
            (project) =>
                FinancialProjectModel.fromJson(project as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [totals, companyProfit, projects];
}
