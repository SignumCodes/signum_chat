import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final AuthRepository repository = AuthRepository();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordObscured = true;

  void togglePasswordVisibility() {
    isPasswordObscured = !isPasswordObscured;
    emit(AuthInitial()); // Trigger UI update
  }

  // LOGIN
  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final user = await repository.login(username, password);
      emit(AuthSuccess(user!));
    } catch (e) {
      if (e is FirebaseAuthException) {
        emit(AuthError(e.message ?? 'Login failed'));
      } else {
        emit(AuthError(e.toString()));
      }
    }
  }

  // SIGNUP
  void signUp(BuildContext context) async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username and password cannot be empty")),
      );
      return;
    }

    emit(AuthLoading());
    try {
      final user = await repository.signUp(username, password);
      emit(AuthSuccess(user!));
    } catch (e) {
      emit(AuthError("Signup failed. Please try again."));
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await repository.logout();
    emit(AuthInitial());
  }
}