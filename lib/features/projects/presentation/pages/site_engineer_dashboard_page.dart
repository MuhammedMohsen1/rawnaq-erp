import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/enums/project_status.dart';
import '../bloc/projects_bloc.dart';
import '../bloc/projects_event.dart';
import '../bloc/projects_state.dart';
import '../../../pricing/data/datasources/pricing_api_datasource.dart';
import '../../../pricing/data/models/pricing_version_model.dart';

class SiteEngineerDashboardPage extends StatefulWidget {
  const SiteEngineerDashboardPage({super.key});

  @override
  State<SiteEngineerDashboardPage> createState() =>
      _SiteEngineerDashboardPageState();
}

class _SiteEngineerDashboardPageState extends State<SiteEngineerDashboardPage> {
  final _pricingApiDataSource = PricingApiDataSource();
  final Map<String, PricingVersionModel?> _projectPricingVersions = {};
  bool _isLoadingPricingVersions = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadPricingVersions(List<ProjectEntity> projects) async {
    if (_isLoadingPricingVersions) return;

    setState(() {
      _isLoadingPricingVersions = true;
    });

    try {
      // Fetch pricing versions for all projects in parallel
      final futures = projects.map((project) async {
        try {
          final versions = await _pricingApiDataSource.getPricingVersions(
            project.id,
          );
          if (versions.isNotEmpty) {
            // Get the latest version (first in the list, assuming sorted by version desc)
            final latestVersion = versions.first;
            return MapEntry(project.id, latestVersion);
          }
          return MapEntry(project.id, null as PricingVersionModel?);
        } catch (e) {
          // If error, assume no pricing version
          return MapEntry(project.id, null as PricingVersionModel?);
        }
      });

      final results = await Future.wait(futures);
      final pricingVersionsMap = Map<String, PricingVersionModel?>.fromEntries(
        results,
      );

      if (mounted) {
        setState(() {
          _projectPricingVersions.clear();
          _projectPricingVersions.addAll(pricingVersionsMap);
          _isLoadingPricingVersions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPricingVersions = false;
        });
      }
    }
  }

  bool _hasUnderPricingStatus(ProjectEntity project) {
    // Show projects with status: Draft, Under Pricing, Pending Approval (Approved), or Pending Signature
    return project.status == ProjectStatus.draft ||
        project.status == ProjectStatus.underPricing ||
        project.status == ProjectStatus.pendingApproval ||
        project.status == ProjectStatus.profitPending;
  }

  String _getPricingStatusText(String? status) {
    if (status == null) return 'بدون تسعير';

    switch (status.toUpperCase()) {
      case 'DRAFT':
        return 'مسودة';
      case 'PENDING_SIGNATURE':
        return 'في انتظار التوقيع';
      case 'PENDING_APPROVAL':
        return 'في انتظار الموافقة';
      case 'APPROVED':
        return 'موافق عليه';
      case 'REJECTED':
        return 'مرفوض';
      default:
        return 'قيد التسعير';
    }
  }

