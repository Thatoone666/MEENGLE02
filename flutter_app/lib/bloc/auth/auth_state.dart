import 'package:equatable/equatable.dart';
import '../../models/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthUninitialized extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  final User? user;

  const AuthAuthenticated({required this.token, this.user});

  @override
  List<Object?> get props => [token, user];
}

class AuthUnauthenticated extends AuthState {}

class AuthLoading extends AuthState {}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);

  @override
  List<Object> get props => [error];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
