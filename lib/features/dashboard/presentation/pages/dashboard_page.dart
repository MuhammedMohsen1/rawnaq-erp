import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/app_router.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/dashboard_content.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardCubit>()..load(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return switch (state) {
            DashboardInitial() || DashboardLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            DashboardFailure(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: context.read<DashboardCubit>().load,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
            DashboardLoaded(:final summary) => DashboardContent(
              summary: summary,
              onPeriodChanged: context.read<DashboardCubit>().changePeriod,
              onUsersPressed: () => context.go(AppRoutes.adminUsers),
              onFinancialPressed: () => context.go(AppRoutes.financial),
            ),
          };
        },
      ),
    );
  }
}
