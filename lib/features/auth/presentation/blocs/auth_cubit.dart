import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    emit(state.copyWith(
      status: isLoggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    ));
  }

  Future<void> login(String username, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    // Mock authentication
    if (username == 'admin' && password == 'password') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setBool('isLoggedIn', true);
      emit(state.copyWith(status: AuthStatus.authenticated));
    } else {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Invalid credentials',
      ));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.setBool('isLoggedIn', false);
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }
}
