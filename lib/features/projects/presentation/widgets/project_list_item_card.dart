import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/enums/project_status.dart';
import '../widgets/project_list_item_card_support_widgets.dart';

class ProjectListItemCard extends StatefulWidget {
  final ProjectEntity project;
  final bool compact;
  final bool enableNavigation;
  final bool showArchiveActions;
  final bool showRestoreActions;
  final bool showStatusActions;
  final ValueChanged<ProjectEntity> onNavigate;
  final ValueChanged<ProjectEntity> onEdit;
  final ValueChanged<ProjectEntity>? onArchive;
  final ValueChanged<ProjectEntity>? onDelete;
  final ValueChanged<ProjectEntity>? onRestore;
  final ValueChanged<ProjectEntity>? onMoveToExecution;

  const ProjectListItemCard({
    super.key,
    required this.project,
    required this.compact,
    required this.enableNavigation,
    required this.showArchiveActions,
    required this.showRestoreActions,
    required this.showStatusActions,
    required this.onNavigate,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
    required this.onRestore,
    required this.onMoveToExecution,
  });

  @override
  State<ProjectListItemCard> createState() => _ProjectListItemCardState();
}

class _ProjectListItemCardState extends State<ProjectListItemCard> {
  bool _hovered = false;

  void _copy(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = _metaOf(widget.project.status, widget.project.lastEditAt);
    final dateProgress = _dateProgress(widget.project);
    final projectTotalPrice = widget.project.projectTotalPrice;
    final receivedProgress = projectTotalPrice > 0
        ? (widget.project.totalExpenses / projectTotalPrice).clamp(0.0, 1.0)
        : null;
    final compact = widget.compact;
    final borderRadius = compact ? 14.0 : 18.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        scale: _hovered ? 1.012 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              children: [
                const Positioned.fill(child: ProjectListItemCardBaseGradient()),
                Positioned(
                  top: -70,
                  right: -55,
                  child: ProjectListItemGlowOrb(
                    color: meta.accent,
                    size: 100,
                    opacity: _hovered ? 0.34 : 0.22,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (widget.enableNavigation) {
                        widget.onNavigate(widget.project);
                      }
                    },
                    borderRadius: BorderRadius.circular(borderRadius),
                    splashColor: meta.accent.withOpacity(0.05),
                    child: Padding(
                      padding: compact
                          ? const EdgeInsets.fromLTRB(11, 10, 8, 9)
                          : const EdgeInsets.fromLTRB(15, 14, 11, 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProjectListItemStatusIconBox(
                                accent: meta.accent,
                                icon: meta.icon,
                                hovered: _hovered,
                                compact: compact,
                              ),
                              SizedBox(width: compact ? 8 : 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ProjectListItemPipelineLabel(
                                      accent: meta.accent,
                                      groupLabel: meta.groupLabel,
                                      compact: compact,
                                    ),
                                    SizedBox(height: compact ? 3 : 5),
                                    Text(
                                      widget.project.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: compact ? 12.5 : null,
                                        height: compact ? 1.15 : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ProjectListItemCardMenu(
                                onEdit: () => widget.onEdit(widget.project),
                                onArchive: widget.showArchiveActions
                                    ? () =>
                                          widget.onArchive?.call(widget.project)
                                    : null,
                                onDelete: widget.showArchiveActions
                                    ? () =>
                                          widget.onDelete?.call(widget.project)
                                    : null,
                                onRestore: widget.showRestoreActions
                                    ? () =>
                                          widget.onRestore?.call(widget.project)
                                    : null,
                                onMoveToExecution:
                                    widget.showStatusActions &&
                                        widget.project.status ==
                                            ProjectStatus.pendingSignature
                                    ? () => widget.onMoveToExecution?.call(
                                        widget.project,
                                      )
                                    : null,
                                compact: compact,
                              ),
                            ],
                          ),
                          SizedBox(height: compact ? 4 : 12),
                          ProjectListItemContactRow(
                            clientName: widget.project.clientName ?? ' --- ',
                            contacts: widget.project.clientContacts,
                            fallbackPhone: widget.project.clientPhone,
                            mapUrl: widget.project.googleMapLink,
                            onCopy: _copy,
                          ),
                          const Spacer(),
                          ProjectListItemProgressSection(
                            dateProgress: dateProgress,
                            receivedProgress: receivedProgress,
                            accentColor: meta.accent,
                            dateInDays: widget.project.deliveryInDays,
                            restInCash: widget.project.restInCash,
                            compact: compact,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusMeta {
  final Color accent;
  final IconData icon;
  final String groupLabel;

  const _StatusMeta({
    required this.accent,
    required this.icon,
    required this.groupLabel,
  });
}

_StatusMeta _metaOf(ProjectStatus status, DateTime? lastEditAt) {
  final daysSinceEdit = lastEditAt != null
      ? DateTime.now().difference(lastEditAt).inDays
      : 0;
  switch (status) {
    case ProjectStatus.underPricing:
      return _StatusMeta(
        accent: daysSinceEdit > 20 ? Colors.red : AppColors.primary,
        icon: Icons.calculate_rounded,
        groupLabel: 'العرض',
      );
    case ProjectStatus.pendingSignature:
      return _StatusMeta(
        accent: daysSinceEdit > 20 ? Colors.red : AppColors.statusOnHold,
        icon: Icons.draw_rounded,
        groupLabel: 'التعاقد',
      );
    case ProjectStatus.execution:
      return _StatusMeta(
        accent: daysSinceEdit > 20 ? Colors.red : AppColors.secondary,
        icon: Icons.rocket_launch_rounded,
        groupLabel: 'التنفيذ',
      );
    case ProjectStatus.completed:
      return _StatusMeta(
        accent: daysSinceEdit > 20 ? Colors.red : AppColors.statusCompleted,
        icon: Icons.verified_rounded,
        groupLabel: 'الإغلاق',
      );
    case ProjectStatus.draft:
      return _StatusMeta(
        accent: daysSinceEdit > 20 ? Colors.red : AppColors.textMuted,
        icon: Icons.folder_rounded,
        groupLabel: 'مسودة',
      );
    default:
      return _StatusMeta(
        accent: daysSinceEdit > 20 ? Colors.red : AppColors.textMuted,
        icon: Icons.folder_rounded,
        groupLabel: 'أخرى',
      );
  }
}

double? _dateProgress(ProjectEntity project) {
  if (!project.hasEndDate) return null;

  final start = DateTime(
    project.startDate.year,
    project.startDate.month,
    project.startDate.day,
  );
  final end = DateTime(
    project.endDate.year,
    project.endDate.month,
    project.endDate.day,
  );
  if (end.isBefore(start)) return null;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final totalDays = math.max(1, end.difference(start).inDays);
  final elapsedDays = today.difference(start).inDays.clamp(0, totalDays);

  return elapsedDays / totalDays;
}

class ProjectsListCenteredLoader extends StatelessWidget {
  const ProjectsListCenteredLoader({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: AppColors.secondary),
  );
}

class ProjectsListBottomLoader extends StatelessWidget {
  const ProjectsListBottomLoader({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(18),
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(color: AppColors.secondary),
      ),
    ),
  );
}

class ProjectsListNoMoreProjects extends StatelessWidget {
  const ProjectsListNoMoreProjects({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class ProjectsListLoadMoreError extends StatelessWidget {
  final VoidCallback onRetry;

  const ProjectsListLoadMoreError({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: onRetry,
      child: const Text('إعادة تحميل المزيد'),
    ),
  );
}

class ProjectsListEmptyState extends StatelessWidget {
  final String message;

  const ProjectsListEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) => Center(child: Text(message));
}

class ProjectsListEmptyFilteredState extends StatelessWidget {
  final VoidCallback onClear;

  const ProjectsListEmptyFilteredState({super.key, required this.onClear});

  @override
  Widget build(BuildContext context) => Center(
    child: OutlinedButton(
      onPressed: onClear,
      child: const Text('عرض كل المشاريع'),
    ),
  );
}

class ProjectsListErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ProjectsListErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
      ],
    ),
  );
}
