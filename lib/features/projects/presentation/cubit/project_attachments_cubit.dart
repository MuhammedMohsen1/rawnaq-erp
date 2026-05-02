import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/projects_repository.dart';
import 'project_attachments_state.dart';

class ProjectAttachmentsCubit extends Cubit<ProjectAttachmentsState> {
  final ProjectsRepository projectsRepository;

  ProjectAttachmentsCubit({required this.projectsRepository})
    : super(const ProjectAttachmentsInitial());

  Future<void> loadAttachments(String projectId) async {
    emit(const ProjectAttachmentsLoading());

    final result = await projectsRepository.getProjectAttachments(projectId);
    result.fold(
      (failure) => emit(ProjectAttachmentsError(message: failure.message)),
      (attachments) => emit(ProjectAttachmentsLoaded(attachments: attachments)),
    );
  }

  Future<void> uploadAttachments(
    String projectId,
    List<String> filePaths, {
    List<MapEntry<String, List<int>>>? fileBytes,
  }) async {
    final currentState = state;
    if (currentState is! ProjectAttachmentsLoaded) return;

    emit(currentState.copyWith(isUploading: true));

    final result = await projectsRepository.uploadProjectAttachments(
      projectId,
      filePaths,
      fileBytes: fileBytes,
    );

    result.fold(
      (failure) => emit(ProjectAttachmentsError(message: failure.message)),
      (newAttachments) => emit(
        currentState.copyWith(
          attachments: [...newAttachments, ...currentState.attachments],
          isUploading: false,
        ),
      ),
    );
  }

  Future<void> deleteAttachment(String projectId, String attachmentId) async {
    final currentState = state;
    if (currentState is! ProjectAttachmentsLoaded) return;

    emit(currentState.copyWith(isDeleting: true));

    final result = await projectsRepository.deleteProjectAttachment(
      projectId,
      attachmentId,
    );

    result.fold(
      (failure) => emit(ProjectAttachmentsError(message: failure.message)),
      (_) => emit(
        currentState.copyWith(
          attachments: currentState.attachments
              .where((attachment) => attachment.id != attachmentId)
              .toList(),
          isDeleting: false,
        ),
      ),
    );
  }
}
