class ProjectFinancialTransactionModel {
  final String id, type, description;
  final double amount;
  final DateTime? date;
  final bool isUndated;
  const ProjectFinancialTransactionModel({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    required this.isUndated,
  });
  factory ProjectFinancialTransactionModel.fromJson(
    Map<String, dynamic> json,
  ) => ProjectFinancialTransactionModel(
    id: '${json['id']}',
    type: '${json['type']}',
    description: '${json['description']}',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    date: DateTime.tryParse('${json['date'] ?? ''}'),
    isUndated: json['isUndated'] as bool? ?? false,
  );
}

class ProjectFinancialOverviewModel {
  final String projectId, projectName, projectType, status;
  final String? clientName;
  final double totalContractValue,
      totalCost,
      expectedProfit,
      totalReceived,
      totalExpenses,
      netCashFlow,
      remainingBudget,
      budgetUsagePercentage;
  final List<ProjectFinancialTransactionModel> transactions;
  const ProjectFinancialOverviewModel({
    required this.projectId,
    required this.projectName,
    required this.projectType,
    required this.status,
    required this.clientName,
    required this.totalContractValue,
    required this.totalCost,
    required this.expectedProfit,
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.remainingBudget,
    required this.budgetUsagePercentage,
    required this.transactions,
  });
  factory ProjectFinancialOverviewModel.fromJson(Map<String, dynamic> json) =>
      ProjectFinancialOverviewModel(
        projectId: '${json['projectId']}',
        projectName: '${json['projectName']}',
        projectType: '${json['projectType']}',
        status: '${json['status']}',
        clientName: json['clientName']?.toString(),
        totalContractValue: _double(json['totalContractValue']),
        totalCost: _double(json['totalCost']),
        expectedProfit: _double(json['expectedProfit']),
        totalReceived: _double(json['totalReceived']),
        totalExpenses: _double(json['totalExpenses']),
        netCashFlow: _double(json['netCashFlow']),
        remainingBudget: _double(json['remainingBudget']),
        budgetUsagePercentage: _double(json['budgetUsagePercentage']),
        transactions: (json['transactions'] as List? ?? [])
            .map(
              (item) => ProjectFinancialTransactionModel.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),
      );
}

double _double(dynamic value) => value is num ? value.toDouble() : 0;
