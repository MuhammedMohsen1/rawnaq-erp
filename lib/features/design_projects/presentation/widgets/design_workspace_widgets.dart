import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../domain/entities/design_workspace_entities.dart';
import '../cubit/design_workspace_cubit.dart';

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
    final clientName = project.clientName ?? 'عميل غير محدد';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: _workspaceShellDecoration(),
      child: Wrap(
        spacing: 14,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.palette_outlined,
                  color: AppColors.secondaryLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'مساحة التصميم • $clientName',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (showFinancials)
                FilledButton.tonalIcon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<DesignWorkspaceCubit>(),
                      child: Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(20),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 960),
                          padding: const EdgeInsets.all(24),
                          decoration: _workspaceShellDecoration(),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'البيانات المالية لمشروع التصميم',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                DesignFinanceStrip(project: project),
                                const SizedBox(height: 20),
                                const DesignInstallmentsPanel(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('المالية'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class DesignFinanceStrip extends StatelessWidget {
  final ProjectEntity project;
  const DesignFinanceStrip({super.key, required this.project});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DesignWorkspaceCubit, DesignWorkspaceState>(
      builder: (context, state) {
        final workspace = state is DesignWorkspaceLoaded
            ? state.workspace
            : null;
        final total = workspace?.projectValue ?? project.projectTotalPrice;
        final received = workspace?.totalReceived ?? project.totalReceived;
        final installments = workspace?.installments ?? project.installments;
        final remaining = total - received;
        final paidInstallments = installments
            .where((installment) => installment.isPaid)
            .length;
        final installmentStatus = installments.isEmpty
            ? 'متابعة من المالية'
            : '$paidInstallments / ${installments.length}';
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _FinanceCard(
              label: 'قيمة المشروع',
              value: '${total.toStringAsFixed(0)} د.ك',
            ),
            _FinanceCard(
              label: 'المحصل',
              value: '${received.toStringAsFixed(0)} د.ك',
            ),
            _FinanceCard(
              label: 'المتبقي',
              value: '${remaining.toStringAsFixed(0)} د.ك',
            ),
            _FinanceCard(label: 'حالة الأقساط', value: installmentStatus),
          ],
        );
      },
    );
  }
}

