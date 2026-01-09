import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const SignupRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

class LoggedIn extends AuthEvent {
  final String token;

  const LoggedIn({required this.token});

  @override
  List<Object> get props => [token];
}

class LoggedOut extends AuthEvent {}

class LogoutRequested extends AuthEvent {}
