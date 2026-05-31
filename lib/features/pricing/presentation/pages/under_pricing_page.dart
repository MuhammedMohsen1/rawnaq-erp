import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rawnaq/core/routing/app_router.dart';
import 'package:flutter_ionicons/flutter_ionicons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/layout/top_bar_title_controller.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../projects/data/datasources/projects_api_datasource.dart';
import '../../../projects/domain/enums/project_status.dart';
import '../../../projects/presentation/widgets/project_attachments_panel.dart';
import '../../../contracts/data/datasources/contracts_api_datasource.dart';
import '../cubit/pricing_cubit.dart';
import '../cubit/pricing_state.dart';
import '../utils/pricing_status_utils.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/add_pricing_item_button.dart';
import '../widgets/contract_export_dialog.dart';
import '../widgets/pricing_confirmation_dialogs.dart';
import '../widgets/pricing_header.dart';
import '../widgets/pricing_items_list.dart';
import '../widgets/pricing_summary_sidebar.dart';

/// Under pricing page - refactored with Cubit and extracted widgets
class UnderPricingPage extends StatelessWidget {
  final String projectId;
  final bool readOnly;
  final bool hideFinancials;

  const UnderPricingPage({
    super.key,
    required this.projectId,
    this.readOnly = false,
    this.hideFinancials = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<PricingCubit>()..loadPricingData(projectId, readOnly: readOnly),
      child: _UnderPricingContent(
        projectId: projectId,
        readOnly: readOnly,
        hideFinancials: hideFinancials,
      ),
    );
  }
}

/// Internal content widget with access to Cubit
class _UnderPricingContent extends StatefulWidget {
  final String projectId;
  final bool readOnly;
  final bool hideFinancials;

  const _UnderPricingContent({
    required this.projectId,
    required this.readOnly,
    required this.hideFinancials,
  });

  @override
  State<_UnderPricingContent> createState() => _UnderPricingContentState();
}

class _UnderPricingContentState extends State<_UnderPricingContent> {
  late bool _showFinancials = !widget.hideFinancials;

  @override
  void initState() {
    super.initState();
    _syncToolbarAction();
  }

