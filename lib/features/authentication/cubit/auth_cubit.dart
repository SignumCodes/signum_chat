import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/login_request_model.dart';
import '../repositories/auth_repo.dart';
import 'auth_state.dart';


class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final AuthRepository repository = AuthRepository();

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await repository.login(LoginRequestModel(email, password));
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError("Login failed. Please try again."));
    }
  }
}