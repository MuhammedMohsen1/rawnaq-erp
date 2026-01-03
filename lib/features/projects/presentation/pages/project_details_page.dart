import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../financial/data/repositories/transactions_repository_impl.dart';
import '../../../financial/domain/entities/transaction_entity.dart';
import '../../../financial/domain/entities/project_financial_summary.dart';
import '../../../financial/domain/entities/transaction_entity.dart' as tx;
import '../../../financial/data/models/transaction_model.dart';
import '../../../financial/domain/repositories/transactions_repository.dart';
import '../../domain/entities/project_entity.dart';
import '../bloc/projects_bloc.dart';
import '../bloc/projects_state.dart';
import '../widgets/financial_summary_card.dart';
import '../widgets/transactions_table.dart';
import '../../domain/enums/project_status.dart';

/// Project details page showing financial dashboard
class ProjectDetailsPage extends StatefulWidget {
  final String projectId;

  const ProjectDetailsPage({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  final TransactionsRepository _transactionsRepository =
      TransactionsRepositoryImpl();
  List<TransactionEntity> _transactions = [];
  ProjectFinancialSummary? _financialSummary;
  bool _isLoading = true;
  ProjectEntity? _project;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load project data
    final projectsState = context.read<ProjectsBloc>().state;
    if (projectsState is ProjectsLoaded) {
      try {
        _project = projectsState.projects.firstWhere(
          (p) => p.id == widget.projectId,
        );
      } catch (e) {
        // Project not found in loaded state, will be handled in build
      }
    }

    // Load financial data
    final transactionsResult =
        await _transactionsRepository.getTransactionsByProjectId(
      widget.projectId,
    );
    final summaryResult =
        await _transactionsRepository.getProjectFinancialSummary(
      widget.projectId,
    );

    transactionsResult.fold(
      (failure) {
        // Handle error
      },
      (transactions) {
        setState(() {
          _transactions = transactions;
        });
      },
    );

    summaryResult.fold(
      (failure) {
        // Handle error
      },
      (summary) {
        setState(() {
          _financialSummary = summary;
        });
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsBloc, ProjectsState>(
      builder: (context, state) {
        // Try to get project from loaded state
        if (state is ProjectsLoaded && _project == null) {
          try {
            final project = state.projects.firstWhere(
              (p) => p.id == widget.projectId,
            );
            if (project.id == widget.projectId) {
              _project = project;
            }
          } catch (e) {
            // Project not found, will show error in UI
          }
        }

        return ResponsiveLayout(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletLayout(),
          desktop: _buildDesktopLayout(),
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreadcrumb(),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ..._buildContent(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreadcrumb(),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ..._buildContent(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreadcrumb(),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ..._buildContent(),
        ],
      ),
    );
  }

  List<Widget> _buildContent() {
    if (_project == null || _financialSummary == null) {
      return [
        const Center(
          child: Text('المشروع غير موجود'),
        ),
      ];
    }

    return [
      _buildHeader(),
      const SizedBox(height: 24),
      _buildSummaryCards(),
      const SizedBox(height: 24),
      _buildTransactionsTable(),
    ];
  }

  Widget _buildBreadcrumb() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go(AppRoutes.projects),
          child: Text(
            'المشاريع',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.chevron_left,
          color: AppColors.textSecondary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          _project?.name ?? 'مشروع',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    if (_project == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _project!.name,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.75,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                border: Border.all(color: _getStatusColor().withOpacity(0.2)),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    if (_financialSummary == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: FinancialSummaryCard(
            type: FinancialSummaryCardType.totalReceived,
            amount: _financialSummary!.totalReceived,
            currency: '\$',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FinancialSummaryCard(
            type: FinancialSummaryCardType.totalExpenses,
            amount: _financialSummary!.totalExpenses,
            currency: '\$',
            subtitle: '3 موافقات معلقة',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FinancialSummaryCard(
            type: FinancialSummaryCardType.netCashFlow,
            amount: _financialSummary!.netCashFlow,
            currency: '\$',
            budgetPercentage: _financialSummary!.budgetPercentage,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsTable() {
    return TransactionsTable(
      transactions: _transactions,
      onDelete: (transaction) {
        if (transaction.canDelete) {
          _showDeleteConfirmation(context, transaction);
        }
      },
      onUpdate: (transaction) {
        _updateTransaction(transaction);
      },
      onAddNew: () {
        _addNewExpense();
      },
      onLoadMore: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تحميل المزيد - قريباً')),
        );
      },
    );
  }

  void _addNewExpense() {
    final newTransaction = TransactionModel(
      id: 'txn-new-${DateTime.now().millisecondsSinceEpoch}',
      type: tx.TransactionType.expense,
      description: '',
      amount: 0.0,
      date: DateTime.now(),
      projectId: widget.projectId,
      metadata: const tx.TransactionMetadata(
        isLocked: false,
      ),
    );

    setState(() {
      _transactions = [newTransaction, ..._transactions];
    });
  }

  void _updateTransaction(TransactionEntity transaction) {
    setState(() {
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }
    });

    // Recalculate summary
    _recalculateSummary();
  }

  void _deleteTransaction(TransactionEntity transaction) {
    setState(() {
      _transactions = _transactions.where((t) => t.id != transaction.id).toList();
    });

    // Recalculate summary
    _recalculateSummary();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف المعاملة')),
    );
  }

  void _recalculateSummary() {
    double totalReceived = 0.0;
    double totalExpenses = 0.0;

    for (final transaction in _transactions) {
      if (transaction.type == tx.TransactionType.deposit) {
        totalReceived += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
      }
    }

    final netCashFlow = totalReceived - totalExpenses;

    // Calculate budget percentage (assuming a budget of 50,000)
    const double budget = 50000.0;
    final remainingBudget = budget - totalExpenses;
    final budgetPercentage = budget > 0 ? (remainingBudget / budget) * 100 : 0.0;

    setState(() {
      _financialSummary = ProjectFinancialSummary(
        totalReceived: totalReceived,
        totalExpenses: totalExpenses,
        netCashFlow: netCashFlow,
        budget: budget,
        remainingBudget: remainingBudget,
        budgetPercentage: budgetPercentage,
      );
    });
  }

  Color _getStatusColor() {
    switch (_project?.status) {
      case ProjectStatus.active:
        return AppColors.statusActive;
      case ProjectStatus.completed:
        return AppColors.statusCompleted;
      case ProjectStatus.delayed:
        return AppColors.statusDelayed;
      case ProjectStatus.onHold:
        return AppColors.statusOnHold;
      default:
        return AppColors.statusOnHold;
    }
  }

  String _getStatusText() {
    switch (_project?.status) {
      case ProjectStatus.active:
        return 'نشط';
      case ProjectStatus.completed:
        return 'مكتمل';
      case ProjectStatus.delayed:
        return 'متأخر';
      case ProjectStatus.onHold:
        return 'معلق';
      default:
        return 'غير محدد';
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TransactionEntity transaction,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('حذف المعاملة'),
        content: Text(
          'هل أنت متأكد من حذف "${transaction.description}"؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTransaction(transaction);
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

