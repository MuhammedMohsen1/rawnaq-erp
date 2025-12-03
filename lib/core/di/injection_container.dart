import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '../storage/storage_service.dart';
import '../network/dio_helper.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/mock_auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/projects/domain/repositories/projects_repository.dart';
import '../../features/projects/data/repositories/projects_repository_impl.dart';
import '../../features/projects/presentation/bloc/projects_bloc.dart';

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

  // Auth Repository (using mock for development - no backend needed)
  getIt.registerLazySingleton<AuthRepository>(() => MockAuthRepository());

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
}

Future<void> resetDI() async {
  await getIt.reset();
}