  @override
  void didUpdateWidget(_UnderPricingContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hideFinancials != widget.hideFinancials) {
      _showFinancials = !widget.hideFinancials;
    }
    _syncToolbarAction();
  }

  @override
  void dispose() {
    TopBarTitleController.clearPricingTitle();
    TopBarTitleController.clearPricingAction();
    super.dispose();
  }

  void _syncToolbarAction() {
    if (!widget.hideFinancials) {
      TopBarTitleController.clearPricingAction();
      return;
    }

    TopBarTitleController.setPricingAction(
      TopBarAction(
        icon: _showFinancials ? Ionicons.eye_outline : Ionicons.eye_off_outline,
        tooltip: _showFinancials
            ? 'إخفاء بيانات التسعير'
            : 'إظهار بيانات التسعير',
        onPressed: _toggleFinancialVisibility,
      ),
    );
  }

  void _toggleFinancialVisibility() {
    setState(() {
      _showFinancials = !_showFinancials;
    });
    _syncToolbarAction();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PricingCubit, PricingState>(
      listener: (context, state) {
        if (state is PricingLoaded) {
          final projectName = state.projectName?.trim();
          if (projectName != null && projectName.isNotEmpty) {
            TopBarTitleController.setPricingTitle('$projectName - التسعير');
          } else {
            TopBarTitleController.clearPricingTitle();
          }
        } else if (state is PricingEmptyReadOnly) {
          final projectName = state.projectName?.trim();
          if (projectName != null && projectName.isNotEmpty) {
            TopBarTitleController.setPricingTitle('$projectName - التسعير');
          } else {
            TopBarTitleController.clearPricingTitle();
          }
        } else {
          TopBarTitleController.clearPricingTitle();
        }

        // Handle errors
        if (state is PricingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is PricingLoading) {
          return const Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is PricingError) {
          return _ErrorView(
            message: state.message,
            onRetry: () => context.read<PricingCubit>().loadPricingData(
              widget.projectId,
              readOnly: widget.readOnly,
            ),
          );
        }

        if (state is PricingLoaded) {
          return _LoadedContent(
            projectId: widget.projectId,
            state: state,
            hideFinancials: widget.hideFinancials,
            showFinancials: _showFinancials,
            onToggleFinancials: _toggleFinancialVisibility,
          );
        }

        if (state is PricingEmptyReadOnly) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 54,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد بيانات تسعير لهذا المشروع المؤرشف',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'استعد المشروع أولاً لإضافة إصدار تسعير جديد.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Loaded content view
class _LoadedContent extends StatelessWidget {
  final String projectId;
  final PricingLoaded state;
  final bool hideFinancials;
  final bool showFinancials;
  final VoidCallback onToggleFinancials;

  const _LoadedContent({
    required this.projectId,
    required this.state,
    required this.hideFinancials,
    required this.showFinancials,
    required this.onToggleFinancials,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _PricingLayout(
        projectId: projectId,
        padding: 16,
        hideFinancialsInitially: hideFinancials,
        showFinancials: showFinancials,
        onToggleFinancials: onToggleFinancials,
      ),
      tablet: _PricingLayout(
        projectId: projectId,
        padding: 24,
        hideFinancialsInitially: hideFinancials,
        showFinancials: showFinancials,
        onToggleFinancials: onToggleFinancials,
      ),
      desktop: _PricingLayout(
        projectId: projectId,
        padding: 32,
        hideFinancialsInitially: hideFinancials,
        showFinancials: showFinancials,
        onToggleFinancials: onToggleFinancials,
      ),
    );
  }
}

/// Pricing layout for different screen sizes
class _PricingLayout extends StatefulWidget {
  final String projectId;
  final double padding;
  final bool hideFinancialsInitially;
  final bool showFinancials;
  final VoidCallback onToggleFinancials;

  const _PricingLayout({
    required this.projectId,
    required this.padding,
    required this.hideFinancialsInitially,
    required this.showFinancials,
    required this.onToggleFinancials,
  });

  @override
  State<_PricingLayout> createState() => _PricingLayoutState();
}

class _PricingLayoutState extends State<_PricingLayout> {
  String get projectId => widget.projectId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PricingCubit, PricingState>(
      builder: (context, state) {
        if (state is! PricingLoaded) return const SizedBox.shrink();

        final statusColor = PricingStatusUtils.getStatusColor(
          state.pricingVersion.status,
        );
        final showMobileFinancialToggle =
            widget.hideFinancialsInitially &&
            ResponsiveLayout.isMobile(context);

        return SingleChildScrollView(
          padding: EdgeInsets.all(widget.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PricingHeader(
                statusText: state.getStatusText(),
                statusColor: statusColor,
              ),
              const SizedBox(height: 24),
              if (showMobileFinancialToggle) ...[
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _MobileFinancialVisibilityButton(
                    showFinancials: widget.showFinancials,
                    onPressed: widget.onToggleFinancials,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ProjectAttachmentsPanel(
                projectId: projectId,
                projectStatus: _projectStatusFromApi(
                  state.pricingVersion.status,
                ),
                readOnly: state.readOnly,
              ),
              const SizedBox(height: 24),

              // Items list
              PricingItemsList(
                projectId: widget.projectId,
                version: state.pricingVersion.version,
                items: state.pricingVersion.items ?? [],
                pricingStatus: state.pricingVersion.status,
                itemExpandedStates: state.itemExpandedStates,
                subItemExpandedStates: state.subItemExpandedStates,
                subItemProfitMargins: state.subItemProfitMargins,
                onItemExpandedChanged: (itemId, isExpanded) {
                  context.read<PricingCubit>().toggleItemExpanded(itemId);
                },
                onSubItemExpandedChanged: (itemId, subItemStates) {
                  // Update all sub-item states for this item
                  for (var entry in subItemStates.entries) {
                    context.read<PricingCubit>().toggleSubItemExpanded(
                      itemId,
                      entry.key,
                    );
                  }
                },
                onDataChanged: () {
                  context.read<PricingCubit>().loadPricingData(
                    widget.projectId,
                    readOnly: state.readOnly,
                  );
                },
                onSubItemProfitMarginChanged: (subItemId, profitMargin) async {
                  if (state.readOnly) return;
                  await context.read<PricingCubit>().loadPricingData(
                    projectId,
                    readOnly: state.readOnly,
                  );
                  await context.read<PricingCubit>().updateSubItemProfitMargin(
                    subItemId,
                    profitMargin,
                    projectId,
                  );
                },
                onAddSubItem: state.readOnly
                    ? (_) {}
                    : (itemId) => _handleAddSubItem(context, itemId),
                onReorderItems: state.readOnly
                    ? null
                    : (oldIndex, newIndex) async {
                        await context.read<PricingCubit>().reorderItems(
                          widget.projectId,
                          oldIndex,
                          newIndex,
                        );
                      },
                onReorderSubItems: state.readOnly
                    ? null
                    : (itemId, oldIndex, newIndex) async {
                        await context.read<PricingCubit>().reorderSubItems(
                          widget.projectId,
                          itemId,
                          oldIndex,
                          newIndex,
                        );
                      },
                onReorderElements: state.readOnly
                    ? null
                    : (itemId, subItemId, elementId, targetOrder) async {
                        await context.read<PricingCubit>().reorderElement(
                          widget.projectId,
                          itemId,
                          subItemId,
                          elementId,
                          targetOrder,
                        );
                      },
                readOnly: state.readOnly,
                showFinancials: widget.showFinancials,
              ),
              const SizedBox(height: 24),

              // Add item button
              if (!state.readOnly) ...[
                AddPricingItemButton(onTap: () => _handleAddItem(context)),
                const SizedBox(height: 24),
              ],

              // Sidebar with summary and actions
              if (widget.showFinancials) _buildSidebar(context, state),
            ],
          ),
        );
      },
    );
  }

  ProjectStatus _projectStatusFromApi(String status) {
    return ProjectStatusExtension.fromApiString(status);
  }

  Widget _buildSidebar(BuildContext context, PricingLoaded state) {
    final authState = context.read<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;

    bool isAdminOrManager = false;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      isAdminOrManager = user.isAdmin || user.isManager;
    }

    final currentStatus = state.pricingVersion.status.toUpperCase();
    final showReturnButton =
        isAuthenticated &&
        (currentStatus == 'APPROVED' || currentStatus == 'PENDING_SIGNATURE');

    final isApproved = currentStatus == 'APPROVED';
    final isProfitPending = currentStatus == 'PENDING_SIGNATURE';

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
      ),
      child: PricingSummarySidebar(
        grandTotal: state.pricingVersion.totalPrice,
        originalTotalAmount: state.pricingVersion.originalTotalAmount,
        deductionAmount: state.deductionAmount,
        totalAmountAfterDeduction:
            state.pricingVersion.totalAmountAfterDeduction,
        totalCost: state.pricingVersion.totalCost,
        totalProfit: state.pricingVersion.totalProfit,
        totalElements: state.getTotalElementsCount(),
        lastSaveTime: PricingStatusUtils.formatLastSaveTime(
          state.pricingVersion.updatedAt,
        ),
        showReturnToPricing: showReturnButton && !state.readOnly,
        onReturnToPricing: showReturnButton && !state.readOnly
            ? () => _handleReturnToPricing(context)
            : null,
        isAdminOrManager: isAdminOrManager && widget.showFinancials,
        isPendingApproval: false,
        onAcceptPricing: null,
        isApproved: isApproved,
        isProfitPending: isProfitPending,
        onMakeProfit: isAdminOrManager && !state.readOnly && isApproved
            ? () => _handleMakeProfit(context)
            : null,
        onConfirmPricing: isProfitPending && !state.readOnly
            ? () => _handleConfirmPricing(context)
            : null,
        onExportPdf: (isAdminOrManager)
            ? (options) => _handleExportPdf(
                context,
                showDeductionBreakdown: options.showDeductionBreakdown,
                showLineItemPrices: options.showLineItemPrices,
              )
            : null,
        onExportContractPdf: isProfitPending
            ? () => _handleExportContractPdf(context)
            : null,
        onConfirmContract: isProfitPending && !state.readOnly
            ? () => _handleConfirmContract(context)
            : null,
        onReturnContractToPricing: isProfitPending && !state.readOnly
            ? () => _handleReturnContractToPricing(context)
            : null,
        onArchiveProject: isAuthenticated && !state.readOnly
            ? () => _handleArchiveProject(context)
            : null,
        onExportImages: (isAdminOrManager)
            ? (options) => _handleExportImages(
                context,
                showDeductionBreakdown: options.showDeductionBreakdown,
                showLineItemPrices: options.showLineItemPrices,
              )
            : null,
        onDeductionAmountChanged:
            isAdminOrManager &&
                !state.readOnly &&
                (isApproved || isProfitPending)
            ? (value) {
                context.read<PricingCubit>().updateDeductionAmount(value);
              }
            : null,
        onDeductionAmountApplied:
            isAdminOrManager &&
                !state.readOnly &&
                (isApproved || isProfitPending)
            ? (value) async {
                final cubit = context.read<PricingCubit>();
                final currentState = cubit.state;
                if (currentState is! PricingLoaded) return;

                try {
                  await cubit.calculateProfitForSubItems(widget.projectId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحديث الخصم بنجاح'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    _showErrorMessage(context, 'فشل تحديث الخصم', e);
                  }
                }
              }
            : null,
        pricingVersionNotes: state.pricingVersion.notes,
        onUpdateNotes: isAdminOrManager && !state.readOnly
            ? (notes) => _handleUpdateNotes(context, notes)
            : null,
        onSubmit: state.readOnly ? null : () => _handleSubmit(context),
        onSaveDraft: state.readOnly
            ? null
            : () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('تم حفظ المسودة')));
              },
        isDraft: currentStatus == 'DRAFT',
        isUnderPricing: currentStatus == 'UNDER_PRICING',
        isPendingSignature: currentStatus == 'PENDING_SIGNATURE',
        onBulkProfitMarginUpdate:
            isAdminOrManager &&
                !state.readOnly &&
                (isApproved || isProfitPending)
            ? (profitMargin) {
                context.read<PricingCubit>().updateAllSubItemProfitMargins(
                  projectId,
                  profitMargin,
                );
              }
            : null,
        showFinancials: widget.showFinancials,
      ),
    );
  }

  // Action handlers

  Future<void> _handleArchiveProject(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('أرشفة المشروع'),
        content: const Text(
          'هل تريد أرشفة هذا المشروع؟ سيتم إخفاء المشروع والتسعير المرتبط به من القوائم النشطة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('أرشفة'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ProjectsApiDataSource().deleteProject(projectId);
      if (!context.mounted) return;
      context.go(AppRoutes.archivedProjects);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تمت أرشفة المشروع')));
    } catch (e) {
      if (context.mounted) {
        _showErrorMessage(context, 'فشل أرشفة المشروع', e);
      }
    }
  }

  Future<void> _handleAddItem(BuildContext context) async {
    final name = await AddItemDialog.showAddItemDialog(context);
    if (name != null && name.isNotEmpty) {
      try {
        await context.read<PricingCubit>().addItem(projectId, name);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم إضافة البند بنجاح')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل إضافة البند: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _handleAddSubItem(BuildContext context, String itemId) async {
    final name = await AddItemDialog.showAddSubItemDialog(context);
    if (name != null && name.isNotEmpty) {
      try {
        await context.read<PricingCubit>().addSubItem(projectId, itemId, name);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة البند الفرعية بنجاح')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل إضافة البند الفرعية: ${e.toString()}'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleReturnToPricing(BuildContext context) async {
    final (confirmed, reason) =
        await PricingConfirmationDialogs.showReturnToPricingDialog(context);

    if (confirmed) {
      try {
        await context.read<PricingCubit>().returnToPricing(projectId, reason);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرجاع التسعير بنجاح. يمكنك الآن التعديل'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'فشل إرجاع التسعير', e);
        }
      }
    }
  }

  Future<void> _handleMakeProfit(BuildContext context) async {
    try {
      await context.read<PricingCubit>().calculateProfitForSubItems(projectId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حساب الربح بنجاح'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorMessage(context, 'فشل حساب الربح', e);
      }
    }
  }

  Future<void> _handleConfirmPricing(BuildContext context) async {
    final confirmed = await PricingConfirmationDialogs.showConfirmPricingDialog(
      context,
    );

    if (confirmed) {
      try {
        await context.read<PricingCubit>().confirmPricing(projectId);
        context.go(AppRoutes.projects);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم تأكيد التسعير وإنشاء العقد بنجاح. تم نقل المشروع إلى مرحلة التنفيذ.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'فشل تأكيد التسعير', e);
        }
      }
    }
  }

  Future<void> _handleConfirmContract(BuildContext context) async {
    // Fetch the contract to get the payment schedule
    final contractsApi = ContractsApiDataSource();
    List<Map<String, dynamic>>? paymentSchedule;

    try {
      final contract = await contractsApi.getContract(projectId);
      if (contract != null && contract['paymentSchedule'] != null) {
        final scheduleData = contract['paymentSchedule'] as List?;
        if (scheduleData != null) {
          paymentSchedule = scheduleData
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      }
    } catch (e) {
      // If we can't fetch the contract, continue without payment schedule
      // The dialog will show an error
    }

    if (!context.mounted) return;

    final confirmed =
        await PricingConfirmationDialogs.showConfirmContractDialog(
          context,
          paymentSchedule: paymentSchedule,
        );

    if (confirmed) {
      try {
        await context.read<PricingCubit>().confirmContract(projectId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم تأكيد العقد بنجاح. تم نقل المشروع إلى مرحلة التنفيذ.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'فشل تأكيد العقد', e);
        }
      }
    }
  }

  Future<void> _handleReturnContractToPricing(BuildContext context) async {
    final (
      confirmed,
      reason,
    ) = await PricingConfirmationDialogs.showReturnContractToPricingDialog(
      context,
    );

    if (confirmed) {
      try {
        await context.read<PricingCubit>().returnContractToPricing(
          projectId,
          reason,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم إرجاع العقد بنجاح. تم نقل المشروع إلى مرحلة التسعير.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'فشل إرجاع العقد', e);
        }
      }
    }
  }

  Future<void> _handleUpdateNotes(BuildContext context, String notes) async {
    try {
      await context.read<PricingCubit>().updatePricingVersionNotes(
        projectId,
        notes,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ الملاحظات: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit(BuildContext context) async {
    try {
      await context.read<PricingCubit>().submitForApproval(projectId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال التسعير للتوقيع')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال التسعير للتوقيع: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleExportPdf(
    BuildContext context, {
    required bool showDeductionBreakdown,
    required bool showLineItemPrices,
  }) async {
    BuildContext? dialogContext;
    try {
      // Show loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            dialogContext = ctx;
            return const Center(child: CircularProgressIndicator());
          },
        );
      }

      final pdfBytes = await context.read<PricingCubit>().exportPricingPdf(
        projectId,
        showDeductionBreakdown: showDeductionBreakdown,
        showLineItemPrices: showLineItemPrices,
      );

      // Close loading
      if (context.mounted && dialogContext != null) {
        Navigator.of(dialogContext!, rootNavigator: true).pop();
      }

      // Save file
      await _savePdfFile(context, pdfBytes);
    } catch (e) {
      if (dialogContext != null && context.mounted) {
        try {
          Navigator.of(dialogContext!, rootNavigator: true).pop();
        } catch (_) {}
      }
      if (context.mounted) {
        _showErrorMessage(context, 'فشل تصدير PDF', e);
      }
    }
  }

  Future<void> _handleExportContractPdf(BuildContext context) async {
    final state = context.read<PricingCubit>().state;
    if (state is! PricingLoaded) return;

    await showDialog<bool>(
      context: context,
      builder: (context) => ContractExportDialog(
        projectId: projectId,
        projectName: state.projectName ?? 'project',
        totalAmount: state.pricingVersion.totalAmountAfterDeduction,
      ),
    );

    // Dialog handles export itself
  }

  Future<void> _handleExportImages(
    BuildContext context, {
    required bool showDeductionBreakdown,
    required bool showLineItemPrices,
  }) async {
    BuildContext? dialogContext;
    try {
      // Show loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            dialogContext = ctx;
            return const Center(child: CircularProgressIndicator());
          },
        );
      }

      final result = await context.read<PricingCubit>().exportPricingImages(
        projectId,
        showDeductionBreakdown: showDeductionBreakdown,
        showLineItemPrices: showLineItemPrices,
      );

      // Close loading
      if (context.mounted && dialogContext != null) {
        Navigator.of(dialogContext!, rootNavigator: true).pop();
      }

      // Handle result (can be Uint8List or Map)
      if (result is Uint8List) {
        await _saveImageFile(context, result, 'pricing-image');
      } else if (result is Map<String, dynamic>) {
        await _saveMultipleImages(context, result);
      }
    } catch (e) {
      if (dialogContext != null && context.mounted) {
        try {
          Navigator.of(dialogContext!, rootNavigator: true).pop();
        } catch (_) {}
      }
      if (context.mounted) {
        _showErrorMessage(context, 'فشل تصدير الصور', e);
      }
    }
  }

  // Helper methods for file operations

  Future<void> _savePdfFile(BuildContext context, List<int> pdfBytes) async {
    final state = context.read<PricingCubit>().state;
    if (state is! PricingLoaded) return;

    final fileName = _buildPricingPdfFileName(state);

    File savedFile;

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ ملف PDF',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (outputFile == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إلغاء حفظ الملف'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      savedFile = File(outputFile);
      await savedFile.writeAsBytes(pdfBytes);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      savedFile = File('${directory.path}/$fileName');
      await savedFile.writeAsBytes(pdfBytes);
      await OpenFile.open(savedFile.path);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ PDF بنجاح: ${savedFile.path}'),
          duration: const Duration(seconds: 3),
          action: Platform.isWindows || Platform.isMacOS || Platform.isLinux
              ? SnackBarAction(
                  label: 'فتح',
                  onPressed: () async {
                    await OpenFile.open(savedFile.path);
                  },
                )
              : null,
        ),
      );
    }
  }

  String _buildPricingPdfFileName(PricingLoaded state) {
    final projectName = _sanitizeFileNamePart(state.projectName, 'المشروع');
    final clientName = _sanitizeFileNamePart(state.clientName, 'العميل');
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return 'عرض سعر $projectName -$clientName - $dateStr.pdf';
  }

  String _sanitizeFileNamePart(String? value, String fallback) {
    final sanitized =
        (value?.trim().isNotEmpty == true ? value!.trim() : fallback)
            .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

    return sanitized.isEmpty ? fallback : sanitized;
  }

  Future<void> _saveImageFile(
    BuildContext context,
    Uint8List imageBytes,
    String baseName,
  ) async {
    final state = context.read<PricingCubit>().state;
    if (state is! PricingLoaded) return;

    final projectName = state.projectName ?? 'project';
    final fileName =
        '$baseName-$projectName-v${state.pricingVersion.version}-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.png';

    File savedFile;

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ الصورة',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['png'],
      );

      if (outputFile == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إلغاء حفظ الملف'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      savedFile = File(outputFile);
      await savedFile.writeAsBytes(imageBytes);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      savedFile = File('${directory.path}/$fileName');
      await savedFile.writeAsBytes(imageBytes);
      await OpenFile.open(savedFile.path);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الصورة بنجاح: ${savedFile.path}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _saveMultipleImages(
    BuildContext context,
    Map<String, dynamic> result,
  ) async {
    final state = context.read<PricingCubit>().state;
    if (state is! PricingLoaded) return;

    final images = result['images'] as List<dynamic>? ?? [];
    if (images.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('لم يتم العثور على صور')));
      }
      return;
    }

    final projectName = state.projectName ?? 'project';
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final savedFiles = <File>[];

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final String? outputDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'اختر مجلد لحفظ الصور',
      );

      if (outputDir == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم إلغاء حفظ الملفات')));
        }
        return;
      }

      for (var i = 0; i < images.length; i++) {
        final imageData = images[i] as Map<String, dynamic>;
        final pageNumber = imageData['page'] as int? ?? (i + 1);
        final base64Data = imageData['data'] as String? ?? '';

        if (base64Data.isNotEmpty) {
          final imageBytes = base64Decode(base64Data);
          final fileName =
              'pricing-$projectName-v${state.pricingVersion.version}-$dateStr-page$pageNumber.png';
          final file = File('$outputDir/$fileName');
          await file.writeAsBytes(imageBytes);
          savedFiles.add(file);
        }
      }
    } else {
      final directory = await getApplicationDocumentsDirectory();
      for (var i = 0; i < images.length; i++) {
        final imageData = images[i] as Map<String, dynamic>;
        final pageNumber = imageData['page'] as int? ?? (i + 1);
        final base64Data = imageData['data'] as String? ?? '';

        if (base64Data.isNotEmpty) {
          final imageBytes = base64Decode(base64Data);
          final fileName =
              'pricing-$projectName-v${state.pricingVersion.version}-$dateStr-page$pageNumber.png';
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(imageBytes);
          savedFiles.add(file);
        }
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ ${savedFiles.length} صورة بنجاح'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorMessage(BuildContext context, String prefix, Object error) {
    String errorMessage = prefix;
    if (error is ServerException) {
      errorMessage = '$prefix: ${error.message}';
    } else if (error is ValidationException) {
      errorMessage = '$prefix: ${error.message}';
    } else {
      errorMessage = '$prefix: ${error.toString()}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

class _MobileFinancialVisibilityButton extends StatelessWidget {
  final bool showFinancials;
  final VoidCallback onPressed;

  const _MobileFinancialVisibilityButton({
    required this.showFinancials,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: showFinancials ? 'إخفاء بيانات التسعير' : 'إظهار بيانات التسعير',
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          icon: Icon(
            showFinancials ? Ionicons.eye_outline : Ionicons.eye_off_outline,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// Error view
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
