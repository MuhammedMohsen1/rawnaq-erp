import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../cubit/design_workspace_cubit.dart';
import '../widgets/design_workspace_widgets.dart';

class DesignProjectWorkspace extends StatelessWidget {
  final ProjectEntity project;

  const DesignProjectWorkspace({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DesignWorkspaceCubit(projectId: project.id)..load(),
      child: DesignWorkspaceBody(project: project),
    );
  }
}
