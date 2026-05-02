import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/project_attachment_entity.dart';
import '../../domain/enums/project_status.dart';
import '../cubit/project_attachments_cubit.dart';
import '../cubit/project_attachments_state.dart';
import 'project_attachments_section.dart';

class ProjectAttachmentsPanel extends StatelessWidget {
  final String projectId;
  final ProjectStatus projectStatus;

  const ProjectAttachmentsPanel({
    super.key,
    required this.projectId,
    required this.projectStatus,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<ProjectAttachmentsCubit>()..loadAttachments(projectId),
      child: _ProjectAttachmentsPanelContent(
        projectId: projectId,
        projectStatus: projectStatus,
      ),
    );
  }
}

class _ProjectAttachmentsPanelContent extends StatelessWidget {
  final String projectId;
  final ProjectStatus projectStatus;

  const _ProjectAttachmentsPanelContent({
    required this.projectId,
    required this.projectStatus,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectAttachmentsCubit, ProjectAttachmentsState>(
      listener: (context, state) {
        if (state is ProjectAttachmentsError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is ProjectAttachmentsLoading ||
            state is ProjectAttachmentsInitial) {
          return const ProjectAttachmentsSection(
            attachments: [],
            canDelete: false,
            isUploading: true,
            isDeleting: false,
            onUpload: _noop,
            onDelete: _noopDelete,
          );
        }

        if (state is ProjectAttachmentsError) {
          return ProjectAttachmentsSection(
            attachments: const [],
            canDelete: false,
            isUploading: false,
            isDeleting: false,
            onUpload: () => context
                .read<ProjectAttachmentsCubit>()
                .loadAttachments(projectId),
            onDelete: _noopDelete,
          );
        }

        final loaded = state as ProjectAttachmentsLoaded;
        return ProjectAttachmentsSection(
          attachments: loaded.attachments,
          canDelete: _canDeleteAttachments(context),
          isUploading: loaded.isUploading,
          isDeleting: loaded.isDeleting,
          onUpload: () => _pickAndUploadAttachments(context),
          onDelete: (attachment) =>
              _confirmDeleteAttachment(context, attachment),
        );
      },
    );
  }

  bool _canDeleteAttachments(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;
    final isUnlockedStatus =
        projectStatus == ProjectStatus.draft ||
        projectStatus == ProjectStatus.underPricing;

    return isAdmin || isUnlockedStatus;
  }

  Future<void> _pickAndUploadAttachments(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );

    if (result == null || result.files.isEmpty || !context.mounted) return;

    final filePaths = <String>[];
    final fileBytes = <MapEntry<String, List<int>>>[];

    for (final file in result.files) {
      if (file.path != null) {
        filePaths.add(file.path!);
      } else if (file.bytes != null) {
        fileBytes.add(MapEntry(file.name, file.bytes!));
      }
    }

    if (filePaths.isEmpty && fileBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر قراءة الملفات المحددة')),
      );
      return;
    }

    await context.read<ProjectAttachmentsCubit>().uploadAttachments(
      projectId,
      filePaths,
      fileBytes: fileBytes,
    );

    if (!context.mounted) return;
    if (context.read<ProjectAttachmentsCubit>().state
        is ProjectAttachmentsLoaded) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم رفع المرفقات بنجاح')));
    }
  }

  Future<void> _confirmDeleteAttachment(
    BuildContext context,
    ProjectAttachmentEntity attachment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المرفق'),
        content: Text('هل تريد حذف "${attachment.originalName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<ProjectAttachmentsCubit>().deleteAttachment(
      projectId,
      attachment.id,
    );

    if (!context.mounted) return;
    if (context.read<ProjectAttachmentsCubit>().state
        is ProjectAttachmentsLoaded) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف المرفق')));
    }
  }
}

void _noop() {}

void _noopDelete(ProjectAttachmentEntity attachment) {}
