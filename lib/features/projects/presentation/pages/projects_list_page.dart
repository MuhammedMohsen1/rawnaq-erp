import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../contracts/data/datasources/contracts_api_datasource.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/enums/project_status.dart';
import '../../domain/enums/project_type.dart';
import '../bloc/projects_bloc.dart';
import '../bloc/projects_event.dart';
import '../bloc/projects_state.dart';
import '../widgets/create_project_dialog.dart';
import '../widgets/edit_project_dialog.dart';
import '../widgets/projects_confirm_action_dialog.dart';
import '../widgets/projects_list_view.dart';

const int _pageSize = 12;
const Set<ProjectStatus> _pricingPipelineStatuses = {
  ProjectStatus.underPricing,
  ProjectStatus.pendingSignature,
};

class ProjectsListPage extends StatefulWidget {
  final String title;
  final String emptyMessage;
  final bool showCreateButton;
  final bool showArchiveActions;
  final bool showRestoreActions;
  final bool showStatusActions;
  final bool enableNavigation;
  final Set<ProjectStatus>? visibleStatuses;
  final bool useDesignStatusLabels;

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
    this.useDesignStatusLabels = false,
  });

  @override
  State<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  ProjectStatus? _selectedStatus;
  String _lastProjectsSignature = '';
  ProjectsLoaded? _lastLoadedState;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

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
    _searchDebounce?.cancel();
    _searchController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectsBloc, ProjectsState>(
      listener: _onProjectsStateChanged,
      builder: (context, state) {
        final authState = context.watch<AuthBloc>().state;
        final isAdmin =
            authState is AuthAuthenticated && authState.user.isAdmin;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: ProjectsListView(
                title: widget.title,
                emptyMessage: widget.emptyMessage,
                showCreateButton: widget.showCreateButton,
                showArchiveActions: widget.showArchiveActions,
                showRestoreActions: widget.showRestoreActions,
                showStatusActions: widget.showStatusActions,
                enableNavigation: widget.enableNavigation,
                visibleStatuses: widget.visibleStatuses,
                useDesignStatusLabels: widget.useDesignStatusLabels,
                selectedStatus: _selectedStatus,
                searchController: _searchController,
                onSearchChanged: _onSearchChanged,
                onClearSearch: _clearSearch,
                onSelectStatus: _selectStatus,
                onCreateTap: widget.showCreateButton
                    ? () => _showCreateDialog(context)
                    : null,
                onRetry: () {
                  _reloadCurrentList(context);
                  _pagingController.refresh();
                },
                loadedState: state is ProjectsLoaded ? state : _lastLoadedState,
                isReloading:
                    state is ProjectsLoading && _lastLoadedState != null,
                pagingController: _pagingController,
                onFetchPage: _fetchPage,
                onNavigate: (project) => _navigate(context, project),
                onEdit: (project) => _showEditDialog(context, project),
                onArchive: widget.showArchiveActions && isAdmin
                    ? (project) =>
                          _showArchiveDialog(context, project.id, project.name)
                    : null,
                onDelete: widget.showArchiveActions && isAdmin
                    ? (project) =>
                          _showDeleteDialog(context, project.id, project.name)
                    : null,
                onRestore: widget.showRestoreActions
                    ? (project) =>
                          _showRestoreDialog(context, project.id, project.name)
                    : null,
                onMoveToExecution: widget.showStatusActions
                    ? (project) =>
                          project.status == ProjectStatus.pendingSignature
                          ? _showMoveToExecutionDialog(context, project)
                          : null
                    : null,
                onClearFilters: () => _selectStatus(null),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onProjectsStateChanged(BuildContext context, ProjectsState state) {
    if (state is! ProjectsLoaded) return;

    _lastLoadedState = state;
    final signature = _signatureOf(state.filteredProjects);
    if (signature == _lastProjectsSignature) return;

    _lastProjectsSignature = signature;
    _pagingController.refresh();
  }

  void _reloadCurrentList(BuildContext context) {
    final state = context.read<ProjectsBloc>().state;
    if (state is ProjectsLoaded) {
      context.read<ProjectsBloc>().add(
        LoadProjects(
          status: state.statusFilter,
          type: state.typeFilter,
          managerId: state.managerFilter,
          teamMemberId: state.teamMemberFilter,
          searchQuery: state.searchQuery,
          archived: state.archived,
          assignedToMe: state.assignedToMe,
          page: 1,
          limit: state.pageSize,
        ),
      );
      return;
    }

    context.read<ProjectsBloc>().add(const LoadProjects());
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<ProjectsBloc>().add(SearchProjects(query));
    });
    setState(() {});
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    context.read<ProjectsBloc>().add(const SearchProjects(''));
    setState(() {});
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

  String _signatureOf(List<ProjectEntity> projects) {
    return projects
        .map(
          (project) =>
              '${project.id}:${project.name}:${project.status.name}:${project.archived}:${project.clientName ?? ''}:${project.clientContacts.length}:${project.googleMapLink ?? ''}:${project.startDate.toIso8601String()}:${project.endDate.toIso8601String()}:${project.hasEndDate}:${project.totalCost}:${project.totalPrice}:${project.totalAmountAfterDeduction}:${project.totalReceived}:${project.totalExpenses}:${project.lastEditAt?.toIso8601String() ?? ''}:${project.teamMembers?.length ?? 0}',
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
    if (project.type == ProjectType.design) {
      context.push(AppRoutes.projectDetails(project.id));
      return;
    }

    if (project.status == ProjectStatus.pendingSignature) {
      context.push(AppRoutes.pricing(project.id, readOnly: project.archived));
      return;
    }

    if (project.status == ProjectStatus.underPricing) {
      context.push(AppRoutes.pricing(project.id, readOnly: project.archived));
      return;
    }

    if (project.status == ProjectStatus.execution ||
        project.status == ProjectStatus.completed) {
      if (project.archived) {
        context.push(AppRoutes.projectDetails(project.id));
      } else {
        context.push(AppRoutes.execution(project.id));
      }
      return;
    }

    context.push(AppRoutes.projectDetails(project.id));
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
        return ProjectsConfirmActionDialog(
          icon: Icons.archive_outlined,
          iconColor: Colors.orange,
          title: 'تأكيد أرشفة المشروع',
          message:
              'هل تريد أرشفة "$name"؟ سيتم إخفاؤه من القوائم النشطة ويمكن استعادته لاحقًا.',
          confirmLabel: 'أرشفة المشروع',
          onConfirm: () => context.read<ProjectsBloc>().add(DeleteProject(id)),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (_) {
        return ProjectsConfirmActionDialog(
          icon: Icons.delete_outline_rounded,
          iconColor: Colors.red,
          title: 'تأكيد حذف المشروع',
          message:
              'هل تريد حذف "$name"؟ سيتم نقله إلى المحذوفات وإخفاء المشروع والتسعير المرتبط به من القوائم النشطة.',
          confirmLabel: 'حذف المشروع',
          onConfirm: () => context.read<ProjectsBloc>().add(DeleteProject(id)),
        );
      },
    );
  }

  void _showRestoreDialog(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (_) {
        return ProjectsConfirmActionDialog(
          icon: Icons.unarchive_outlined,
          iconColor: Colors.green,
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
        return ProjectsConfirmActionDialog(
          icon: Icons.play_circle_outline_rounded,
          iconColor: Colors.green,
          title: 'بدء التنفيذ',
          message: 'هل تريد نقل "${project.name}" إلى مرحلة التنفيذ؟',
          confirmLabel: 'بدء التنفيذ',
          onConfirm: () {
            _confirmPendingSignatureProject(context, project);
          },
        );
      },
    );
  }

  Future<void> _confirmPendingSignatureProject(
    BuildContext context,
    ProjectEntity project,
  ) async {
    try {
      if (project.type == ProjectType.design) {
        if (!context.mounted) return;
        context.push(AppRoutes.projectDetails(project.id));
        return;
      }

      if (project.status == ProjectStatus.pendingSignature) {
        if (!context.mounted) return;
        context.push(AppRoutes.pricing(project.id, readOnly: project.archived));
        return;
      }

      await ContractsApiDataSource().confirmContract(project.id);

      if (!context.mounted) return;

      context.read<ProjectsBloc>().add(const RefreshProjects());
      context.push(
        project.type == ProjectType.design
            ? AppRoutes.projectDetails(project.id)
            : AppRoutes.execution(project.id),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نقل المشروع إلى مرحلة التنفيذ بنجاح.'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل نقل المشروع إلى التنفيذ: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
