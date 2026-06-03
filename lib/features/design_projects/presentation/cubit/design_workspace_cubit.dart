import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/design_workspace_repository.dart';
import '../../domain/entities/design_workspace_entities.dart';
import '../../../projects/domain/entities/project_entity.dart';

sealed class DesignWorkspaceState {
  const DesignWorkspaceState();
}

final class DesignWorkspaceLoading extends DesignWorkspaceState {
  const DesignWorkspaceLoading();
}

final class DesignWorkspaceFailure extends DesignWorkspaceState {
  final String message;
  const DesignWorkspaceFailure(this.message);
}

final class DesignWorkspaceLoaded extends DesignWorkspaceState {
  final DesignWorkspace workspace;
  final bool isSubmitting;
  const DesignWorkspaceLoaded(this.workspace, {this.isSubmitting = false});
}

class DesignWorkspaceCubit extends Cubit<DesignWorkspaceState> {
  final String projectId;
  final DesignWorkspaceRepository _repository;
  DesignWorkspaceCubit({
    required this.projectId,
    DesignWorkspaceRepository? repository,
  }) : _repository = repository ?? DesignWorkspaceRepository(),
       super(const DesignWorkspaceLoading());

  Future<void> load() async {
    emit(const DesignWorkspaceLoading());
    await _reload();
  }

  Future<void> addComment(String message) async {
    if (message.trim().isEmpty) return;
    await _perform(() => _repository.addComment(projectId, message.trim()));
  }

  Future<void> upload({
    required String fileName,
    String? filePath,
    List<int>? bytes,
    DesignVideoQuality videoQuality = DesignVideoQuality.p720,
  }) => _perform(
    () => _repository.uploadAttachment(
      projectId,
      fileName: fileName,
      filePath: filePath,
      bytes: bytes,
      videoQuality: videoQuality,
    ),
  );

  Future<void> assignDesigner(String taskId, String designerId) =>
      _perform(() => _repository.assignTask(projectId, taskId, designerId));

  Future<void> toggleTask(DesignTask task) => _perform(
    () => _repository.updateTaskStatus(
      projectId,
      task.id,
      task.status == DesignTaskStatus.completed
          ? DesignTaskStatus.inProgress
          : DesignTaskStatus.completed,
    ),
  );

  Future<void> toggleInstallment(String installmentId, bool isPaid) => _perform(
    () =>
        _repository.updateInstallment(projectId, installmentId, isPaid: isPaid),
  );

  Future<void> updateInstallment(
    String installmentId, {
    bool? isPaid,
    double? amount,
    DateTime? dueDate,
  }) => _perform(
    () => _repository.updateInstallment(
      projectId,
      installmentId,
      isPaid: isPaid,
      amount: amount,
      dueDate: dueDate,
    ),
  );

  Future<void> uploadInstallmentCapture(
    String installmentId, {
    required String fileName,
    String? filePath,
    List<int>? bytes,
  }) => _perform(
    () => _repository.uploadInstallmentCapture(
      projectId,
      installmentId,
      fileName: fileName,
      filePath: filePath,
      bytes: bytes,
    ),
  );

  Future<void> replaceInstallments(List<ProjectInstallment> installments) =>
      _perform(() => _repository.replaceInstallments(projectId, installments));

  Future<void> _perform(Future<void> Function() operation) async {
    final current = state;
    if (current is DesignWorkspaceLoaded) {
      emit(DesignWorkspaceLoaded(current.workspace, isSubmitting: true));
    }
    try {
      await operation();
      await _reload();
    } catch (error) {
      emit(DesignWorkspaceFailure(_message(error)));
    }
  }

  Future<void> _reload() async {
    try {
      emit(DesignWorkspaceLoaded(await _repository.getWorkspace(projectId)));
    } catch (error) {
      emit(DesignWorkspaceFailure(_message(error)));
    }
  }

  String _message(Object error) => 'تعذر تحميل مساحة مشروع التصميم. $error';
}
