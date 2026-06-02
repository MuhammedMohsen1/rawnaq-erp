import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../projects/domain/entities/project_entity.dart';
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

  @override
  void dispose() {
    controller.dispose();
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
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: activities.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, index) => DesignChatBubble(
                        activity: activities[index],
                        isMine:
                            currentUserName.isNotEmpty &&
                            activities[index].author.trim() == currentUserName,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DesignWorkspaceComposer(
                  controller: controller,
                  onAttach: _pickFile,
                  onSend: () {
                    final message = controller.text.trim();
                    if (message.isEmpty) return;
                    context.read<DesignWorkspaceCubit>().addComment(message);
                    controller.clear();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    final file = result?.files.single;
    if (file == null || !mounted) return;

    if (file.size > _maxDesignAttachmentBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حجم الملف يجب ألا يتجاوز 1GB')),
      );
      return;
    }

    await context.read<DesignWorkspaceCubit>().upload(
      fileName: file.name,
      filePath: file.path,
      bytes: file.path == null ? file.bytes : null,
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
