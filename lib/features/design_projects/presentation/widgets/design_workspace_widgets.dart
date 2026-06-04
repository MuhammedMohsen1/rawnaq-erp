import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:pasteboard/pasteboard.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../domain/entities/design_workspace_entities.dart';
import '../cubit/design_workspace_cubit.dart';
import 'design_workspace_message_widgets.dart';
import 'design_workspace_support_widgets.dart';

const int _maxDesignAttachmentBytes = 1024 * 1024 * 1024;

class DesignWorkspaceHeader extends StatelessWidget {
  final ProjectEntity project;
  final bool showFinancials;

  const DesignWorkspaceHeader({
    super.key,
    required this.project,
    required this.showFinancials,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DesignWorkspaceProjectHeader(
        project: project,
        showFinancials: showFinancials,
        canComplete: false,
      ),
    );
  }
}

class DesignTimelinePanel extends StatefulWidget {
  const DesignTimelinePanel({super.key});

  @override
  State<DesignTimelinePanel> createState() => _DesignTimelinePanelState();
}

class _DesignTimelinePanelState extends State<DesignTimelinePanel> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  var _isDragging = false;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUserName = authState is AuthAuthenticated
            ? authState.user.name.trim()
            : '';
        return BlocBuilder<DesignWorkspaceCubit, DesignWorkspaceState>(
          builder: (context, state) {
            if (state is! DesignWorkspaceLoaded) {
              return const SizedBox.shrink();
            }
            final activities = state.workspace.activities.reversed.toList();
            _scrollToLatestMessage();
            return DropTarget(
              onDragEntered: (_) => setState(() => _isDragging = true),
              onDragExited: (_) => setState(() => _isDragging = false),
              onDragDone: (details) async {
                setState(() => _isDragging = false);
                final quality = await _qualityForUpload(
                  details.files.any((file) => _isVideoFile(file.name)),
                );
                if (quality == null) return;
                for (final file in details.files) {
                  await _uploadDroppedFile(file, quality);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground.withValues(
                              alpha: 0.62,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(12),
                            itemCount: activities.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, index) => DesignChatBubble(
                              activity: activities[index],
                              isMine:
                                  currentUserName.isNotEmpty &&
                                  activities[index].author.trim() ==
                                      currentUserName,
                            ),
                          ),
                        ),
                        if (_isDragging)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.primaryLight,
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.upload_file,
                                  size: 42,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  DesignWorkspaceComposer(
                    controller: controller,
                    onAttach: _pickFile,
                    onPaste: _pasteClipboardContents,
                    onSend: () {
                      final message = controller.text.trim();
                      if (message.isEmpty) return;
                      context.read<DesignWorkspaceCubit>().addComment(message);
                      controller.clear();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    final files = result?.files;
    if (files == null || !mounted) return;

    final quality = await _qualityForUpload(
      files.any((file) => _isVideoFile(file.name)),
    );
    if (quality == null) return;

    for (final file in files) {
      await _uploadPickedFile(file, quality);
    }
  }

  Future<void> _pasteClipboardContents() async {
    final filePaths = await Pasteboard.files();
    if (filePaths.isNotEmpty) {
      await _uploadPastedFiles(filePaths);
      return;
    }

    final imageBytes = await Pasteboard.image;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      await _uploadPastedImage(imageBytes);
      return;
    }

    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    if (text == null || text.isEmpty) return;

    final selection = controller.selection;
    final currentText = controller.text;
    final start = selection.isValid ? selection.start : currentText.length;
    final end = selection.isValid ? selection.end : currentText.length;
    final nextText = currentText.replaceRange(start, end, text);
    controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: start + text.length),
    );
  }

  Future<void> _uploadPastedFiles(List<String> filePaths) async {
    final quality = await _qualityForUpload(filePaths.any(_isVideoFile));
    if (quality == null) return;

    for (final path in filePaths) {
      final file = io.File(path);
      if (!await file.exists()) continue;
      final size = await file.length();
      if (!mounted) return;

      if (size > _maxDesignAttachmentBytes) {
        _showOversizedFileMessage();
        continue;
      }

      await context.read<DesignWorkspaceCubit>().upload(
        fileName: path.split(io.Platform.pathSeparator).last,
        filePath: path,
        videoQuality: quality,
      );
    }
  }

  Future<void> _uploadPastedImage(Uint8List imageBytes) async {
    if (imageBytes.lengthInBytes > _maxDesignAttachmentBytes) {
      _showOversizedFileMessage();
      return;
    }

    await context.read<DesignWorkspaceCubit>().upload(
      fileName: 'pasted_image_${DateTime.now().millisecondsSinceEpoch}.png',
      bytes: imageBytes,
      videoQuality: DesignVideoQuality.p720,
    );
  }

  Future<void> _uploadPickedFile(
    PlatformFile file,
    DesignVideoQuality videoQuality,
  ) async {
    if (file.size > _maxDesignAttachmentBytes) {
      _showOversizedFileMessage();
      return;
    }

    await context.read<DesignWorkspaceCubit>().upload(
      fileName: file.name,
      filePath: file.path,
      bytes: file.path == null ? file.bytes : null,
      videoQuality: videoQuality,
    );
  }

  Future<void> _uploadDroppedFile(
    dynamic file,
    DesignVideoQuality videoQuality,
  ) async {
    final fileSize = await file.length();
    if (!mounted) return;

    if (fileSize > _maxDesignAttachmentBytes) {
      _showOversizedFileMessage();
      return;
    }

    final path = file.path as String;
    await context.read<DesignWorkspaceCubit>().upload(
      fileName: file.name,
      filePath: path.isEmpty ? null : path,
      bytes: path.isEmpty ? await file.readAsBytes() : null,
      videoQuality: videoQuality,
    );
  }

  Future<DesignVideoQuality?> _qualityForUpload(bool hasVideo) {
    if (!hasVideo) return Future.value(DesignVideoQuality.p720);
    return showDialog<DesignVideoQuality>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر جودة الفيديو'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DesignVideoQuality.values
              .map(
                (quality) => ListTile(
                  leading: const Icon(Icons.high_quality_outlined),
                  title: Text(quality.label),
                  onTap: () => Navigator.of(context).pop(quality),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  bool _isVideoFile(String fileName) {
    final normalized = fileName.toLowerCase();
    return normalized.endsWith('.mp4') ||
        normalized.endsWith('.mov') ||
        normalized.endsWith('.webm') ||
        normalized.endsWith('.m4v');
  }

  void _scrollToLatestMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  void _showOversizedFileMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('حجم الملف يجب ألا يتجاوز 1GB')),
    );
  }
}

