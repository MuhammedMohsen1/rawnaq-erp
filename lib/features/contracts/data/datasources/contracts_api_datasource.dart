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
    String? civilId,
    String? projectAddress,
    List<Map<String, String>>? contractTerms,
    required List<Map<String, dynamic>> paymentSchedule,
  }) async {
    final endpoint = ApiEndpoints.exportContractPdf(projectId);

    final response = await _apiClient.post(
      endpoint,
      data: {
        if (civilId != null && civilId.isNotEmpty) 'civilId': civilId,
        if (projectAddress != null && projectAddress.isNotEmpty)
          'projectAddress': projectAddress,
        if (contractTerms != null && contractTerms.isNotEmpty)
          'contractTerms': contractTerms,
        'paymentSchedule': paymentSchedule,
      },
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

