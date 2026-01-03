import 'package:equatable/equatable.dart';

/// Type of transaction
enum TransactionType {
  /// Money received (deposit, payment)
  deposit,
  
  /// Money spent (expense)
  expense,
}

/// Extension methods for TransactionType
extension TransactionTypeExtension on TransactionType {
  /// Get the Arabic display name
  String get arabicName {
    switch (this) {
      case TransactionType.deposit:
        return 'إيداع';
      case TransactionType.expense:
        return 'مصروف';
    }
  }

  /// Get the English display name
  String get englishName {
    switch (this) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.expense:
        return 'Expense';
    }
  }
}

/// Metadata for transactions
class TransactionMetadata extends Equatable {
  final String? supplier;
  final String? transferId;
  final String? notes;
  final String? category;
  final bool isLocked; // If true, transaction cannot be deleted

  const TransactionMetadata({
    this.supplier,
    this.transferId,
    this.notes,
    this.category,
    this.isLocked = false,
  });

  @override
  List<Object?> get props => [
        supplier,
        transferId,
        notes,
        category,
        isLocked,
      ];

  TransactionMetadata copyWith({
    String? supplier,
    String? transferId,
    String? notes,
    String? category,
    bool? isLocked,
  }) {
    return TransactionMetadata(
      supplier: supplier ?? this.supplier,
      transferId: transferId ?? this.transferId,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

/// Represents a financial transaction (expense or deposit)
class TransactionEntity extends Equatable {
  final String id;
  final TransactionType type;
  final String description;
  final double amount;
  final DateTime date;
  final String projectId;
  final TransactionMetadata metadata;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    required this.projectId,
    this.metadata = const TransactionMetadata(),
  });

  @override
  List<Object?> get props => [
        id,
        type,
        description,
        amount,
        date,
        projectId,
        metadata,
      ];

  /// Create a copy with updated fields
  TransactionEntity copyWith({
    String? id,
    TransactionType? type,
    String? description,
    double? amount,
    DateTime? date,
    String? projectId,
    TransactionMetadata? metadata,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      projectId: projectId ?? this.projectId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if transaction can be deleted
  bool get canDelete => !metadata.isLocked;
}

