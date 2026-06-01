import '../datasources/design_workspace_api_datasource.dart';
import '../../domain/entities/design_workspace_entities.dart';

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
  }) => _dataSource.uploadAttachment(
    projectId,
    fileName: fileName,
    filePath: filePath,
    bytes: bytes,
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
  Future<void> updateInstallmentStatus(
    String projectId,
    String installmentId,
    bool isPaid,
  ) => _dataSource.updateInstallmentStatus(projectId, installmentId, isPaid);
}
