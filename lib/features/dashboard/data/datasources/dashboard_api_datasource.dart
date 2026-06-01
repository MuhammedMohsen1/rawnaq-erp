import '../../../../core/constants/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_summary_model.dart';

class DashboardApiDataSource {
  final ApiClient _client;
  DashboardApiDataSource({ApiClient? client}) : _client = client ?? ApiClient();

  Future<DashboardSummaryModel> getSummary(String period) async {
    final response = await _client.get(
      ApiEndpoints.dashboardSummary,
      queryParameters: {'period': period},
    );
    final map = response.data as Map<String, dynamic>;
    return DashboardSummaryModel.fromJson(
      map['data'] as Map<String, dynamic>? ?? map,
    );
  }
}
