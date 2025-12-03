part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String? deviceToken;

  const LoginRequested({
    required this.email,
    required this.password,
    this.deviceToken,
  });

  @override
  List<Object?> get props => [email, password, deviceToken];
}

class LogoutRequested extends AuthEvent {}

class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthStatusChecked extends AuthEvent {}

class CurrentUserRequested extends AuthEvent {}
