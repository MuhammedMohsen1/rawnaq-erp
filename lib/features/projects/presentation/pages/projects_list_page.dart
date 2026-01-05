import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/entities/team_member_entity.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/enums/project_status.dart';
import '../bloc/projects_bloc.dart';
import '../bloc/projects_event.dart';
import '../bloc/projects_state.dart';
import '../widgets/project_filters_widget.dart';
import '../widgets/project_table_widget.dart';
import '../widgets/project_card_widget.dart';
import '../widgets/create_project_dialog.dart';
import '../widgets/edit_project_dialog.dart';

/// Main projects list page with table and card views
class ProjectsListPage extends StatefulWidget {
  const ProjectsListPage({super.key});

  @override
  State<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isTableView = true;
  bool _isSearchVisible = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsBloc, ProjectsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context),
                const SizedBox(height: 24),

                // Search and filters
                Visibility(
                  visible: _isSearchVisible,
                  child: Column(
                    children: [
                      _buildSearchAndFilters(context, state),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // View toggle and pagination info
                _buildViewToggle(context, state),
                const SizedBox(height: 16),

                // Content
                Expanded(child: _buildContent(context, state)),

                // Pagination
                if (state is ProjectsLoaded) _buildPagination(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('قائمة المشاريع', style: AppTextStyles.pageTitle),
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                });
              },
              icon: Icon(
                _isSearchVisible ? Icons.search_off : Icons.search,
                color: AppColors.textSecondary,
              ),
              tooltip: _isSearchVisible ? 'إخفاء البحث' : 'إظهار البحث',
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Show create project dialog
                _showCreateProjectDialog(context);
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('إنشاء مشروع جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, ProjectsState state) {
    final teamMembers = state is ProjectsLoaded
        ? state.teamMembers
        : <TeamMemberEntity>[];
    final statusFilter = state is ProjectsLoaded ? state.statusFilter : null;
    final managerFilter = state is ProjectsLoaded ? state.managerFilter : null;
    final teamMemberFilter = state is ProjectsLoaded
        ? state.teamMemberFilter
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              hintText: 'ابحث عن مشروع بالاسم...',
              hintStyle: AppTextStyles.inputHint,
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        context.read<ProjectsBloc>().add(
                          const SearchProjects(''),
                        );
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.inputFocusBorder,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (value) {
              context.read<ProjectsBloc>().add(SearchProjects(value));
            },
          ),
          const SizedBox(height: 16),

          // Filters
          ProjectFiltersWidget(
            selectedStatus: statusFilter,
            selectedManagerId: managerFilter,
            selectedTeamMemberId: teamMemberFilter,
            teamMembers: teamMembers,
            onStatusChanged: (status) {
              context.read<ProjectsBloc>().add(FilterByStatus(status));
            },
            onManagerChanged: (managerId) {
              context.read<ProjectsBloc>().add(FilterByManager(managerId));
            },
            onTeamMemberChanged: (teamMemberId) {
              context.read<ProjectsBloc>().add(
                FilterByTeamMember(teamMemberId),
              );
            },
            onReset: () {
              _searchController.clear();
              context.read<ProjectsBloc>().add(const ClearFilters());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context, ProjectsState state) {
    final projectCount = state is ProjectsLoaded
        ? state.filteredProjects.length
        : 0;
    final totalCount = state is ProjectsLoaded ? state.projects.length : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'عرض $projectCount من $totalCount',
          style: AppTextStyles.bodyMedium,
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _buildViewButton(
                icon: Icons.table_rows_outlined,
                label: 'عرض الجدول',
                isSelected: _isTableView,
                onTap: () {
                  setState(() => _isTableView = true);
                  context.read<ProjectsBloc>().add(const ChangeViewMode(true));
                },
              ),
              _buildViewButton(
                icon: Icons.grid_view_outlined,
                label: 'عرض البطاقات',
                isSelected: !_isTableView,
                onTap: () {
                  setState(() => _isTableView = false);
                  context.read<ProjectsBloc>().add(const ChangeViewMode(false));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProjectsState state) {
    if (state is ProjectsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is ProjectsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ProjectsBloc>().add(const LoadProjects());
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state is ProjectsLoaded) {
      if (_isTableView) {
        return ProjectTableWidget(
          projects: state.filteredProjects,
          onProjectTap: (project) {
            // Route to pricing page if status is underPricing or pendingApproval
            if (project.status == ProjectStatus.underPricing ||
                project.status == ProjectStatus.pendingApproval) {
              context.go(AppRoutes.pricing(project.id));
            } else {
              context.go(AppRoutes.projectDetails(project.id));
            }
          },
          onEditProject: (project) {
            _showEditProjectDialog(context, project);
          },
          onDeleteProject: (project) {
            _showDeleteConfirmation(context, project.id, project.name);
          },
        );
      } else {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400,
            childAspectRatio: 1.1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: state.filteredProjects.length,
          itemBuilder: (context, index) {
            final project = state.filteredProjects[index];
            return ProjectCardWidget(
              project: project,
              onTap: () {
                // Route to pricing page if status is underPricing or pendingApproval
                if (project.status == ProjectStatus.underPricing ||
                    project.status == ProjectStatus.pendingApproval) {
                  context.go(AppRoutes.pricing(project.id));
                } else {
                  context.go(AppRoutes.projectDetails(project.id));
                }
              },
              onEdit: () {
                _showEditProjectDialog(context, project);
              },
              onDelete: () {
                _showDeleteConfirmation(context, project.id, project.name);
              },
            );
          },
        );
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildPagination(BuildContext context, ProjectsLoaded state) {
    final totalProjects = state.projects.length;
    final showingCount = state.filteredProjects.length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'عرض 1-$showingCount من $totalProjects',
            style: AppTextStyles.bodyMedium,
          ),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  // Previous page
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('السابق'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  // Next page
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('التالي'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final projectsBloc = context.read<ProjectsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: projectsBloc,
        child: const CreateProjectDialog(),
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, ProjectEntity project) {
    final projectsBloc = context.read<ProjectsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: projectsBloc,
        child: EditProjectDialog(project: project),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String projectId,
    String projectName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'تأكيد الحذف',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'هل أنت متأكد من حذف المشروع "$projectName"؟',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ProjectsBloc>().add(DeleteProject(projectId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
