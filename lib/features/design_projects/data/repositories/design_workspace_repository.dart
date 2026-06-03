import '../datasources/design_workspace_api_datasource.dart';
import '../../domain/entities/design_workspace_entities.dart';
import '../../../projects/domain/entities/project_entity.dart';

class DesignWorkspaceRepository {
  final DesignWorkspaceApiDataSource _dataSource;
  DesignWorkspaceRepository({DesignWorkspaceApiDataSource? dataSource})
    : _dataSource = dataSource ?? DesignWorkspaceApiDataSource();

  Future<DesignWorkspace> getWorkspace(String projectId) async =>
      DesignWorkspace.fromJson(await _dataSource.getWorkspace(projectId));
  Future<void> addComment(String projectId, String message) =>
      _dataSource.addComment(projectId, message);
  Future<void> uploadAttachment(
    String projectId, {
    required String fileName,
    String? filePath,
    List<int>? bytes,
    DesignVideoQuality videoQuality = DesignVideoQuality.p720,
  }) => _dataSource.uploadAttachment(
    projectId,
    fileName: fileName,
    filePath: filePath,
    bytes: bytes,
    videoQuality: videoQuality,
  );
  Future<void> assignTask(String projectId, String taskId, String assigneeId) =>
      _dataSource.assignTask(projectId, taskId, assigneeId);
  Future<void> updateTaskStatus(
    String projectId,
    String taskId,
    DesignTaskStatus status,
  ) => _dataSource.updateTaskStatus(projectId, taskId, switch (status) {
    DesignTaskStatus.pending => 'TODO',
    DesignTaskStatus.inProgress => 'IN_PROGRESS',
    DesignTaskStatus.completed => 'DONE',
  });
  Future<void> updateInstallment(
    String projectId,
    String installmentId, {
    bool? isPaid,
    double? amount,
    DateTime? dueDate,
  }) => _dataSource.updateInstallment(
    projectId,
    installmentId,
    isPaid: isPaid,
    amount: amount,
    dueDate: dueDate,
  );
  Future<void> uploadInstallmentCapture(
    String projectId,
    String installmentId, {
    required String fileName,
    String? filePath,
    List<int>? bytes,
  }) => _dataSource.uploadInstallmentCapture(
    projectId,
    installmentId,
    fileName: fileName,
    filePath: filePath,
    bytes: bytes,
  );
  Future<void> replaceInstallments(
    String projectId,
    List<ProjectInstallment> installments,
  ) => _dataSource.replaceInstallments(
    projectId,
    installments
        .map(
          (installment) => {
            'id': installment.id,
            'amount': installment.amount,
            'dueDate': installment.dueDate.toIso8601String(),
            'isPaid': installment.isPaid,
            'captures': installment.captures
                .map(
                  (capture) => {
                    'id': capture.id,
                    'url': capture.url,
                    'fileName': capture.fileName,
                    if (capture.mimeType != null) 'mimeType': capture.mimeType,
                    if (capture.createdAt != null)
                      'createdAt': capture.createdAt!.toIso8601String(),
                  },
                )
                .toList(),
          },
        )
        .toList(),
  );
}
