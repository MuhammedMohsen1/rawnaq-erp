import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/endpoints.dart';

/// API data source for contracts
class ContractsApiDataSource {
  final ApiClient _apiClient;

  ContractsApiDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Export contract PDF
  Future<Uint8List> exportContractPdf(
    String projectId, {
    String? contractTerms,
  }) async {
    final endpoint = ApiEndpoints.exportContractPdf(projectId);
    final queryParams = contractTerms != null
        ? {'contractTerms': contractTerms}
        : null;

    final response = await _apiClient.get(
      endpoint,
      queryParameters: queryParams,
      options: Options(responseType: ResponseType.bytes),
    );

    return response.data as Uint8List;
  }

  /// Confirm contract (move to EXECUTION)
  Future<void> confirmContract(String projectId) async {
    await _apiClient.post(
      ApiEndpoints.confirmContract(projectId),
    );
  }

  /// Return contract to pricing
  Future<void> returnContractToPricing(
    String projectId, {
    String? reason,
  }) async {
    await _apiClient.post(
      ApiEndpoints.returnContractToPricing(projectId),
      data: {
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
  }
}