class DesignWorkspaceBody extends StatelessWidget {
  final ProjectEntity project;

  const DesignWorkspaceBody({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DesignWorkspaceCubit, DesignWorkspaceState>(
      builder: (context, state) {
        if (state is DesignWorkspaceLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is DesignWorkspaceFailure) {
          return Center(
            child: Column(
              children: [
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: context.read<DesignWorkspaceCubit>().load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        final loaded = state as DesignWorkspaceLoaded;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (loaded.isSubmitting) const LinearProgressIndicator(),
            if (loaded.isSubmitting) const SizedBox(height: 12),
            Expanded(child: DesignTimelineSurface(project: project)),
          ],
        );
      },
    );
  }
}

class DesignTimelineSurface extends StatelessWidget {
  final ProjectEntity project;

  const DesignTimelineSurface({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: _workspaceShellDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => DesignWorkspaceProjectHeader(
              project: project,
              showFinancials:
                  state is AuthAuthenticated &&
                  (state.user.isAdmin || state.user.isManager),
              canComplete:
                  state is AuthAuthenticated &&
                  (state.user.isAdmin || state.user.isManager),
            ),
          ),
          const SizedBox(height: 6),
          const Expanded(child: DesignTimelinePanel()),
        ],
      ),
    );
  }
}

BoxDecoration _workspaceShellDecoration() => BoxDecoration(
  color: AppColors.cardBackground,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: AppColors.border),
  boxShadow: const [
    BoxShadow(color: Color(0x18000000), blurRadius: 18, offset: Offset(0, 8)),
  ],
);
