import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/constants/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/design_workspace_entities.dart';

const int _maxDesignAttachmentBytes = 1024 * 1024 * 1024;

class DesignWorkspaceApiDataSource {
  final ApiClient _apiClient;

  DesignWorkspaceApiDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getWorkspace(String projectId) async {
    final response = await _apiClient.get(
      ApiEndpoints.designWorkspace(projectId),
    );
    return _dataMap(response.data);
  }

  Future<void> addComment(String projectId, String message) async {
    await _apiClient.post(
      ApiEndpoints.designComments(projectId),
      data: {'message': message},
    );
  }

  Future<void> uploadAttachment(
    String projectId, {
    required String fileName,
    String? filePath,
    List<int>? bytes,
    DesignVideoQuality videoQuality = DesignVideoQuality.p720,
  }) async {
    final fileSize =
        bytes?.length ??
        (filePath != null ? await File(filePath).length() : null);
    if (fileSize != null && fileSize > _maxDesignAttachmentBytes) {
      throw DioException(
        requestOptions: RequestOptions(
          path: ApiEndpoints.designAttachments(projectId),
        ),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(
            path: ApiEndpoints.designAttachments(projectId),
          ),
          statusCode: 400,
          data: {
            'success': false,
            'code': 'BAD_REQUEST',
            'message': 'حجم الملف يجب ألا يتجاوز 1GB',
          },
        ),
      );
    }

    final file = filePath != null
        ? await MultipartFile.fromFile(filePath, filename: fileName)
        : MultipartFile.fromBytes(bytes!, filename: fileName);
    await _apiClient.uploadFile(
      ApiEndpoints.designAttachments(projectId),
      formData: FormData.fromMap({
        'files': file,
        'videoQuality': videoQuality.apiValue,
      }),
    );
  }

  Future<void> assignTask(
    String projectId,
    String taskId,
    String assigneeId,
  ) async {
    await _apiClient.patch(
      ApiEndpoints.designTaskAssign(projectId, taskId),
      data: {'designerId': assigneeId},
    );
  }

  Future<void> updateTaskStatus(
    String projectId,
    String taskId,
    String status,
  ) async {
    await _apiClient.patch(
      ApiEndpoints.designTaskStatus(projectId, taskId),
      data: {'status': status},
    );
  }

  Future<void> updateInstallment(
    String projectId,
    String installmentId, {
    bool? isPaid,
    double? amount,
    DateTime? dueDate,
  }) async {
    final payload = <String, dynamic>{
      if (isPaid != null) 'isPaid': isPaid,
      if (amount != null) 'amount': amount,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
    };
    await _apiClient.patch(
      ApiEndpoints.designInstallment(projectId, installmentId),
      data: payload,
    );
  }

  Future<void> uploadInstallmentCapture(
    String projectId,
    String installmentId, {
    required String fileName,
    String? filePath,
    List<int>? bytes,
  }) async {
    final file = filePath != null
        ? await MultipartFile.fromFile(filePath, filename: fileName)
        : MultipartFile.fromBytes(bytes!, filename: fileName);
    await _apiClient.uploadFile(
      ApiEndpoints.designInstallmentCapture(projectId, installmentId),
      formData: FormData.fromMap({'files': file}),
    );
  }

  Future<void> replaceInstallments(
    String projectId,
    List<Map<String, dynamic>> paymentSchedule,
  ) async {
    await _apiClient.patch(
      ApiEndpoints.designInstallments(projectId),
      data: {'paymentSchedule': paymentSchedule},
    );
  }

  Map<String, dynamic> _dataMap(dynamic response) {
    final map = response as Map<String, dynamic>;
    return (map['data'] as Map<String, dynamic>?) ?? map;
  }
}
