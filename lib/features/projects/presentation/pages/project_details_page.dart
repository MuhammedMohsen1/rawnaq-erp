import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../cubit/project_financial_cubit.dart';
import '../widgets/project_details_content.dart';

/// Project details page showing financial dashboard
/// Refactored to use Cubit for state management and extracted widget components
class ProjectDetailsPage extends StatelessWidget {
  final String projectId;

  const ProjectDetailsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<ProjectFinancialCubit>()..loadProjectFinancialData(projectId),
      child: ProjectDetailsContent(projectId: projectId),
    );
  }
}
