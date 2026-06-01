import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/constants/endpoints.dart';
import '../../../../core/network/api_client.dart';

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
      formData: FormData.fromMap({'files': file}),
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

  Future<void> updateInstallmentStatus(
    String projectId,
    String installmentId,
    bool isPaid,
  ) async {
    await _apiClient.patch(
      ApiEndpoints.designInstallment(projectId, installmentId),
      data: {'isPaid': isPaid},
    );
  }

  Map<String, dynamic> _dataMap(dynamic response) {
    final map = response as Map<String, dynamic>;
    return (map['data'] as Map<String, dynamic>?) ?? map;
  }
}
