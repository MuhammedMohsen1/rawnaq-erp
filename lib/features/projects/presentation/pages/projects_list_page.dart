import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
import '../widgets/project_contact_actions.dart';

const int _pageSize = 12;
const Duration _fastAnimation = Duration(milliseconds: 160);
const Duration _normalAnimation = Duration(milliseconds: 220);

class _StatusMeta {
  final String label;
  final String shortLabel;
  final String groupLabel;
  final String description;
  final Color accent;
  final IconData icon;

  const _StatusMeta({
    required this.label,
    required this.shortLabel,
    required this.groupLabel,
    required this.description,
    required this.accent,
    required this.icon,
  });
  _StatusMeta copyWith({
    String? label,
    String? shortLabel,
    String? groupLabel,
    String? description,
    Color? accent,
    IconData? icon,
  }) {
    return _StatusMeta(
      label: label ?? this.label,
      shortLabel: shortLabel ?? this.shortLabel,
      groupLabel: groupLabel ?? this.groupLabel,
      description: description ?? this.description,
      accent: accent ?? this.accent,
      icon: icon ?? this.icon,
    );
  }
}

const List<ProjectStatus> _statusOrder = [
  ProjectStatus.underPricing,
  ProjectStatus.execution,
  ProjectStatus.completed,
];

const Set<ProjectStatus> _pricingPipelineStatuses = {
  ProjectStatus.underPricing,
  ProjectStatus.pendingSignature,
};

const Map<ProjectStatus, _StatusMeta> _statusMeta =
    <ProjectStatus, _StatusMeta>{
      ProjectStatus.underPricing: _StatusMeta(
        label: 'التسعير والتوقيع',
        shortLabel: 'تسعير',
        groupLabel: 'العرض',
        description: 'تجهيز العرض أو انتظار توقيع العميل',
        accent: AppColors.primary,
        icon: Icons.calculate_rounded,
      ),
      ProjectStatus.pendingSignature: _StatusMeta(
        label: 'بانتظار التوقيع',
        shortLabel: 'توقيع',
        groupLabel: 'التعاقد',
        description: 'العرض جاهز وينتظر اعتماد العميل',
        accent: AppColors.statusOnHold,
        icon: Icons.draw_rounded,
      ),
      ProjectStatus.execution: _StatusMeta(
        label: 'قيد التنفيذ',
        shortLabel: 'تنفيذ',
        groupLabel: 'التنفيذ',
        description: 'متابعة الأعمال والتوريدات والتسليمات',
        accent: AppColors.secondary,
        icon: Icons.rocket_launch_rounded,
      ),
      ProjectStatus.completed: _StatusMeta(
        label: 'مكتمل',
        shortLabel: 'مكتمل',
        groupLabel: 'الإغلاق',
        description: 'مشروع منتهي وجاهز للمراجعة',
        accent: AppColors.statusCompleted,
        icon: Icons.verified_rounded,
      ),
    };

_StatusMeta _metaOf(ProjectStatus status, DateTime? lastEditAt) {
  int daysSinceEdit = lastEditAt != null
      ? DateTime.now().difference(lastEditAt).inDays
      : 0;
  return _statusMeta[status]?.copyWith(
        accent: daysSinceEdit > 20 ? Colors.red : null,
      ) ??
      const _StatusMeta(
        label: 'أخرى',
        shortLabel: 'أخرى',
        groupLabel: 'غير مصنف',
        description: 'مرحلة غير معرفة',
        accent: AppColors.textMuted,
        icon: Icons.folder_rounded,
      );
}

class ProjectsListPage extends StatefulWidget {
  final String title;
  final String emptyMessage;
  final bool showCreateButton;
  final bool showArchiveActions;
  final bool showRestoreActions;
  final bool showStatusActions;
  final bool enableNavigation;
  final Set<ProjectStatus>? visibleStatuses;

  const ProjectsListPage({
    super.key,
    this.title = 'المشاريع',
    this.emptyMessage = 'لا توجد مشاريع',
    this.showCreateButton = true,
    this.showArchiveActions = true,
    this.showRestoreActions = false,
    this.showStatusActions = true,
    this.enableNavigation = true,
    this.visibleStatuses,
  });

  @override
  State<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  ProjectStatus? _selectedStatus;
  String _lastProjectsSignature = '';

