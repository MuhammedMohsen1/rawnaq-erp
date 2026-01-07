import '../../../../core/network/api_client.dart';
import '../../../../core/constants/endpoints.dart';

/// API data source for settings
class SettingsApiDataSource {
  final ApiClient _apiClient;

  SettingsApiDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get default contract terms (returns list of terms with title and description)
  Future<List<Map<String, String>>> getDefaultContractTerms() async {
    final response = await _apiClient.get(
      ApiEndpoints.contractTerms,
    );

    final responseData = response.data as Map<String, dynamic>;
    // Extract data from standard response format
    final data = responseData['data'] as Map<String, dynamic>?;
    final terms = data?['terms'] as List?;
    
    if (terms == null) {
      return [];
    }
    
    return terms
        .map((term) {
          return {
            'title': (term as Map<String, dynamic>)['title'] as String? ?? '',
            'description': term['description'] as String? ?? '',
          };
        })
        .toList();
  }

  /// Update default contract terms (admin/manager only)
  Future<void> updateDefaultContractTerms(
    List<Map<String, String>> terms,
  ) async {
    await _apiClient.put(
      ApiEndpoints.contractTerms,
      data: {
        'terms': terms
            .map((term) {
              return {
                'title': term['title'] ?? '',
                'description': term['description'] ?? '',
              };
            })
            .toList(),
      },
    );
  }
}

