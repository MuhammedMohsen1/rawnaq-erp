import '../../../../core/constants/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/financial_summary_model.dart';

class FinancialApiDataSource {
  final ApiClient _apiClient;

  FinancialApiDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<FinancialSummaryModel> getSummary() async {
    final response = await _apiClient.get(ApiEndpoints.financialSummary);
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
    return FinancialSummaryModel.fromJson(data);
  }
}
