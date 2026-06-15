import '../../../../core/network/api_client.dart';
import '../../../../core/constants/endpoints.dart';

/// API data source for settings
class SettingsApiDataSource {
  final ApiClient _apiClient;

  SettingsApiDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, List<Map<String, String>>>>
  getDefaultContractTerms() async {
    final response = await _apiClient.get(ApiEndpoints.contractTerms);

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>?;
    List<Map<String, String>> mapTerms(String key) {
      final terms = data?[key] as List?;
      if (terms == null) {
        return [];
      }
      return terms.map((term) {
        return {
          'title': (term as Map<String, dynamic>)['title'] as String? ?? '',
          'description': term['description'] as String? ?? '',
        };
      }).toList();
    }

    return {
      'designTerms': mapTerms('designTerms'),
      'executionTerms': mapTerms('executionTerms'),
    };
  }

  Future<List<Map<String, String>>> getDefaultContractTermsForType(
    String contractType,
  ) async {
    final terms = await getDefaultContractTerms();
    return contractType == 'DESIGN'
        ? (terms['designTerms'] ?? [])
        : (terms['executionTerms'] ?? []);
  }

  Future<void> updateDefaultContractTerms({
    required List<Map<String, String>> designTerms,
    required List<Map<String, String>> executionTerms,
  }) async {
    await _apiClient.put(
      ApiEndpoints.contractTerms,
      data: {
        'designTerms': designTerms.map((term) {
          return {
            'title': term['title'] ?? '',
            'description': term['description'] ?? '',
          };
        }).toList(),
        'executionTerms': executionTerms.map((term) {
          return {
            'title': term['title'] ?? '',
            'description': term['description'] ?? '',
          };
        }).toList(),
      },
    );
  }

  Future<String> getDefaultPricingNotes() async {
    final response = await _apiClient.get(ApiEndpoints.pricingNotes);

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>?;
    return data?['notes'] as String? ?? '';
  }

  Future<void> updateDefaultPricingNotes(String notes) async {
    await _apiClient.put(ApiEndpoints.pricingNotes, data: {'value': notes});
  }
}
