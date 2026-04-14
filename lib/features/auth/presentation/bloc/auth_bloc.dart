import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) {
    try {
      emit(AuthUnauthenticated());
    } catch (_) {
      emit(const AuthError('Authentication failed. Please try again.'));
    }
  }

  void _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) {
    try {
      emit(AuthAuthenticated());
    } catch (_) {
      emit(const AuthError('Login failed. Please try again.'));
    }
  }

  void _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) {
    try {
      emit(AuthUnauthenticated());
    } catch (_) {
      emit(const AuthError('Logout failed. Please try again.'));
    }
  }
}
