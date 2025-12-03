import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/di/injection_container.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final IsLoggedInUseCase isLoggedInUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.resetPasswordUseCase,
    required this.getCurrentUserUseCase,
    required this.isLoggedInUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<CurrentUserRequested>(_onCurrentUserRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      log('🚩 AuthBloc: Starting login request');
      emit(AuthLoading());

      final result = await loginUseCase(
        email: event.email,
        password: event.password,
        deviceToken: event.deviceToken,
      );

      log('🚩 AuthBloc: Login use case completed');

      await result.fold(
        (failure) async {
          log(
            '🚩 AuthBloc: Login failed - ${failure.runtimeType}: ${failure.message}',
          );
          if (!emit.isDone) {
            emit(AuthError(message: failure.message));
          }
        },
        (data) async {
          log('🚩 AuthBloc: Login successful');
          final token = data['token'] as String;
          final userJson = data['user'] as Map<String, dynamic>;
          final user = User.fromJson(userJson);
          final storageService = getIt<StorageService>();
          await storageService.setToken(token);
          await storageService.setUserData(userJson);
          await Future.delayed(const Duration(milliseconds: 200));
          if (!emit.isDone) {
            emit(AuthAuthenticated(user: user, token: token));
          }
        },
      );
    } catch (e) {
      log('🚩 AuthBloc: Unexpected error caught: $e');
      if (!emit.isDone) {
        emit(AuthError(message: 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.'));
      }
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logoutUseCase();

    await result.fold(
      (failure) async => emit(AuthError(message: failure.message)),
      (async_) async {
        final storageService = getIt<StorageService>();
        await storageService.clearToken();
        await storageService.clearUserData();

        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(ResetPasswordLoading());

    final result = await resetPasswordUseCase(email: event.email);

    result.fold(
      (failure) => emit(ResetPasswordError(message: failure.message)),
      (_) => emit(
        const ResetPasswordSuccess(
          message: 'Password reset link sent to your email',
        ),
      ),
    );
  }

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final result = await isLoggedInUseCase();

    await result.fold((failure) async => emit(AuthUnauthenticated()), (
      isLoggedIn,
    ) async {
      if (isLoggedIn) {
        final storageService = getIt<StorageService>();
        final userData = await storageService.getUserData();
        final token = await storageService.getToken();

        if (userData != null && token != null) {
          final user = User.fromJson(userData);
          if (!emit.isDone) emit(AuthAuthenticated(user: user, token: token));
        } else {
          if (!emit.isDone) emit(AuthUnauthenticated());
        }
      } else {
        if (!emit.isDone) emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> _onCurrentUserRequested(
    CurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getCurrentUserUseCase();

    await result.fold(
      (failure) async => emit(AuthError(message: failure.message)),
      (user) async {
        final storageService = getIt<StorageService>();
        final token = await storageService.getToken();
        await storageService.setUserData(user.toJson());

        if (token != null) {
          await storageService.setUserData(user.toJson());
          if (!emit.isDone) emit(AuthAuthenticated(user: user, token: token));
        } else {
          if (!emit.isDone) emit(AuthUnauthenticated());
        }
      },
    );
  }

  @override
  void onChange(Change<AuthState> change) {
    log(
      '🚩 Bloc: حالة AuthBloc تغيرت: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
    );
    super.onChange(change);
  }
}
