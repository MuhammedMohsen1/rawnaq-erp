import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/enums/project_status.dart';
import '../bloc/projects_bloc.dart';
import '../bloc/projects_event.dart';
import '../bloc/projects_state.dart';
import '../widgets/create_project_dialog.dart';
import '../widgets/edit_project_dialog.dart';

// ─── Status meta (uses AppColors exactly) ──────────────────────────────────────

class _StatusMeta {
  final String label;
  final Color accent; // solid accent from AppColors
  final IconData icon;

  const _StatusMeta({
    required this.label,
    required this.accent,
    required this.icon,
  });
}

const _statusOrder = [
  ProjectStatus.execution,
  ProjectStatus.underPricing,
  ProjectStatus.pendingSignature,
  ProjectStatus.completed,
];

// Map each status → its AppColors accent
const _metaMap = <ProjectStatus, _StatusMeta>{
  ProjectStatus.execution: _StatusMeta(
    label: 'قيد التنفيذ',
    accent: AppColors.statusCompleted, // #22C55E green
    icon: Icons.rocket_launch_rounded,
  ),
  ProjectStatus.underPricing: _StatusMeta(
    label: 'قيد التسعير',
    accent: AppColors.secondary, // #3B82F6 blue
    icon: Icons.calculate_rounded,
  ),
  ProjectStatus.pendingSignature: _StatusMeta(
    label: 'في انتظار التوقيع',
    accent: AppColors.statusOnHold, // #F59E0B amber
    icon: Icons.draw_rounded,
  ),
  ProjectStatus.completed: _StatusMeta(
    label: 'مكتمل',
    accent: AppColors.statusCompleted,
    icon: Icons.verified_rounded,
  ),
};

_StatusMeta _metaOf(ProjectStatus s) =>
    _metaMap[s] ??
    const _StatusMeta(
      label: 'أخرى',
      accent: AppColors.textMuted,
      icon: Icons.folder_rounded,
    );

// ─── Page ──────────────────────────────────────────────────────────────────────

class ProjectsListPage extends StatefulWidget {
  final String title;
  final String emptyMessage;
  final bool showCreateButton;
  final bool showArchiveActions;
  final bool showRestoreActions;
  final bool showStatusActions;
  final bool enableNavigation;