class _FinanceCard extends StatelessWidget {
  final String label;
  final String value;
  const _FinanceCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class DesignTimelinePanel extends StatefulWidget {
  const DesignTimelinePanel({super.key});
  @override
  State<DesignTimelinePanel> createState() => _DesignTimelinePanelState();
}

class DesignInstallmentsPanel extends StatelessWidget {
  const DesignInstallmentsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DesignWorkspaceCubit, DesignWorkspaceState>(
      builder: (context, state) {
        if (state is! DesignWorkspaceLoaded ||
            state.workspace.installments.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'جدول الأقساط',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...state.workspace.installments.map(
              (installment) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: installment.isPaid,
                        onChanged: state.isSubmitting
                            ? null
                            : (value) {
                                context
                                    .read<DesignWorkspaceCubit>()
                                    .toggleInstallment(
                                      installment.id,
                                      value ?? false,
                                    );
                              },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${installment.amount.toStringAsFixed(2)} د.ك',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'تاريخ الاستحقاق: ${installment.dueDate.toLocal().toString().split(' ').first}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
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
                _Composer(
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

class DesignChatBubble extends StatelessWidget {
  final DesignActivity activity;
  final bool isMine;
  const DesignChatBubble({
    super.key,
    required this.activity,
    required this.isMine,
  });
  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine
        ? AppColors.secondary.withValues(alpha: 0.18)
        : AppColors.surfaceColor.withValues(alpha: 0.90);
    final borderRadius = isMine
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(6),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(18),
          );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMine) ...[
              Text(
                activity.author,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
            ],
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: borderRadius,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activity.message.trim().isNotEmpty)
                    Text(activity.message),
                  if (activity.media != null) ...[
                    if (activity.message.trim().isNotEmpty)
                      const SizedBox(height: 8),
                    DesignAttachmentBubble(media: activity.media!),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _relativeTime(activity.createdAt),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      if (isMine) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.done_all,
                          size: 16,
                          color: AppColors.secondaryLight,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAttach;
  final VoidCallback onSend;
  const _Composer({
    required this.controller,
    required this.onAttach,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _ChatActionButton(
            icon: Icons.attach_file,
            tooltip: 'إرفاق ملف',
            onPressed: onAttach,
            enabledColor: AppColors.primary,
            disabledColor: AppColors.textDisabled,
            backgroundColor: AppColors.primary.withValues(alpha: 0.14),
            disabledBackgroundColor: AppColors.surfaceColor.withValues(
              alpha: 0.65,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText: 'اكتب رسالة...',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final canSend = value.text.trim().isNotEmpty;
              return _ChatActionButton(
                icon: Icons.send,
                tooltip: 'إرسال',
                onPressed: canSend ? onSend : null,
                enabledColor: AppColors.white,
                disabledColor: AppColors.textDisabled,
                backgroundColor: AppColors.secondary,
                disabledBackgroundColor: AppColors.surfaceColor.withValues(
                  alpha: 0.65,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DesignAttachmentBubble extends StatelessWidget {
  final DesignMedia media;
  const DesignAttachmentBubble({super.key, required this.media});
  @override
  Widget build(BuildContext context) {
    if (media.type == DesignMediaType.image && media.previewUrl != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openFullscreenImage(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 240,
              maxHeight: 180,
              minWidth: 120,
              minHeight: 90,
            ),
            color: AppColors.inputBackground.withValues(alpha: 0.65),
            child: Image.network(
              media.previewUrl!,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, _, _) => _fileTile(context),
            ),
          ),
        ),
      );
    }

    return _fileTile(context);
  }

  Future<void> _openFullscreenImage(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Image preview',
      barrierColor: Colors.black.withValues(alpha: 0.92),
      pageBuilder: (dialogContext, _, __) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.of(dialogContext).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox.expand(),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1200,
                      maxHeight: 900,
                    ),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          media.previewUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.cardBackground,
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'تعذر فتح الصورة',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 16,
                end: 16,
                child: Material(
                  color: AppColors.cardBackground.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'إغلاق',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fileTile(BuildContext context) {
    return InkWell(
      onTap: media.downloadUrl == null
          ? null
          : () => launchUrl(Uri.parse(media.downloadUrl!)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.inputBackground.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconFor(media.type),
                color: AppColors.primaryLight,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    media.size,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.download_outlined, color: AppColors.primaryLight),
          ],
        ),
      ),
    );
  }
}

class _ChatActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color enabledColor;
  final Color disabledColor;
  final Color backgroundColor;
  final Color disabledBackgroundColor;

  const _ChatActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.enabledColor,
    required this.disabledColor,
    required this.backgroundColor,
    required this.disabledBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled ? backgroundColor : disabledBackgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? enabledColor : disabledColor,
            ),
          ),
        ),
      ),
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
            builder: (context, state) => _PinnedChatHeader(
              project: project,
              showFinancials: state is AuthAuthenticated && state.user.isAdmin,
            ),
          ),
          const SizedBox(height: 6),
          const Expanded(child: DesignTimelinePanel()),
        ],
      ),
    );
  }
}

class _PinnedChatHeader extends StatelessWidget {
  final ProjectEntity project;
  final bool showFinancials;
  const _PinnedChatHeader({
    required this.project,
    required this.showFinancials,
  });

  @override
  Widget build(BuildContext context) {
    final clientName = project.clientName ?? 'عميل غير محدد';
    final lastEdit = project.lastEditAt ?? project.updatedAt;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.palette_outlined,
              color: AppColors.secondaryLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  'مساحة التصميم • $clientName',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (lastEdit != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'آخر تحديث ${_relativeTime(lastEdit)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ],
            ),
          ),
          if (showFinancials)
            FilledButton.tonalIcon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<DesignWorkspaceCubit>(),
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(20),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 960),
                      padding: const EdgeInsets.all(24),
                      decoration: _workspaceShellDecoration(),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'البيانات المالية لمشروع التصميم',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            DesignFinanceStrip(project: project),
                            const SizedBox(height: 20),
                            const DesignInstallmentsPanel(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('المالية'),
            ),
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

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.cardBackground,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: AppColors.border),
);

IconData _iconFor(DesignMediaType type) => switch (type) {
  DesignMediaType.image => Icons.image_outlined,
  DesignMediaType.pdf => Icons.picture_as_pdf_outlined,
  DesignMediaType.video => Icons.play_circle_outline,
  DesignMediaType.technical => Icons.description_outlined,
};

String _relativeTime(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 1) return 'الآن';
  if (difference.inHours < 1) return 'منذ ${difference.inMinutes} دقيقة';
  if (difference.inDays < 1) return 'منذ ${difference.inHours} ساعة';
  return 'منذ ${difference.inDays} يوم';
}
