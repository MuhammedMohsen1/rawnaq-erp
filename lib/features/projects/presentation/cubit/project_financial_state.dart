import 'package:equatable/equatable.dart';
import '../../../financial/domain/entities/transaction_entity.dart';
import '../../../financial/domain/entities/project_financial_summary.dart';
import '../../domain/entities/project_attachment_entity.dart';
import '../../domain/entities/project_entity.dart';

/// Base state for project financial management
sealed class ProjectFinancialState extends Equatable {
  const ProjectFinancialState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProjectFinancialInitial extends ProjectFinancialState {
  const ProjectFinancialInitial();
}

/// Loading state
class ProjectFinancialLoading extends ProjectFinancialState {
  const ProjectFinancialLoading();
}

/// Loaded state with all financial data
class ProjectFinancialLoaded extends ProjectFinancialState {
  final ProjectEntity project;
  final List<TransactionEntity> transactions;
  final ProjectFinancialSummary financialSummary;
  final List<ProjectAttachmentEntity> attachments;
  final bool isUploadingAttachments;
  final bool isDeletingAttachment;

  const ProjectFinancialLoaded({
    required this.project,
    required this.transactions,
    required this.financialSummary,
    this.attachments = const [],
    this.isUploadingAttachments = false,
    this.isDeletingAttachment = false,
  });

  @override
  List<Object?> get props => [
    project,
    transactions,
    financialSummary,
    attachments,
    isUploadingAttachments,
    isDeletingAttachment,
  ];

  /// Create a copy with updated fields
  ProjectFinancialLoaded copyWith({
    ProjectEntity? project,
    List<TransactionEntity>? transactions,
    ProjectFinancialSummary? financialSummary,
    List<ProjectAttachmentEntity>? attachments,
    bool? isUploadingAttachments,
    bool? isDeletingAttachment,
  }) {
    return ProjectFinancialLoaded(
      project: project ?? this.project,
      transactions: transactions ?? this.transactions,
      financialSummary: financialSummary ?? this.financialSummary,
      attachments: attachments ?? this.attachments,
      isUploadingAttachments:
          isUploadingAttachments ?? this.isUploadingAttachments,
      isDeletingAttachment: isDeletingAttachment ?? this.isDeletingAttachment,
    );
  }
}

/// Error state
class ProjectFinancialError extends ProjectFinancialState {
  final String message;

  const ProjectFinancialError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Project not found state
class ProjectFinancialNotFound extends ProjectFinancialState {
  const ProjectFinancialNotFound();
}
