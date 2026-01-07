import '../../../../core/network/api_client.dart';
import '../../../../core/constants/endpoints.dart';

/// API data source for settings
class SettingsApiDataSource {
  final ApiClient _apiClient;

  SettingsApiDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get default contract terms
  Future<String> getDefaultContractTerms() async {
    final response = await _apiClient.get(
      ApiEndpoints.contractTerms,
    );

    final responseData = response.data as Map<String, dynamic>;
    return responseData['terms'] as String? ?? '';
  }

  /// Update default contract terms (admin/manager only)
  Future<void> updateDefaultContractTerms(String terms) async {
    await _apiClient.put(
      ApiEndpoints.contractTerms,
      data: {'value': terms},
    );
  }
}