  late final PagingController<int, ProjectEntity> _pagingController =
      PagingController<int, ProjectEntity>(
        getNextPageKey: (state) {
          if (state.lastPageIsEmpty) return null;
          return state.items?.length ?? 0;
        },
        fetchPage: _fetchPage,
      );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectsBloc, ProjectsState>(
      listener: _onProjectsStateChanged,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: _buildBody(context, state),
            ),
          ),
        );
      },
    );
  }

  void _onProjectsStateChanged(BuildContext context, ProjectsState state) {
    if (state is! ProjectsLoaded) return;

    final signature = _signatureOf(state.filteredProjects);
    if (signature == _lastProjectsSignature) return;

    _lastProjectsSignature = signature;

    if (!_pagingController.isLoading) {
      _pagingController.refresh();
    }
  }

  Widget _buildBody(BuildContext context, ProjectsState state) {
    if (state is ProjectsLoading) {
      return const _CenteredLoader();
    }

    if (state is ProjectsError) {
      return _ErrorState(
        message: state.message,
        onRetry: () {
          context.read<ProjectsBloc>().add(const LoadProjects());
          _pagingController.refresh();
        },
      );
    }

    if (state is! ProjectsLoaded) {
      return const SizedBox.shrink();
    }

    final allProjects = _applyVisibleStatusFilter(state.filteredProjects);

    if (allProjects.isEmpty) {
      return _EmptyState(message: widget.emptyMessage);
    }

    final counts = _countByStatus(allProjects);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.isNotEmpty) ...[
          Text(
            widget.title,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
        ],
        _StatusFilterBar(
          selectedStatus: _selectedStatus,
          totalCount: allProjects.length,
          counts: counts,
          availableStatuses: _availableStatuses(counts),
          onSelected: _selectStatus,
          onCreateTap: widget.showCreateButton
              ? () => _showCreateDialog(context)
              : null,
        ),
        const SizedBox(height: 16),

        Expanded(child: _buildPagedGrid()),
      ],
    );
  }

  Widget _buildPagedGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 680;
        final maxExtent = isCompact ? constraints.maxWidth : 390.0;
        final cardHeight = isCompact ? 226.0 : 190.0;

        return PagingListener<int, ProjectEntity>(
          controller: _pagingController,
          builder: (context, pagingState, fetchNextPage) {
            return RefreshIndicator(
              color: AppColors.secondary,
              backgroundColor: AppColors.cardBackground,
              onRefresh: () async {
                context.read<ProjectsBloc>().add(const LoadProjects());
                _pagingController.refresh();
              },
              child: PagedGridView<int, ProjectEntity>(
                clipBehavior: Clip.none,
                state: pagingState,
                fetchNextPage: fetchNextPage,
                padding: const EdgeInsets.only(bottom: 28),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxExtent,
                  mainAxisExtent: cardHeight,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                builderDelegate: PagedChildBuilderDelegate<ProjectEntity>(
                  invisibleItemsThreshold: 4,
                  firstPageProgressIndicatorBuilder: (_) =>
                      const _CenteredLoader(),
                  newPageProgressIndicatorBuilder: (_) => const _BottomLoader(),
                  firstPageErrorIndicatorBuilder: (_) => _ErrorState(
                    message: 'تعذر تحميل المشاريع',
                    onRetry: _pagingController.refresh,
                  ),
                  newPageErrorIndicatorBuilder: (_) =>
                      _LoadMoreError(onRetry: fetchNextPage),
                  noItemsFoundIndicatorBuilder: (_) =>
                      _EmptyFilteredState(onClear: () => _selectStatus(null)),
                  noMoreItemsIndicatorBuilder: (_) => const _NoMoreProjects(),
                  itemBuilder: (context, project, index) {
                    return _ProjectCard(
                      project: project,
                      onTap: () {
                        if (widget.enableNavigation) {
                          _navigate(context, project);
                        }
                      },
                      onEdit: () => _showEditDialog(context, project),
                      onArchive: widget.showArchiveActions
                          ? () => _showArchiveDialog(
                              context,
                              project.id,
                              project.name,
                            )
                          : null,
                      onRestore: widget.showRestoreActions
                          ? () => _showRestoreDialog(
                              context,
                              project.id,
                              project.name,
                            )
                          : null,
                      onMoveToExecution:
                          widget.showStatusActions &&
                              project.status == ProjectStatus.pendingSignature
                          ? () => _showMoveToExecutionDialog(context, project)
                          : null,
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<ProjectEntity> _currentFilteredProjects() {
    final state = context.read<ProjectsBloc>().state;
    if (state is! ProjectsLoaded) return const <ProjectEntity>[];
    return _applyStatusFilter(
      _applyVisibleStatusFilter(state.filteredProjects),
    );
  }

  List<ProjectEntity> _applyVisibleStatusFilter(List<ProjectEntity> projects) {
    final visibleStatuses = widget.visibleStatuses;
    if (visibleStatuses == null || visibleStatuses.isEmpty) return projects;

    return projects
        .where((project) => visibleStatuses.contains(project.status))
        .toList();
  }

  List<ProjectEntity> _applyStatusFilter(List<ProjectEntity> projects) {
    final selectedStatus = _selectedStatus;
    if (selectedStatus == null) return projects;

    if (selectedStatus == ProjectStatus.underPricing) {
      return projects
          .where((project) => _pricingPipelineStatuses.contains(project.status))
          .toList();
    }

    return projects
        .where((project) => project.status == selectedStatus)
        .toList();
  }

  Future<List<ProjectEntity>> _fetchPage(int offset) async {
    var projects = _currentFilteredProjects();

    if (offset < projects.length) {
      return _slicePage(projects, offset);
    }

    final bloc = context.read<ProjectsBloc>();
    final beforeCount = projects.length;
    final currentState = bloc.state;

    if (currentState is ProjectsLoaded && !currentState.isLoadingMore) {
      bloc.add(const LoadMoreProjects());
    }

    try {
      final loadedState = await bloc.stream
          .where((state) => state is ProjectsLoaded)
          .map((state) => state as ProjectsLoaded)
          .firstWhere((state) {
            final updatedCount = _applyStatusFilter(
              _applyVisibleStatusFilter(state.filteredProjects),
            ).length;
            return updatedCount > beforeCount || !state.isLoadingMore;
          })
          .timeout(const Duration(seconds: 1));

      projects = _applyStatusFilter(
        _applyVisibleStatusFilter(loadedState.filteredProjects),
      );
    } on TimeoutException {
      projects = _currentFilteredProjects();
    }

    if (offset >= projects.length) {
      return const <ProjectEntity>[];
    }

    return _slicePage(projects, offset);
  }

  List<ProjectEntity> _slicePage(List<ProjectEntity> projects, int offset) {
    final end = math.min(offset + _pageSize, projects.length);
    return projects.sublist(offset, end);
  }

  Map<ProjectStatus, int> _countByStatus(List<ProjectEntity> projects) {
    final counts = <ProjectStatus, int>{
      for (final status in _statusOrder) status: 0,
    };

    for (final project in projects) {
      if (_pricingPipelineStatuses.contains(project.status)) {
        counts[ProjectStatus.underPricing] =
            (counts[ProjectStatus.underPricing] ?? 0) + 1;
        continue;
      }

      counts[project.status] = (counts[project.status] ?? 0) + 1;
    }

    return counts;
  }

  List<ProjectStatus> _availableStatuses(Map<ProjectStatus, int> counts) {
    final allowed = widget.visibleStatuses;
    final orderedStatuses = [
      ..._statusOrder,
      ...counts.keys.where((status) => !_statusOrder.contains(status)),
    ];

    return orderedStatuses
        .where((status) {
          if (allowed != null && allowed.isNotEmpty) {
            if (status == ProjectStatus.underPricing) {
              return allowed.any(_pricingPipelineStatuses.contains);
            }
            return allowed.contains(status);
          }

          return (counts[status] ?? 0) > 0 || _statusOrder.contains(status);
        })
        .toList(growable: false);
  }

  String _signatureOf(List<ProjectEntity> projects) {
    return projects
        .map(
          (project) =>
              '${project.id}:${project.name}:${project.status.name}:${project.archived}:${project.clientName ?? ''}:${project.clientContacts.length}:${project.googleMapLink ?? ''}:${project.startDate.toIso8601String()}:${project.endDate.toIso8601String()}:${project.hasEndDate}:${project.totalCost}:${project.totalReceived}:${project.lastEditAt?.toIso8601String() ?? ''}:${project.teamMembers?.length ?? 0}',
        )
        .join('|');
  }

  void _selectStatus(ProjectStatus? status) {
    if (_selectedStatus == status) return;

    setState(() {
      _selectedStatus = status;
    });

    _pagingController.refresh();
  }

  void _navigate(BuildContext context, ProjectEntity project) {
    if (project.status == ProjectStatus.underPricing ||
        project.status == ProjectStatus.pendingSignature) {
      context.go(AppRoutes.pricing(project.id, readOnly: project.archived));
      return;
    }

    if (project.status == ProjectStatus.execution) {
      if (project.archived) {
        context.go(AppRoutes.projectDetails(project.id));
      } else {
        context.go(AppRoutes.execution(project.id));
      }
      return;
    }

    context.go(AppRoutes.projectDetails(project.id));
  }

  void _showCreateDialog(BuildContext context) {
    final bloc = context.read<ProjectsBloc>();

    showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: const CreateProjectDialog(),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, ProjectEntity project) {
    final bloc = context.read<ProjectsBloc>();

    showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: EditProjectDialog(project: project),
        );
      },
    );
  }

  void _showArchiveDialog(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (_) {
        return _ConfirmActionDialog(
          icon: Icons.archive_outlined,
          iconColor: AppColors.error,
          title: 'تأكيد الأرشفة',
          message:
              'هل تريد أرشفة "$name"؟ سيتم إخفاء المشروع والتسعير المرتبط به من القوائم النشطة.',
          confirmLabel: 'أرشفة',
          onConfirm: () => context.read<ProjectsBloc>().add(DeleteProject(id)),
        );
      },
    );
  }

  void _showRestoreDialog(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (_) {
        return _ConfirmActionDialog(
          icon: Icons.unarchive_outlined,
          iconColor: AppColors.statusCompleted,
          title: 'استعادة المشروع',
          message: 'هل تريد استعادة "$name" وإعادته إلى قوائم المشاريع النشطة؟',
          confirmLabel: 'استعادة',
          onConfirm: () => context.read<ProjectsBloc>().add(RestoreProject(id)),
        );
      },
    );
  }

  void _showMoveToExecutionDialog(BuildContext context, ProjectEntity project) {
    showDialog(
      context: context,
      builder: (_) {
        return _ConfirmActionDialog(
          icon: Icons.play_circle_outline_rounded,
          iconColor: AppColors.statusCompleted,
          title: 'بدء التنفيذ',
          message: 'هل تريد نقل "${project.name}" إلى مرحلة التنفيذ؟',
          confirmLabel: 'بدء التنفيذ',
          onConfirm: () {
            context.read<ProjectsBloc>().add(
              UpdateProjectStatus(
                projectId: project.id,
                status: ProjectStatus.execution,
                notes: 'Started execution from pending signature',
              ),
            );
          },
        );
      },
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  final ProjectStatus? selectedStatus;
  final int totalCount;
  final Map<ProjectStatus, int> counts;
  final List<ProjectStatus> availableStatuses;
  final ValueChanged<ProjectStatus?> onSelected;
  final VoidCallback? onCreateTap;
  const _StatusFilterBar({
    required this.selectedStatus,
    required this.totalCount,
    required this.counts,
    required this.availableStatuses,
    required this.onSelected,
    this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42, // Slightly tighter height for a cleaner look
      child: Row(
        children: [
          // 1. Expanded allows the list to take up available space without breaking the Row
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              // Adding padding so the glow/shadow isn't clipped
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: 1 + availableStatuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                if (index == 0) {
                  return _StatusFilterChip(
                    label: 'الكل',
                    count: totalCount,
                    icon: Icons.grid_view_rounded,
                    accent: AppColors.primary,
                    selected: selectedStatus == null,
                    onTap: () => onSelected(null),
                  );
                }

                final status = availableStatuses[index - 1];
                final meta = _metaOf(status, null);

                return _StatusFilterChip(
                  label: meta.label,
                  count: counts[status] ?? 0,
                  icon: meta.icon,
                  accent: meta.accent,
                  selected: selectedStatus == status,
                  onTap: () => onSelected(status),
                );
              },
            ),
          ),

          // 2. Space between list and action button
          if (onCreateTap != null) ...[
            const SizedBox(width: 12),
            _PrimaryGlowButton(
              label: 'مشروع جديد', // Shorter text for better UX
              icon: Icons.add_rounded,
              onTap: onCreateTap!, // Fixed: Logic now checks if NOT null
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.count,
    required this.icon,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: _fastAnimation,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? accent.withOpacity(0.12)
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? accent.withOpacity(0.40) : AppColors.border,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.12),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? accent : AppColors.textMuted,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: selected ? accent : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              _CountBubble(count: count, color: accent, active: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBubble extends StatelessWidget {
  final int count;
  final Color color;
  final bool active;

  const _CountBubble({
    required this.count,
    required this.color,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.16) : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? color.withOpacity(0.25) : AppColors.border,
        ),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: active ? color : AppColors.textMuted,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final ProjectEntity project;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onRestore;
  final VoidCallback? onMoveToExecution;

  const _ProjectCard({
    required this.project,
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

  // Helper for copying to clipboard
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
    final action = _resolveAction(widget.project);
    final dateProgress = _dateProgress(widget.project);
    final receivedProgress = widget.project.totalCost > 0
        ? (widget.project.totalReceived / widget.project.totalCost).clamp(
            0.0,
            1.0,
          )
        : null;

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
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                const Positioned.fill(child: _CardBaseGradient()),

                // Top Glow (Using 3-step logic)
                Positioned(
                  top: -70,
                  right: -55,
                  child: _GlowOrb(
                    color: meta.accent,
                    size: 100,
                    opacity: _hovered ? 0.34 : 0.22,
                  ),
                ),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(18),
                    splashColor: meta.accent.withOpacity(0.05),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 14, 11, 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StatusIconBox(meta: meta, hovered: _hovered),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _PipelineLabel(meta: meta),
                                    const SizedBox(height: 5),
                                    Text(
                                      widget.project.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _CardMenu(
                                onEdit: widget.onEdit,
                                onArchive: widget.onArchive,
                                onMoveToExecution: widget.onMoveToExecution,
                                onRestore: widget.onRestore,
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Client & Contact Section
                          _InteractiveContactRow(
                            clientName: widget.project.clientName ?? ' --- ',
                            contacts: widget.project.clientContacts,
                            fallbackPhone: widget.project.clientPhone,
                            mapUrl: widget.project.googleMapLink,
                            onCopy: (String phone, String message) {
                              _copy(phone, message);
                            }, // Placeholder, will be overridden in ProjectContactActions
                          ),

                          const Spacer(),
                          // Progress Section
                          _ProgressSection(
                            dateProgress: dateProgress,
                            receivedProgress: receivedProgress,
                            accentColor: meta.accent,
                            dateInDays: widget.project.deliveryInDays,
                            restInCash: widget.project.restInCash,
                          ),

                          const SizedBox(height: 8),
                          // Divider(
                          //   height: 24,
                          //   color: AppColors.border.withOpacity(0.5),
                          // ),

                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: Text(
                          //         meta.description,
                          //         style: AppTextStyles.bodySmall.copyWith(
                          //           color: AppColors.textMuted,
                          //           fontSize: 11,
                          //         ),
                          //       ),
                          //     ),
                          //     _ActionHint(action: action, color: meta.accent),
                          //   ],
                          // ),
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

String _resolveAction(ProjectEntity project) {
  if (project.status == ProjectStatus.underPricing) {
    return 'فتح التسعير';
  }

  if (project.status == ProjectStatus.pendingSignature) {
    return 'مراجعة التوقيع';
  }

  if (project.status == ProjectStatus.execution) {
    return project.archived ? 'عرض التفاصيل' : 'فتح التنفيذ';
  }

  return 'عرض التفاصيل';
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

class _InteractiveContactRow extends StatelessWidget {
  final String clientName;
  final List<ProjectPhoneContact> contacts;
  final String? fallbackPhone;
  final String? mapUrl;
  final Function(String, String) onCopy;

  const _InteractiveContactRow({
    required this.clientName,
    this.contacts = const [],
    this.fallbackPhone,
    this.mapUrl,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final phones = contacts.isNotEmpty
        ? contacts
        : [
            if ((fallbackPhone ?? '').trim().isNotEmpty)
              ProjectPhoneContact(name: clientName, phone: fallbackPhone!),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                clientName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ProjectContactActions(
              contacts: phones,
              fallbackPhone: fallbackPhone,
              fallbackName: clientName,
              googleMapLink: mapUrl,
              onCopy: (phone, message) => onCopy(phone, message),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final double? dateProgress;
  final double? receivedProgress;
  final int? dateInDays;
  final double? restInCash;
  final Color accentColor;

  const _ProgressSection({
    required this.dateProgress,
    required this.receivedProgress,
    required this.dateInDays,
    required this.restInCash,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (dateProgress == null && receivedProgress == null) {
      return const SizedBox.shrink();
    }

    final safeDateProgress = dateProgress?.clamp(0.0, 1.0).toDouble();
    final safeReceivedProgress = receivedProgress?.clamp(0.0, 1.0).toDouble();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (safeDateProgress != null)
                  _ProgressLegend(label: 'الأيام', color: AppColors.secondary),
                if (safeDateProgress != null && safeReceivedProgress != null)
                  const SizedBox(width: 10),
                if (safeReceivedProgress != null)
                  const _ProgressLegend(
                    label: 'التحصيل',
                    color: Color(0xFF22C55E),
                  ),
              ],
            ),
            Text(
              [
                if (safeDateProgress != null) '$dateInDays يوم',
                if (safeReceivedProgress != null) 'باقي $restInCash\$',
              ].join('  |  '),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _DualProgressTrack(
          dateProgress: safeDateProgress,
          receivedProgress: safeReceivedProgress,
          dateColor: accentColor,
        ),
      ],
    );
  }
}

class _ProgressLegend extends StatelessWidget {
  final String label;
  final Color color;

  const _ProgressLegend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _DualProgressTrack extends StatelessWidget {
  final double? dateProgress;
  final double? receivedProgress;
  final Color dateColor;

  const _DualProgressTrack({
    required this.dateProgress,
    required this.receivedProgress,
    required this.dateColor,
  });

  @override
  Widget build(BuildContext context) {
    final segments =
        [
            if (dateProgress != null)
              _ProgressSegment(
                progress: dateProgress!,
                color: AppColors.secondary,
              ),
            if (receivedProgress != null)
              const _ProgressSegment(
                progress: null,
                color: Color(0xFF22C55E),
                usesReceivedProgress: true,
              ),
          ].map((segment) {
            if (segment.usesReceivedProgress) {
              return _ProgressSegment(
                progress: receivedProgress!,
                color: segment.color,
              );
            }
            return segment;
          }).toList()
          ..sort((a, b) => b.progress.compareTo(a.progress));

    return Container(
      height: 8,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          for (var index = 0; index < segments.length; index++)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: segments[index].progress,
                heightFactor: 1,
                alignment: AlignmentDirectional.centerStart,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: index == 0 && segments.length > 1
                        ? segments[index].color.withOpacity(0.38)
                        : segments[index].color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProgressSegment {
  final double progress;
  final Color color;
  final bool usesReceivedProgress;

  const _ProgressSegment({
    required double? progress,
    required this.color,
    this.usesReceivedProgress = false,
  }) : progress = progress ?? 0;
}

class _CardBaseGradient extends StatelessWidget {
  const _CardBaseGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.surfaceColor,
            AppColors.cardBackground,
            AppColors.scaffoldBackground,
          ],
          stops: const [0, 0.52, 1],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _GlowOrb({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(opacity * 0.26),
              color.withOpacity(0),
            ],
            stops: const [0, 0.45, 1],
          ),
        ),
      ),
    );
  }
}

class _StatusSideGlow extends StatelessWidget {
  final Color color;
  final bool active;

  const _StatusSideGlow({required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedContainer(
        duration: _normalAnimation,
        width: active ? 4 : 3,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0),
              color.withOpacity(active ? 0.72 : 0.44),
              color.withOpacity(0),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(active ? 0.44 : 0.22),
              blurRadius: active ? 16 : 10,
              spreadRadius: active ? 2 : 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIconBox extends StatelessWidget {
  final _StatusMeta meta;
  final bool hovered;

  const _StatusIconBox({required this.meta, required this.hovered});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _normalAnimation,
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: meta.accent.withOpacity(hovered ? 0.16 : 0.11),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: meta.accent.withOpacity(hovered ? 0.34 : 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: meta.accent.withOpacity(hovered ? 0.18 : 0.10),
            blurRadius: hovered ? 22 : 14,
            spreadRadius: hovered ? 1 : 0,
          ),
        ],
      ),
      child: Icon(meta.icon, size: 18, color: meta.accent),
    );
  }
}

class _PipelineLabel extends StatelessWidget {
  final _StatusMeta meta;

  const _PipelineLabel({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.black.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withOpacity(0.80)),
      ),
      child: Text(
        meta.groupLabel,
        style: AppTextStyles.overline.copyWith(
          color: meta.accent,
          fontSize: 9.2,
          letterSpacing: 0,
          height: 1.1,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ArchivedLabel extends StatelessWidget {
  const _ArchivedLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.textMuted.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.textMuted.withOpacity(0.16)),
      ),
      child: Text(
        'مؤرشف',
        style: AppTextStyles.overline.copyWith(
          color: AppColors.textMuted,
          fontSize: 9.2,
          letterSpacing: 0,
          height: 1.1,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ClientLine extends StatelessWidget {
  final ProjectEntity project;

  const _ClientLine({required this.project});

  @override
  Widget build(BuildContext context) {
    final clientName = project.clientName?.trim();
    final hasClient = clientName != null && clientName.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.76)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 14,
            color: hasClient ? AppColors.textMuted : AppColors.textDisabled,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              hasClient ? clientName : 'لا يوجد عميل محدد',
              style: AppTextStyles.bodySmall.copyWith(
                color: hasClient
                    ? AppColors.textSecondary
                    : AppColors.textDisabled,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _StatusMeta meta;

  const _StatusBadge({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: meta.accent.withOpacity(0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: meta.accent.withOpacity(0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 11, color: meta.accent),
          const SizedBox(width: 5),
          Text(
            meta.shortLabel,
            style: AppTextStyles.statusBadge.copyWith(
              color: meta.accent,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SmallPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionHint extends StatelessWidget {
  final String action;
  final Color color;

  const _ActionHint({required this.action, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            action,
            style: TextStyle(
              color: color,
              fontSize: 11.2,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(width: 5),
          Icon(Icons.arrow_forward_rounded, size: 13, color: color),
        ],
      ),
    );
  }
}

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
      tooltip: 'خيارات المشروع',
      padding: EdgeInsets.zero,
      icon: const Icon(
        Icons.more_horiz_rounded,
        size: 19,
        color: AppColors.textMuted,
      ),
      color: AppColors.cardBackground,
      elevation: 8,
      shadowColor: AppColors.black.withOpacity(0.36),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      itemBuilder: (_) {
        return [
          const PopupMenuItem(
            value: 'edit',
            height: 40,
            child: _PopupMenuRow(
              icon: Icons.edit_outlined,
              label: 'تعديل',
              color: AppColors.textSecondary,
            ),
          ),
          if (onRestore != null)
            const PopupMenuItem(
              value: 'restore',
              height: 40,
              child: _PopupMenuRow(
                icon: Icons.unarchive_outlined,
                label: 'استعادة',
                color: AppColors.statusCompleted,
              ),
            ),
          if (onMoveToExecution != null)
            const PopupMenuItem(
              value: 'execution',
              height: 40,
              child: _PopupMenuRow(
                icon: Icons.play_circle_outline_rounded,
                label: 'بدء التنفيذ',
                color: AppColors.statusCompleted,
              ),
            ),
          if (onArchive != null)
            const PopupMenuItem(
              value: 'archive',
              height: 40,
              child: _PopupMenuRow(
                icon: Icons.archive_outlined,
                label: 'أرشفة',
                color: AppColors.error,
              ),
            ),
        ];
      },
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'archive':
            onArchive?.call();
            break;
          case 'restore':
            onRestore?.call();
            break;
          case 'execution':
            onMoveToExecution?.call();
            break;
        }
      },
    );
  }
}

class _PopupMenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PopupMenuRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PrimaryGlowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryGlowButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.buttonSmall.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.secondary,
        strokeWidth: 2,
      ),
    );
  }
}

class _BottomLoader extends StatelessWidget {
  const _BottomLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: AppColors.secondary,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

class _NoMoreProjects extends StatelessWidget {
  const _NoMoreProjects();

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}

class _LoadMoreError extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadMoreError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('إعادة تحميل المزيد'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondary,
            side: BorderSide(color: AppColors.secondary.withOpacity(0.28)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.folder_open_rounded,
              size: 58,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFilteredState extends StatelessWidget {
  final VoidCallback onClear;

  const _EmptyFilteredState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.filter_alt_off_outlined,
            size: 42,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد مشاريع في هذه المرحلة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onClear,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
              side: BorderSide(color: AppColors.secondary.withOpacity(0.28)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('عرض كل المشاريع'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: AppColors.error,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            _GhostButton(
              label: 'إعادة المحاولة',
              accent: AppColors.secondary,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: iconColor.withOpacity(0.18)),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        confirmLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    return Material(
      color: accent.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withOpacity(0.25)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
