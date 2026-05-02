import 'package:equatable/equatable.dart';
import '../../domain/entities/project_attachment_entity.dart';

sealed class ProjectAttachmentsState extends Equatable {
  const ProjectAttachmentsState();

  @override
  List<Object?> get props => [];
}

class ProjectAttachmentsInitial extends ProjectAttachmentsState {
  const ProjectAttachmentsInitial();
}

class ProjectAttachmentsLoading extends ProjectAttachmentsState {
  const ProjectAttachmentsLoading();
}

class ProjectAttachmentsLoaded extends ProjectAttachmentsState {
  final List<ProjectAttachmentEntity> attachments;
  final bool isUploading;
  final bool isDeleting;

  const ProjectAttachmentsLoaded({
    required this.attachments,
    this.isUploading = false,
    this.isDeleting = false,
  });

  ProjectAttachmentsLoaded copyWith({
    List<ProjectAttachmentEntity>? attachments,
    bool? isUploading,
    bool? isDeleting,
  }) {
    return ProjectAttachmentsLoaded(
      attachments: attachments ?? this.attachments,
      isUploading: isUploading ?? this.isUploading,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [attachments, isUploading, isDeleting];
}

class ProjectAttachmentsError extends ProjectAttachmentsState {
  final String message;

  const ProjectAttachmentsError({required this.message});

  @override
  List<Object?> get props => [message];
}
