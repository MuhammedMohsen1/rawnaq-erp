import '../../domain/enums/transaction_type.dart';

/// Helper functions for parsing
double _toDoubleOrZero(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

double? _toDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

int _toIntOrZero(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

String _toStringOrEmpty(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

String? _toStringOrNull(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

/// Transaction item model
class TransactionModel {
  final String id;
  final TransactionType type;
  final String description;
  final String? subDescription;
  final double amount;
  final DateTime date;
  final bool isEditable;
  final String source; // 'expense' or 'installment'
  final CostType? costType;
  final double? unitCost;
  final double? quantity;

  TransactionModel({
    required this.id,
    required this.type,
    required this.description,
    this.subDescription,
    required this.amount,
    required this.date,
    required this.isEditable,
    required this.source,
    this.costType,
    this.unitCost,
    this.quantity,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: _toStringOrEmpty(json['id']),
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      description: _toStringOrEmpty(json['description']),
      subDescription: _toStringOrNull(json['subDescription']),
      amount: _toDoubleOrZero(json['amount']),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isEditable: json['isEditable'] as bool? ?? false,
      source: _toStringOrEmpty(json['source']),
      costType: json['costType'] == 'UNIT_BASED' ? CostType.unitBased : CostType.total,
      unitCost: _toDoubleOrNull(json['unitCost']),
      quantity: _toDoubleOrNull(json['quantity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'description': description,
      'subDescription': subDescription,
      'amount': amount,
      'date': date.toIso8601String(),
      'isEditable': isEditable,
      'source': source,
      'costType': costType == CostType.unitBased ? 'UNIT_BASED' : 'TOTAL',
      'unitCost': unitCost,
      'quantity': quantity,
    };
  }
}

/// Payment phase model
class PaymentPhaseModel {
  final int index;
  final String phaseName;
  final double percentage;
  final double originalAmount;
  final double costAmount;
  final bool isRequested;
  final bool isApproved;
  final String? requestId;

  PaymentPhaseModel({
    required this.index,
    required this.phaseName,
    required this.percentage,
    required this.originalAmount,
    required this.costAmount,
    required this.isRequested,
    required this.isApproved,
    this.requestId,
  });

  factory PaymentPhaseModel.fromJson(Map<String, dynamic> json) {
    return PaymentPhaseModel(
      index: _toIntOrZero(json['index']),
      phaseName: _toStringOrEmpty(json['phaseName']),
      percentage: _toDoubleOrZero(json['percentage']),
      originalAmount: _toDoubleOrZero(json['originalAmount']),
      costAmount: _toDoubleOrZero(json['costAmount']),
      isRequested: json['isRequested'] as bool? ?? false,
      isApproved: json['isApproved'] as bool? ?? false,
      requestId: _toStringOrNull(json['requestId']),
    );
  }
}

/// Installment request model
class InstallmentRequestModel {
  final String id;
  final int phaseIndex;
  final String phaseName;
  final double requestedAmount;
  final double originalAmount;
  final double profitPercentage;
  final InstallmentRequestStatus status;
  final String requestedByName;
  final DateTime createdAt;
  final String? approvedByName;
  final DateTime? approvedAt;
  final String? rejectedReason;

  InstallmentRequestModel({
    required this.id,
    required this.phaseIndex,
    required this.phaseName,
    required this.requestedAmount,
    required this.originalAmount,
    required this.profitPercentage,
    required this.status,
    required this.requestedByName,
    required this.createdAt,
    this.approvedByName,
    this.approvedAt,
    this.rejectedReason,
  });

  factory InstallmentRequestModel.fromJson(Map<String, dynamic> json) {
    InstallmentRequestStatus parseStatus(String? status) {
      if (status == null) return InstallmentRequestStatus.pending;
      switch (status.toUpperCase()) {
        case 'APPROVED':
          return InstallmentRequestStatus.approved;
        case 'REJECTED':
          return InstallmentRequestStatus.rejected;
        default:
          return InstallmentRequestStatus.pending;
      }
    }

    return InstallmentRequestModel(
      id: _toStringOrEmpty(json['id']),
      phaseIndex: _toIntOrZero(json['phaseIndex']),
      phaseName: _toStringOrEmpty(json['phaseName']),
      requestedAmount: _toDoubleOrZero(json['requestedAmount']),
      originalAmount: _toDoubleOrZero(json['originalAmount']),
      profitPercentage: _toDoubleOrZero(json['profitPercentage']),
      status: parseStatus(json['status'] as String?),
      requestedByName: _toStringOrEmpty(json['requestedByName']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      approvedByName: _toStringOrNull(json['approvedByName']),
      approvedAt: json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'].toString())
          : null,
      rejectedReason: _toStringOrNull(json['rejectedReason']),
    );
  }
}

/// Execution dashboard model
class ExecutionDashboardModel {
  final String projectId;
  final String projectName;
  final double totalReceived;
  final double totalExpenses;
  final double netCashFlow;
  final double totalBudget;
  final double remainingBudget;
  final double budgetPercentage;
  final BudgetWarningLevel budgetWarningLevel;
  final double profitPercentage;
  final List<TransactionModel> transactions;
  final List<PaymentPhaseModel> paymentSchedule;
  final List<InstallmentRequestModel> pendingInstallmentRequests;
  final bool hasMoreTransactions;
  final int totalTransactionsCount;

  ExecutionDashboardModel({
    required this.projectId,
    required this.projectName,
    required this.totalReceived,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.totalBudget,
    required this.remainingBudget,
    required this.budgetPercentage,
    required this.budgetWarningLevel,
    required this.profitPercentage,
    required this.transactions,
    required this.paymentSchedule,
    required this.pendingInstallmentRequests,
    required this.hasMoreTransactions,
    required this.totalTransactionsCount,
  });

  factory ExecutionDashboardModel.fromJson(Map<String, dynamic> json) {
    BudgetWarningLevel parseWarningLevel(String? level) {
      if (level == null) return BudgetWarningLevel.normal;
      switch (level) {
        case 'warning':
          return BudgetWarningLevel.warning;
        case 'danger':
          return BudgetWarningLevel.danger;
        case 'exceeded':
          return BudgetWarningLevel.exceeded;
        default:
          return BudgetWarningLevel.normal;
      }
    }

    return ExecutionDashboardModel(
      projectId: _toStringOrEmpty(json['projectId']),
      projectName: _toStringOrEmpty(json['projectName']),
      totalReceived: _toDoubleOrZero(json['totalReceived']),
      totalExpenses: _toDoubleOrZero(json['totalExpenses']),
      netCashFlow: _toDoubleOrZero(json['netCashFlow']),
      totalBudget: _toDoubleOrZero(json['totalBudget']),
      remainingBudget: _toDoubleOrZero(json['remainingBudget']),
      budgetPercentage: _toDoubleOrZero(json['budgetPercentage']),
      budgetWarningLevel: parseWarningLevel(json['budgetWarningLevel'] as String?),
      profitPercentage: _toDoubleOrZero(json['profitPercentage']),
      transactions: (json['transactions'] as List?)
              ?.map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      paymentSchedule: (json['paymentSchedule'] as List?)
              ?.map((p) => PaymentPhaseModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      pendingInstallmentRequests: (json['pendingInstallmentRequests'] as List?)
              ?.map((r) => InstallmentRequestModel.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      hasMoreTransactions: json['hasMoreTransactions'] as bool? ?? false,
      totalTransactionsCount: _toIntOrZero(json['totalTransactionsCount']),
    );
  }

  ExecutionDashboardModel copyWith({
    String? projectId,
    String? projectName,
    double? totalReceived,
    double? totalExpenses,
    double? netCashFlow,
    double? totalBudget,
    double? remainingBudget,
    double? budgetPercentage,
    BudgetWarningLevel? budgetWarningLevel,
    double? profitPercentage,
    List<TransactionModel>? transactions,
    List<PaymentPhaseModel>? paymentSchedule,
    List<InstallmentRequestModel>? pendingInstallmentRequests,
    bool? hasMoreTransactions,
    int? totalTransactionsCount,
  }) {
    return ExecutionDashboardModel(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      totalReceived: totalReceived ?? this.totalReceived,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      netCashFlow: netCashFlow ?? this.netCashFlow,
      totalBudget: totalBudget ?? this.totalBudget,
      remainingBudget: remainingBudget ?? this.remainingBudget,
      budgetPercentage: budgetPercentage ?? this.budgetPercentage,
      budgetWarningLevel: budgetWarningLevel ?? this.budgetWarningLevel,
      profitPercentage: profitPercentage ?? this.profitPercentage,
      transactions: transactions ?? this.transactions,
      paymentSchedule: paymentSchedule ?? this.paymentSchedule,
      pendingInstallmentRequests: pendingInstallmentRequests ?? this.pendingInstallmentRequests,
      hasMoreTransactions: hasMoreTransactions ?? this.hasMoreTransactions,
      totalTransactionsCount: totalTransactionsCount ?? this.totalTransactionsCount,
    );
  }
}

/// Create expense DTO
class CreateExpenseDto {
  final String name;
  final String? description;
  final String type; // 'DAILY' or 'TOTAL_COST'
  final String costType; // 'TOTAL' or 'UNIT_BASED'
  final double? amount;
  final double? unitCost;
  final double? quantity;
  final DateTime date;
  final String? pricingItemId;

  CreateExpenseDto({
    required this.name,
    this.description,
    required this.type,
    required this.costType,
    this.amount,
    this.unitCost,
    this.quantity,
    required this.date,
    this.pricingItemId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'type': type,
      'costType': costType,
      if (amount != null) 'amount': amount,
      if (unitCost != null) 'unitCost': unitCost,
      if (quantity != null) 'quantity': quantity,
      'date': date.toIso8601String(),
      if (pricingItemId != null) 'pricingItemId': pricingItemId,
    };
  }
}

/// Update expense DTO
class UpdateExpenseDto {
  final String? name;
  final String? description;
  final String? type;
  final String? costType;
  final double? amount;
  final double? unitCost;
  final double? quantity;
  final DateTime? date;
  final String? pricingItemId;

  UpdateExpenseDto({
    this.name,
    this.description,
    this.type,
    this.costType,
    this.amount,
    this.unitCost,
    this.quantity,
    this.date,
    this.pricingItemId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (type != null) map['type'] = type;
    if (costType != null) map['costType'] = costType;
    if (amount != null) map['amount'] = amount;
    if (unitCost != null) map['unitCost'] = unitCost;
    if (quantity != null) map['quantity'] = quantity;
    if (date != null) map['date'] = date!.toIso8601String();
    if (pricingItemId != null) map['pricingItemId'] = pricingItemId;
    return map;
  }
}

/// Create income DTO (for Admin/Manager direct income addition)
class CreateIncomeDto {
  final String description;
  final double amount;
  final DateTime date;

  CreateIncomeDto({
    required this.description,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