  const ProjectsListPage({
    super.key,
    this.title = 'المشاريع',
    this.emptyMessage = 'لا توجد مشاريع',
    this.showCreateButton = true,
    this.showArchiveActions = true,
    this.showRestoreActions = false,
    this.showStatusActions = true,
    this.enableNavigation = true,
  });
  @override
  State<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  // All accordions start expanded
  final Set<ProjectStatus> _open = {..._statusOrder};
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 360) {
      context.read<ProjectsBloc>().add(const LoadMoreProjects());
    }
  }

  Map<ProjectStatus, List<ProjectEntity>> _group(List<ProjectEntity> list) {
    final map = <ProjectStatus, List<ProjectEntity>>{};
    for (final s in _statusOrder) {
      final items = list.where((p) => p.status == s).toList();
      if (items.isNotEmpty) map[s] = items;
    }
    // Catch unlisted statuses
    for (final p in list) {
      if (!_statusOrder.contains(p.status)) (map[p.status] ??= []).add(p);
    }
    return map;
  }

  void _toggle(ProjectStatus s) =>
      setState(() => _open.contains(s) ? _open.remove(s) : _open.add(s));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsBloc, ProjectsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  title: widget.title,
                  onCreateTap: widget.showCreateButton
                      ? () => _showCreate(context)
                      : null,
                ),
                const SizedBox(height: 24),
                Expanded(child: _body(context, state)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Content ──────────────────────────────────────────────────────────────────

  Widget _body(BuildContext context, ProjectsState state) {
    if (state is ProjectsLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.secondary,
          strokeWidth: 2,
        ),
      );
    }

    if (state is ProjectsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: AppColors.error,
            ),
            const SizedBox(height: 14),
            Text(
              state.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            _GhostButton(
              label: 'إعادة المحاولة',
              accent: AppColors.secondary,
              onTap: () =>
                  context.read<ProjectsBloc>().add(const LoadProjects()),
            ),
          ],
        ),
      );
    }

    if (state is ProjectsLoaded) {
      final grouped = _group(state.filteredProjects);
      if (grouped.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.folder_open_rounded,
                size: 64,
                color: AppColors.textDisabled,
              ),
              const SizedBox(height: 16),
              Text(
                widget.emptyMessage,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        controller: _scrollController,
        itemCount: grouped.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          if (i >= grouped.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.secondary,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          final status = grouped.keys.elementAt(i);
          final projects = grouped[status]!;
          final meta = _metaOf(status);
          return _Accordion(
            meta: meta,
            count: projects.length,
            isOpen: _open.contains(status),
            onToggle: () => _toggle(status),
            child: _CardGrid(
              projects: projects,
              meta: meta,
              onTap: (p) {
                if (widget.enableNavigation) _navigate(context, p);
              },
              onEdit: (p) => _showEdit(context, p),
              onArchive: widget.showArchiveActions
                  ? (p) => _showArchive(context, p.id, p.name)
                  : null,
              onRestore: widget.showRestoreActions
                  ? (p) => _showRestore(context, p.id, p.name)
                  : null,
              onMoveToExecution: widget.showStatusActions
                  ? (p) => _showMoveToExecution(context, p)
                  : null,
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _navigate(BuildContext context, ProjectEntity p) {
    if (p.status == ProjectStatus.underPricing ||
        p.status == ProjectStatus.pendingSignature) {
      context.go(AppRoutes.pricing(p.id, readOnly: p.archived));
    } else if (p.status == ProjectStatus.execution) {
      if (p.archived) {
        context.go(AppRoutes.projectDetails(p.id));
      } else {
        context.go(AppRoutes.execution(p.id));
      }
    } else {
      context.go(AppRoutes.projectDetails(p.id));
    }
  }

  void _showCreate(BuildContext context) {
    final bloc = context.read<ProjectsBloc>();
    showDialog(
      context: context,
      builder: (_) =>
          BlocProvider.value(value: bloc, child: const CreateProjectDialog()),
    );
  }

  void _showEdit(BuildContext context, ProjectEntity p) {
    final bloc = context.read<ProjectsBloc>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: EditProjectDialog(project: p),
      ),
    );
  }

  void _showArchive(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmActionDialog(
        icon: Icons.archive_outlined,
        iconColor: AppColors.error,
        title: 'تأكيد الأرشفة',
        message:
            'هل تريد أرشفة "$name"؟ سيتم إخفاء المشروع والتسعير المرتبط به من القوائم النشطة.',
        confirmLabel: 'أرشفة',
        onConfirm: () => context.read<ProjectsBloc>().add(DeleteProject(id)),
      ),
    );
  }

  void _showRestore(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmActionDialog(
        icon: Icons.unarchive_outlined,
        iconColor: AppColors.statusCompleted,
        title: 'استعادة المشروع',
        message: 'هل تريد استعادة "$name" وإعادته إلى قوائم المشاريع النشطة؟',
        confirmLabel: 'استعادة',
        onConfirm: () => context.read<ProjectsBloc>().add(RestoreProject(id)),
      ),
    );
  }

  void _showMoveToExecution(BuildContext context, ProjectEntity project) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmActionDialog(
        icon: Icons.play_circle_outline_rounded,
        iconColor: AppColors.statusCompleted,
        title: 'بدء التنفيذ',
        message: 'هل تريد نقل "${project.name}" إلى مرحلة التنفيذ؟',
        confirmLabel: 'بدء التنفيذ',
        onConfirm: () => context.read<ProjectsBloc>().add(
          UpdateProjectStatus(
            projectId: project.id,
            status: ProjectStatus.execution,
            notes: 'Started execution from pending signature',
          ),
        ),
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback? onCreateTap;
  const _Header({required this.title, this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Page title
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.pageTitle),
            const SizedBox(height: 3),
            Text(
              'مُصنَّفة حسب الحالة',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),

        const Spacer(),

        // Create button
        if (onCreateTap != null)
          ElevatedButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text('إنشاء مشروع جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0,
            ),
          ),
      ],
    );
  }
}

