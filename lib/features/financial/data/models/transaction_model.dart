import '../../domain/entities/transaction_entity.dart';

/// Model class for Transaction with JSON serialization
class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.description,
    required super.amount,
    required super.date,
    required super.projectId,
    super.metadata,
  });

  /// Create from JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: _parseTransactionType(json['type'] as String),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      projectId: json['projectId'] as String,
      metadata: json['metadata'] != null
          ? TransactionMetadata(
              supplier: json['metadata']['supplier'] as String?,
              transferId: json['metadata']['transferId'] as String?,
              notes: json['metadata']['notes'] as String?,
              category: json['metadata']['category'] as String?,
              isLocked: json['metadata']['isLocked'] as bool? ?? false,
            )
          : const TransactionMetadata(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'projectId': projectId,
      'metadata': {
        'supplier': metadata.supplier,
        'transferId': metadata.transferId,
        'notes': metadata.notes,
        'category': metadata.category,
        'isLocked': metadata.isLocked,
      },
    };
  }

  /// Create from entity
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      type: entity.type,
      description: entity.description,
      amount: entity.amount,
      date: entity.date,
      projectId: entity.projectId,
      metadata: entity.metadata,
    );
  }

  /// Convert to entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      type: type,
      description: description,
      amount: amount,
      date: date,
      projectId: projectId,
      metadata: metadata,
    );
  }

  /// Parse transaction type from string
  static TransactionType _parseTransactionType(String value) {
    switch (value.toLowerCase()) {
      case 'deposit':
        return TransactionType.deposit;
      case 'expense':
        return TransactionType.expense;
      default:
        return TransactionType.expense;
    }
  }
}

