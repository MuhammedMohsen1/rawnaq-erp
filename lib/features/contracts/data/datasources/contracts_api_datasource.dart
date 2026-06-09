import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/endpoints.dart';

/// API data source for contracts
class ContractsApiDataSource {
  final ApiClient _apiClient;

  ContractsApiDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get contract for a project
  Future<Map<String, dynamic>?> getContract(String projectId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.contract(projectId));
      final responseData = response.data as Map<String, dynamic>;
      // Extract nested data from API response wrapper
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;
      return data;
    } catch (e) {
      // Contract may not exist yet
      return null;
    }
  }

  Future<Map<String, dynamic>> getContractExportDefaults(
    String projectId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.contractExportDefaults(projectId),
    );
    final responseData = response.data as Map<String, dynamic>;
    return responseData['data'] as Map<String, dynamic>? ?? responseData;
  }

  /// Export contract PDF
  Future<Uint8List> exportContractPdf(
    String projectId, {
    String? contractType,
    String? civilId,
    String? projectAddress,
    List<Map<String, String>>? contractTerms,
    List<Map<String, String>>? designScopeItems,
    List<String>? designNotes,
    List<String>? executionNotes,
    int? executionDurationDays,
    String? companySignerName,
    required List<Map<String, dynamic>> paymentSchedule,
  }) async {
    final endpoint = ApiEndpoints.exportContractPdf(projectId);

    final response = await _apiClient.post(
      endpoint,
      data: {
        if (contractType != null && contractType.isNotEmpty)
          'contractType': contractType,
        if (civilId != null && civilId.isNotEmpty) 'civilId': civilId,
        if (projectAddress != null && projectAddress.isNotEmpty)
          'projectAddress': projectAddress,
        if (contractTerms != null && contractTerms.isNotEmpty)
          'contractTerms': contractTerms,
        if (designScopeItems != null && designScopeItems.isNotEmpty)
          'designScopeItems': designScopeItems,
        if (designNotes != null && designNotes.isNotEmpty)
          'designNotes': designNotes,
        if (executionNotes != null && executionNotes.isNotEmpty)
          'executionNotes': executionNotes,
        if (executionDurationDays != null)
          'executionDurationDays': executionDurationDays,
        if (companySignerName != null && companySignerName.isNotEmpty)
          'companySignerName': companySignerName,
        'paymentSchedule': paymentSchedule,
      },
      options: Options(responseType: ResponseType.bytes),
    );

    return response.data as Uint8List;
  }

  /// Confirm contract (move to EXECUTION)
  Future<void> confirmContract(
    String projectId, {
    List<Map<String, dynamic>>? paymentSchedule,
  }) async {
    await _apiClient.post(
      ApiEndpoints.confirmContract(projectId),
      data: {
        if (paymentSchedule != null && paymentSchedule.isNotEmpty)
          'paymentSchedule': paymentSchedule,
      },
    );
  }

  /// Return contract to pricing
  Future<void> returnContractToPricing(
    String projectId, {
    String? reason,
  }) async {
    await _apiClient.post(
      ApiEndpoints.returnContractToPricing(projectId),
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    );
  }
}