// ─── Accordion ─────────────────────────────────────────────────────────────────

class _Accordion extends StatefulWidget {
  final _StatusMeta meta;
  final int count;
  final bool isOpen;
  final VoidCallback onToggle;
  final Widget child;

  const _Accordion({
    required this.meta,
    required this.count,
    required this.isOpen,
    required this.onToggle,
    required this.child,
  });

  @override
  State<_Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<_Accordion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _expand;
  late final Animation<double> _chevron;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: widget.isOpen ? 1.0 : 0.0,
    );
    _expand = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _chevron = Tween(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_Accordion old) {
    super.didUpdateWidget(old);
    if (widget.isOpen != old.isOpen) {
      widget.isOpen ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // ── Accordion header ──────────────────────────────────────────
          GestureDetector(
            onTap: widget.onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  // Glowing status dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.meta.accent,
                      boxShadow: [
                        BoxShadow(
                          color: widget.meta.accent.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 11),

                  // Icon
                  Icon(widget.meta.icon, size: 15, color: widget.meta.accent),
                  const SizedBox(width: 8),

                  // Label
                  Text(
                    widget.meta.label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Count pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: widget.meta.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.meta.accent.withOpacity(0.22),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${widget.count}',
                      style: TextStyle(
                        color: widget.meta.accent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Animated chevron
                  RotationTransition(
                    turns: _chevron,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider (only visible when expanded)
          AnimatedBuilder(
            animation: _expand,
            builder: (_, __) => _expand.value > 0.05
                ? const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  )
                : const SizedBox.shrink(),
          ),

          // ── Expandable content ────────────────────────────────────────
          SizeTransition(
            sizeFactor: _expand,
            child: FadeTransition(
              opacity: _expand,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card grid ─────────────────────────────────────────────────────────────────

class _CardGrid extends StatelessWidget {
  final List<ProjectEntity> projects;
  final _StatusMeta meta;
  final void Function(ProjectEntity) onTap;
  final void Function(ProjectEntity) onEdit;
  final void Function(ProjectEntity)? onArchive;
  final void Function(ProjectEntity)? onRestore;
  final void Function(ProjectEntity)? onMoveToExecution;

  const _CardGrid({
    required this.projects,
    required this.meta,
    required this.onTap,
    required this.onEdit,
    this.onArchive,
    this.onRestore,
    this.onMoveToExecution,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,
        childAspectRatio: 1.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: projects.length,
      itemBuilder: (_, i) => _ProjectCard(
        project: projects[i],
        meta: meta,
        onTap: () => onTap(projects[i]),
        onEdit: () => onEdit(projects[i]),
        onArchive: onArchive == null ? null : () => onArchive!(projects[i]),
        onRestore: onRestore == null ? null : () => onRestore!(projects[i]),
        onMoveToExecution:
            onMoveToExecution == null ||
                projects[i].status != ProjectStatus.pendingSignature
            ? null
            : () => onMoveToExecution!(projects[i]),
      ),
    );
  }
}

// ─── Project card ──────────────────────────────────────────────────────────────
//
//  The gradient lives IN the card background:
//    top-left corner → accent @ 10% opacity
//    fading into AppColors.surfaceColor by bottom-right
//
// ──────────────────────────────────────────────────────────────────────────────

class _ProjectCard extends StatefulWidget {
  final ProjectEntity project;
  final _StatusMeta meta;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onRestore;
  final VoidCallback? onMoveToExecution;

  const _ProjectCard({
    required this.project,
    required this.meta,
    required this.onTap,
    required this.onEdit,
    this.onArchive,
    this.onRestore,
    this.onMoveToExecution,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.meta.accent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? accent.withOpacity(0.35) : AppColors.border,
              width: 1,
            ),
            // ── Gradient IS the background of the card ─────────────────
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                // accent tint bleeds in from top-left
                accent.withOpacity(_hovered ? 0.13 : 0.08),
                // settles back to the app's surface color
                AppColors.surfaceColor,
              ],
              stops: const [0.0, 0.65],
            ),
            // ─────────────────────────────────────────────────────────────
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row + overflow menu ───────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.project.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _CardMenu(
                      onEdit: widget.onEdit,
                      onArchive: widget.onArchive,
                      onRestore: widget.onRestore,
                      onMoveToExecution: widget.onMoveToExecution,
                    ),
                  ],
                ),

                const Spacer(),

                // ── Manager ────────────────────────────────────────────
                if (widget.project.clientName != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 11,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          widget.project.clientName!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // ── Team count + status badge ──────────────────────────
                Row(
                  children: [
                    if (widget.project.teamMembers?.length != null) ...[
                      const Icon(
                        Icons.group_outlined,
                        size: 11,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.project.teamMembers!.length} أعضاء',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: accent.withOpacity(0.22),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.meta.label,
                        style: TextStyle(
                          color: accent,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Card overflow menu ─────────────────────────────────────────────────────────

class _CardMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onRestore;
  final VoidCallback? onMoveToExecution;
  const _CardMenu({
    required this.onEdit,
    this.onArchive,
    this.onRestore,
    this.onMoveToExecution,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(
        Icons.more_horiz_rounded,
        size: 17,
        color: AppColors.textMuted,
      ),
      color: AppColors.cardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      itemBuilder: (_) => [
        if (onRestore == null)
          PopupMenuItem(
            value: 'edit',
            height: 36,
            child: Row(
              children: const [
                Icon(
                  Icons.edit_outlined,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8),
                Text(
                  'تعديل',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        if (onRestore != null)
          PopupMenuItem(
            value: 'restore',
            height: 36,
            child: Row(
              children: const [
                Icon(
                  Icons.unarchive_outlined,
                  size: 13,
                  color: AppColors.statusCompleted,
                ),
                SizedBox(width: 8),
                Text(
                  'استعادة',
                  style: TextStyle(
                    color: AppColors.statusCompleted,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        if (onMoveToExecution != null)
          PopupMenuItem(
            value: 'execution',
            height: 36,
            child: Row(
              children: const [
                Icon(
                  Icons.play_circle_outline_rounded,
                  size: 13,
                  color: AppColors.statusCompleted,
                ),
                SizedBox(width: 8),
                Text(
                  'بدء التنفيذ',
                  style: TextStyle(
                    color: AppColors.statusCompleted,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        if (onArchive != null)
          PopupMenuItem(
            value: 'archive',
            height: 36,
            child: Row(
              children: const [
                Icon(Icons.archive_outlined, size: 13, color: AppColors.error),
                SizedBox(width: 8),
                Text(
                  'أرشفة',
                  style: TextStyle(color: AppColors.error, fontSize: 12.5),
                ),
              ],
            ),
          ),
      ],
      onSelected: (v) {
        if (v == 'edit') onEdit();
        if (v == 'archive') onArchive?.call();
        if (v == 'restore') onRestore?.call();
        if (v == 'execution') onMoveToExecution?.call();
      },
    );
  }
}

// ─── Delete confirmation dialog ─────────────────────────────────────────────────

class _ConfirmActionDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;
  const _ConfirmActionDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + title
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor.withOpacity(0.12),
                      foregroundColor: iconColor,
                      side: BorderSide(color: iconColor.withOpacity(0.30)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ghost button (error state retry) ─────────────────────────────────────────

class _GhostButton extends StatelessWidget {
  final String label;
  final Color accent;
  final VoidCallback onTap;
  const _GhostButton({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accent.withOpacity(0.25)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: accent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