  Color _getPricingStatusColor(String? status) {
    if (status == null) return AppColors.textMuted;

    switch (status.toUpperCase()) {
      case 'DRAFT':
        return AppColors.textMuted;
      case 'PENDING_SIGNATURE':
        return AppColors.warning;
      case 'PENDING_APPROVAL':
        return AppColors.warning;
      case 'APPROVED':
        return AppColors.statusCompleted;
      case 'REJECTED':
        return AppColors.statusDelayed;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsBloc, ProjectsState>(
      builder: (context, state) {
        if (state is ProjectsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProjectsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'حدث خطأ: ${state.message}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
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
          // Load pricing versions if not already loaded
          if (!_isLoadingPricingVersions &&
              _projectPricingVersions.length != state.projects.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadPricingVersions(state.projects);
            });
          }

          // Filter projects based on project status
          // Under pricing projects: Draft, Under Pricing, Pending Approval (Approved), or Pending Signature
          final underPricingProjects = state.projects
              .where((p) => _hasUnderPricingStatus(p))
              .toList();

          // Ongoing projects: Only EXECUTION or Completed status
          final ongoingProjects = state.projects
              .where(
                (p) =>
                    p.status == ProjectStatus.execution ||
                    p.status == ProjectStatus.completed,
              )
              .toList();

          return ResponsiveLayout(
            mobile: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ONGOING PROJECTS Section
                  _buildSectionTitle('المشاريع الجارية'),
                  const SizedBox(height: 16),
                  _buildOngoingProjectsMobile(ongoingProjects),
                  const SizedBox(height: 32),

                  // UNDER PRICING PROJECTS Section
                  _buildSectionTitle('المشاريع قيد التسعير'),
                  const SizedBox(height: 16),
                  _buildUnderPricingProjectsMobile(
                    context,
                    underPricingProjects,
                  ),
                ],
              ),
            ),
            tablet: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ONGOING PROJECTS Section
                  _buildSectionTitle('المشاريع الجارية'),
                  const SizedBox(height: 16),
                  _buildOngoingProjectsTablet(ongoingProjects),
                  const SizedBox(height: 32),

                  // UNDER PRICING PROJECTS Section
                  _buildSectionTitle('المشاريع قيد التسعير'),
                  const SizedBox(height: 16),
                  _buildUnderPricingProjectsTablet(
                    context,
                    underPricingProjects,
                  ),
                ],
              ),
            ),
            desktop: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ONGOING PROJECTS Section
                  _buildSectionTitle('المشاريع الجارية'),
                  const SizedBox(height: 16),
                  _buildOngoingProjectsDesktop(ongoingProjects),
                  const SizedBox(height: 32),

                  // UNDER PRICING PROJECTS Section
                  _buildSectionTitle('المشاريع قيد التسعير'),
                  const SizedBox(height: 16),
                  _buildUnderPricingProjectsDesktop(
                    context,
                    underPricingProjects,
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h4.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Mobile layout: Stack vertically
  Widget _buildOngoingProjectsMobile(List<ProjectEntity> projects) {
    if (projects.isEmpty) {
      return _buildEmptyState('لا توجد مشاريع جارية');
    }

    return Column(
      children: [
        for (var i = 0; i < projects.length; i++) ...[
          _buildOngoingProjectCard(projects[i], context),
          if (i < projects.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  // Tablet layout: 2 columns
  Widget _buildOngoingProjectsTablet(List<ProjectEntity> projects) {
    if (projects.isEmpty) {
      return _buildEmptyState('لا توجد مشاريع جارية');
    }

    return Column(
      children: [
        for (var i = 0; i < projects.length; i += 2) ...[
          Row(
            children: [
              Expanded(child: _buildOngoingProjectCard(projects[i], context)),
              if (i + 1 < projects.length) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOngoingProjectCard(projects[i + 1], context),
                ),
              ],
            ],
          ),
          if (i + 2 < projects.length) const SizedBox(height: 16),
        ],
      ],
    );
  }

  // Desktop layout: 4 columns
  Widget _buildOngoingProjectsDesktop(List<ProjectEntity> projects) {
    if (projects.isEmpty) {
      return _buildEmptyState('لا توجد مشاريع جارية');
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: projects
          .map(
            (project) => SizedBox(
              width: (MediaQuery.of(context).size.width - 96) / 4 - 12,
              child: _buildOngoingProjectCard(project, context),
            ),
          )
          .toList(),
    );
  }

  Widget _buildOngoingProjectCard(ProjectEntity project, BuildContext context) {
    final lastUpdate = _formatTimeAgo(
      project.updatedAt ?? project.createdAt ?? DateTime.now(),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusButton('نشط', AppColors.statusActive),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'التقدم',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${project.progress}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: project.progress / 100,
              backgroundColor: AppColors.progressBackground,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.statusActive),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'آخر تحديث: $lastUpdate',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          // Divider
          const Divider(color: AppColors.border, height: 1, thickness: 1),
          const SizedBox(height: 16),
          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Open Project button (left side, no icon, dark grey)
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go(AppRoutes.projectDetails(project.id));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardBackground,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: AppColors.border, width: 1),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'فتح المشروع',
                      style: AppTextStyles.buttonSmall,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Add Expenses button (right side, wallet icon, square)
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'assets/images/add-wallet.svg',
                        width: 24,
                        height: 24,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Mobile layout: Stack vertically
  Widget _buildUnderPricingProjectsMobile(
    BuildContext context,
    List<ProjectEntity> projects,
  ) {
    if (projects.isEmpty) {
      return _buildEmptyState('لا توجد مشاريع قيد التسعير');
    }

    return Column(
      children: [
        for (var i = 0; i < projects.length; i++) ...[
          _buildPricingProjectCard(context, projects[i]),
          if (i < projects.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  // Tablet layout: Horizontal (same as desktop)
  Widget _buildUnderPricingProjectsTablet(
    BuildContext context,
    List<ProjectEntity> projects,
  ) {
    return _buildUnderPricingProjectsDesktop(context, projects);
  }

  // Desktop layout: 3 columns horizontal
  Widget _buildUnderPricingProjectsDesktop(
    BuildContext context,
    List<ProjectEntity> projects,
  ) {
    if (projects.isEmpty) {
      return _buildEmptyState('لا توجد مشاريع قيد التسعير');
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: projects
          .map(
            (project) => SizedBox(
              width: (MediaQuery.of(context).size.width - 96) / 3 - 11,
              child: _buildPricingProjectCard(context, project),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPricingProjectCard(BuildContext context, ProjectEntity project) {
    final pricingVersion = _projectPricingVersions[project.id];
    final pricingStatus = pricingVersion?.status;
    final statusText = _getPricingStatusText(pricingStatus);
    final statusColor = _getPricingStatusColor(pricingStatus);

    // Determine action button text and icon based on pricing status
    String actionButton;
    Widget prefixIcon;

    if (pricingStatus == null) {
      actionButton = 'بدء التسعير';
      prefixIcon = const Icon(Icons.add, size: 15, weight: 700);
    } else {
      switch (pricingStatus.toUpperCase()) {
        case 'DRAFT':
          actionButton = 'متابعة التسعير';
          prefixIcon = const Icon(Icons.edit, size: 15, weight: 700);
          break;
        case 'PENDING_SIGNATURE':
          actionButton = 'عرض التسعير';
          prefixIcon = const Icon(Icons.visibility, size: 15, weight: 700);
          break;
        case 'PENDING_APPROVAL':
          actionButton = 'عرض التسعير';
          prefixIcon = const Icon(Icons.visibility, size: 15, weight: 700);
          break;
        default:
          actionButton = 'عرض التسعير';
          prefixIcon = const Icon(Icons.visibility, size: 15, weight: 700);
      }
    }

    return InkWell(
      onTap: () {
        context.go(AppRoutes.pricing(project.id));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/engineering-pencil.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ],
            ),
            if (pricingStatus != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Two dark cards side by side
            Row(
              children: [
                // Estimated Price Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'السعر المقدر',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pricingVersion?.totalPrice != null
                              ? '${pricingVersion!.totalPrice.toStringAsFixed(3)} KD'
                              : '- KD',
                          style: AppTextStyles.h5.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Number of Items Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'عدد الفئات',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              color: AppColors.textPrimary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              project.itemsCount != null
                                  ? '${project.itemsCount}'
                                  : '-',
                              style: AppTextStyles.h5.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Divider
            const Divider(color: AppColors.border, height: 1, thickness: 1),
            const SizedBox(height: 16),
            // Action button (same style as Ongoing Projects)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  context.go(AppRoutes.pricing(project.id));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardBackground,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppColors.border, width: 1),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    prefixIcon,
                    const SizedBox(width: 4),
                    Text(
                      actionButton,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Format date to Arabic "time ago" format
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'منذ $years ${years == 1 ? 'سنة' : 'سنوات'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months ${months == 1 ? 'شهر' : 'أشهر'}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }
}
