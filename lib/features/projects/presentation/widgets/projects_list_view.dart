import 'dart:async';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/enums/project_status.dart';
import '../bloc/projects_state.dart';
import 'project_list_header.dart';
import 'project_list_item_card.dart';

const List<ProjectStatus> _statusOrder = [
  ProjectStatus.underPricing,
  ProjectStatus.execution,
  ProjectStatus.completed,
];

const Set<ProjectStatus> _pricingPipelineStatuses = {
  ProjectStatus.underPricing,
  ProjectStatus.pendingSignature,
};

class ProjectsListView extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final bool showCreateButton;
  final bool showArchiveActions;
  final bool showRestoreActions;
  final bool showStatusActions;
  final bool enableNavigation;
  final Set<ProjectStatus>? visibleStatuses;
  final bool useDesignStatusLabels;
  final ProjectStatus? selectedStatus;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<ProjectStatus?> onSelectStatus;
  final VoidCallback? onCreateTap;
  final VoidCallback onRetry;
  final ProjectsLoaded? loadedState;
  final bool isReloading;
  final PagingController<int, ProjectEntity> pagingController;
  final Future<List<ProjectEntity>> Function(int offset) onFetchPage;
  final ValueChanged<ProjectEntity> onNavigate;
  final ValueChanged<ProjectEntity> onEdit;
  final ValueChanged<ProjectEntity>? onArchive;
  final ValueChanged<ProjectEntity>? onDelete;
  final ValueChanged<ProjectEntity>? onRestore;
  final ValueChanged<ProjectEntity>? onMoveToExecution;
  final VoidCallback onClearFilters;

  const ProjectsListView({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.showCreateButton,
    required this.showArchiveActions,
    required this.showRestoreActions,
    required this.showStatusActions,
    required this.enableNavigation,
    required this.visibleStatuses,
    required this.useDesignStatusLabels,
    required this.selectedStatus,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onSelectStatus,
    required this.onCreateTap,
    required this.onRetry,
    required this.loadedState,
    required this.isReloading,
    required this.pagingController,
    required this.onFetchPage,
    required this.onNavigate,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
    required this.onRestore,
    required this.onMoveToExecution,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final state = loadedState;
    if (state == null) return const SizedBox.shrink();

    final allProjects = _applyVisibleStatusFilter(state.filteredProjects);
    final counts = _countByStatus(allProjects);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
        ],
        ProjectListSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          onClear: onClearSearch,
        ),
        const SizedBox(height: 14),
        ProjectListStatusFilterBar(
          selectedStatus: selectedStatus,
          totalCount: allProjects.length,
          counts: counts,
          availableStatuses: _availableStatuses(counts),
          useDesignStatusLabels: useDesignStatusLabels,
          onSelected: onSelectStatus,
          onCreateTap: onCreateTap,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: isReloading
              ? const ProjectsListCenteredLoader()
              : allProjects.isEmpty
              ? ProjectsListEmptyState(message: emptyMessage)
              : _PagedProjectsGrid(
                  pagingController: pagingController,
                  onFetchPage: onFetchPage,
                  onRetry: onRetry,
                  onNavigate: onNavigate,
                  onEdit: onEdit,
                  onArchive: onArchive,
                  onDelete: onDelete,
                  onRestore: onRestore,
                  onMoveToExecution: onMoveToExecution,
                  onClearFilters: onClearFilters,
                  enableNavigation: enableNavigation,
                  showArchiveActions: showArchiveActions,
                  showRestoreActions: showRestoreActions,
                  showStatusActions: showStatusActions,
                ),
        ),
      ],
    );
  }

  List<ProjectEntity> _applyVisibleStatusFilter(List<ProjectEntity> projects) {
    final statuses = visibleStatuses;
    if (statuses == null || statuses.isEmpty) return projects;
    return projects
        .where((project) => statuses.contains(project.status))
        .toList();
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
    final allowed = visibleStatuses;
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
}

class _PagedProjectsGrid extends StatelessWidget {
  final PagingController<int, ProjectEntity> pagingController;
  final Future<List<ProjectEntity>> Function(int offset) onFetchPage;
  final VoidCallback onRetry;
  final ValueChanged<ProjectEntity> onNavigate;
  final ValueChanged<ProjectEntity> onEdit;
  final ValueChanged<ProjectEntity>? onArchive;
  final ValueChanged<ProjectEntity>? onDelete;
  final ValueChanged<ProjectEntity>? onRestore;
  final ValueChanged<ProjectEntity>? onMoveToExecution;
  final bool enableNavigation;
  final bool showArchiveActions;
  final bool showRestoreActions;
  final bool showStatusActions;
  final VoidCallback onClearFilters;

  const _PagedProjectsGrid({
    required this.pagingController,
    required this.onFetchPage,
    required this.onRetry,
    required this.onNavigate,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
    required this.onRestore,
    required this.onMoveToExecution,
    required this.enableNavigation,
    required this.showArchiveActions,
    required this.showRestoreActions,
    required this.showStatusActions,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxWidth < 680 || ResponsiveLayout.isMobile(context);
        final maxExtent = isCompact ? constraints.maxWidth : 390.0;
        final cardHeight = isCompact ? 158.0 : 190.0;

        return PagingListener<int, ProjectEntity>(
          controller: pagingController,
          builder: (context, pagingState, fetchNextPage) {
            return RefreshIndicator(
              color: AppColors.secondary,
              backgroundColor: AppColors.cardBackground,
              onRefresh: () async {
                onRetry();
                pagingController.refresh();
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
                      const ProjectsListCenteredLoader(),
                  newPageProgressIndicatorBuilder: (_) =>
                      const ProjectsListBottomLoader(),
                  firstPageErrorIndicatorBuilder: (_) => ProjectsListErrorState(
                    message: 'تعذر تحميل المشاريع',
                    onRetry: pagingController.refresh,
                  ),
                  newPageErrorIndicatorBuilder: (_) =>
                      ProjectsListLoadMoreError(onRetry: fetchNextPage),
                  noItemsFoundIndicatorBuilder: (_) =>
                      ProjectsListEmptyFilteredState(onClear: onClearFilters),
                  noMoreItemsIndicatorBuilder: (_) =>
                      const ProjectsListNoMoreProjects(),
                  itemBuilder: (context, project, index) => ProjectListItemCard(
                    project: project,
                    compact: isCompact,
                    enableNavigation: enableNavigation,
                    showArchiveActions: showArchiveActions,
                    showRestoreActions: showRestoreActions,
                    showStatusActions: showStatusActions,
                    onNavigate: onNavigate,
                    onEdit: onEdit,
                    onArchive: onArchive,
                    onDelete: onDelete,
                    onRestore: onRestore,
                    onMoveToExecution: onMoveToExecution,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
