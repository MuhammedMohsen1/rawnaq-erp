import '../../../../core/constants/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/financial_summary_model.dart';
import '../models/project_financial_overview_model.dart';

class FinancialApiDataSource {
  final ApiClient _apiClient;

  FinancialApiDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<FinancialSummaryModel> getSummary({
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.financialSummary,
      queryParameters: {
        if (period != null) 'period': period,
        if (startDate != null) 'startDate': _date(startDate),
        if (endDate != null) 'endDate': _date(endDate),
      },
    );
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
    return FinancialSummaryModel.fromJson(data);
  }

  Future<ProjectFinancialOverviewModel> getProjectOverview(
    String projectId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.projectFinancialOverview(projectId),
    );
    final map = response.data as Map<String, dynamic>;
    return ProjectFinancialOverviewModel.fromJson(
      map['data'] as Map<String, dynamic>? ?? map,
    );
  }

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
