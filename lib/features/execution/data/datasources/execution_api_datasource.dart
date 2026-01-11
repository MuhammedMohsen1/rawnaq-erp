import '../../../../core/network/api_client.dart';
import '../../../../core/constants/endpoints.dart';
import '../models/execution_models.dart';

/// API data source for execution
class ExecutionApiDataSource {
  final ApiClient _apiClient;

  ExecutionApiDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get execution dashboard data
  Future<ExecutionDashboardModel> getExecutionDashboard(String projectId) async {
    final response = await _apiClient.get(
      ApiEndpoints.executionDashboard(projectId),
    );

    final responseData = response.data as Map<String, dynamic>;
    return ExecutionDashboardModel.fromJson(responseData);
  }

  /// Get paginated transactions
  Future<List<TransactionModel>> getTransactions(
    String projectId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.executionTransactions(projectId),
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final transactions = responseData['transactions'] as List? ?? [];
    return transactions
        .map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Get available payment phases
  Future<List<PaymentPhaseModel>> getAvailablePhases(String projectId) async {
    final response = await _apiClient.get(
      ApiEndpoints.executionAvailablePhases(projectId),
    );

    final data = response.data as List? ?? [];
    return data
        .map((p) => PaymentPhaseModel.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Request an installment (Site Engineer)
  Future<InstallmentRequestModel> requestInstallment(
    String projectId, {
    required int phaseIndex,
    required String phaseName,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.executionRequestInstallment(projectId),
      data: {
        'phaseIndex': phaseIndex,
        'phaseName': phaseName,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    return InstallmentRequestModel.fromJson(responseData);
  }

  /// Approve an installment request (Admin/Manager)
  Future<InstallmentRequestModel> approveInstallment(String requestId) async {
    final response = await _apiClient.patch(
      ApiEndpoints.approveInstallment(requestId),
    );

    final responseData = response.data as Map<String, dynamic>;
    return InstallmentRequestModel.fromJson(responseData);
  }

  /// Reject an installment request (Admin/Manager)
  Future<InstallmentRequestModel> rejectInstallment(
    String requestId, {
    required String reason,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.rejectInstallment(requestId),
      data: {'reason': reason},
    );

    final responseData = response.data as Map<String, dynamic>;
    return InstallmentRequestModel.fromJson(responseData);
  }

  /// Create expense
  Future<void> createExpense(String projectId, CreateExpenseDto dto) async {
    await _apiClient.post(
      ApiEndpoints.contractExpenses(projectId),
      data: dto.toJson(),
    );
  }

  /// Update expense
  Future<void> updateExpense(
    String projectId,
    String expenseId,
    UpdateExpenseDto dto,
  ) async {
    await _apiClient.patch(
      ApiEndpoints.contractExpense(projectId, expenseId),
      data: dto.toJson(),
    );
  }

  /// Delete expense
  Future<void> deleteExpense(String projectId, String expenseId) async {
    await _apiClient.delete(
      ApiEndpoints.contractExpense(projectId, expenseId),
    );
  }
}
