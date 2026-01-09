import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/user_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({required this.userRepository}) : super(AuthUninitialized()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      if (await userRepository.hasToken()) {
        final token = await userRepository.getToken();
        final profile = await userRepository.getProfile();
        if (token != null) {
          emit(AuthAuthenticated(token: token, user: profile));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final profile = await userRepository.getProfile();
    emit(AuthAuthenticated(token: event.token, user: profile));
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await userRepository.deleteToken();
    emit(AuthUnauthenticated());
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success =
          await userRepository.authenticate(event.email, event.password);
      if (success) {
        final token = await userRepository.getToken();
        if (token != null) {
          final profile = await userRepository.getProfile();
          emit(AuthAuthenticated(token: token, user: profile));
        } else {
          emit(AuthError('Login failed: No token received'));
        }
      } else {
        emit(AuthError('Login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignupRequested(
      SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success =
          await userRepository.register(event.email, event.password);
      if (success) {
        final token = await userRepository.getToken();
        if (token != null) {
          final profile = await userRepository.getProfile();
          emit(AuthAuthenticated(token: token, user: profile));
        } else {
          emit(AuthError('Signup failed: No token received'));
        }
      } else {
        emit(AuthError('Signup failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await userRepository.deleteToken();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
