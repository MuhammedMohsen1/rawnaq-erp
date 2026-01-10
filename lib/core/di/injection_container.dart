import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '../storage/storage_service.dart';
import '../network/dio_helper.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/projects/domain/repositories/projects_repository.dart';
import '../../features/projects/data/repositories/projects_repository_impl.dart';
import '../../features/projects/presentation/bloc/projects_bloc.dart';
import '../../features/projects/presentation/cubit/project_financial_cubit.dart';
import '../../features/financial/domain/repositories/transactions_repository.dart';
import '../../features/financial/data/repositories/transactions_repository_impl.dart';
import '../../features/pricing/presentation/cubit/pricing_cubit.dart';
import '../../features/pricing/data/datasources/pricing_api_datasource.dart';
import '../../features/contracts/data/datasources/contracts_api_datasource.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  // Register navigator key for routing
  getIt.registerSingleton<GlobalKey<NavigatorState>>(
    GlobalKey<NavigatorState>(),
  );

  // Storage
  final storageService = StorageServiceImpl();
  await storageService.init();
  getIt.registerSingleton<StorageService>(storageService);

  // Network initialization
  DioHelper.init();

  // Auth Repository (using real implementation with backend API)
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  // Auth Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => ResetPasswordUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt()));
  getIt.registerLazySingleton(() => IsLoggedInUseCase(getIt()));

  // Auth BLoC
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt(),
      logoutUseCase: getIt(),
      resetPasswordUseCase: getIt(),
      getCurrentUserUseCase: getIt(),
      isLoggedInUseCase: getIt(),
    ),
  );

  // Projects Repository
  getIt.registerLazySingleton<ProjectsRepository>(
    () => ProjectsRepositoryImpl(),
  );

  // Projects BLoC
  getIt.registerFactory(
    () => ProjectsBloc(repository: getIt()),
  );

  // Transactions Repository
  getIt.registerLazySingleton<TransactionsRepository>(
    () => TransactionsRepositoryImpl(),
  );

  // Project Financial Cubit
  getIt.registerFactory(
    () => ProjectFinancialCubit(
      projectsRepository: getIt(),
      transactionsRepository: getIt(),
    ),
  );

  // Pricing Data Sources
  getIt.registerLazySingleton(() => PricingApiDataSource());
  getIt.registerLazySingleton(() => ContractsApiDataSource());

  // Pricing Cubit
  getIt.registerFactory(
    () => PricingCubit(
      pricingApiDataSource: getIt(),
      contractsApiDataSource: getIt(),
    ),
  );
}

Future<void> resetDI() async {
  await getIt.reset();
}
