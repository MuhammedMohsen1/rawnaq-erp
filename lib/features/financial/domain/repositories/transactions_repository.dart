import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';
import '../entities/project_financial_summary.dart';

/// Repository interface for financial transactions
abstract class TransactionsRepository {
  /// Get all transactions for a project
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByProjectId(
    String projectId,
  );

  /// Get financial summary for a project
  Future<Either<Failure, ProjectFinancialSummary>> getProjectFinancialSummary(
    String projectId,
  );

  /// Create a new transaction
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  );

  /// Delete a transaction
  Future<Either<Failure, void>> deleteTransaction(String transactionId);
}

