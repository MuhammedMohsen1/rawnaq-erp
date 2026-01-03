import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/project_financial_summary.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/mock_transactions_datasource.dart';

/// Implementation of TransactionsRepository using mock data
class TransactionsRepositoryImpl implements TransactionsRepository {
  final MockTransactionsDataSource _dataSource;

  TransactionsRepositoryImpl({MockTransactionsDataSource? dataSource})
      : _dataSource = dataSource ?? MockTransactionsDataSource();

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByProjectId(
    String projectId,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      final transactions = _dataSource.getTransactionsByProjectId(projectId);
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectFinancialSummary>> getProjectFinancialSummary(
    String projectId,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      final transactions = _dataSource.getTransactionsByProjectId(projectId);

      // Calculate financial summary
      double totalReceived = 0.0;
      double totalExpenses = 0.0;

      for (final transaction in transactions) {
        if (transaction.type == TransactionType.deposit) {
          totalReceived += transaction.amount;
        } else {
          totalExpenses += transaction.amount;
        }
      }

      final netCashFlow = totalReceived - totalExpenses;

      // Calculate budget percentage (assuming a budget of 50,000 KD based on image)
      const double budget = 50000.0;
      final remainingBudget = budget - totalExpenses;
      final budgetPercentage = budget > 0 ? (remainingBudget / budget) * 100 : 0.0;

      final summary = ProjectFinancialSummary(
        totalReceived: totalReceived,
        totalExpenses: totalExpenses,
        netCashFlow: netCashFlow,
        budget: budget,
        remainingBudget: remainingBudget,
        budgetPercentage: budgetPercentage,
      );

      return Right(summary);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // In a real implementation, this would save to the data source
      // For now, just return the transaction
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String transactionId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      // In a real implementation, this would delete from the data source
      // For now, just return success
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

