import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/user_signup_model.dart';
import '../data/services/hive_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LocalStorageService _hiveService;

  AuthCubit(this._hiveService) : super(AuthInitial());

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    if (isClosed) return;
    emit(AuthLoading());

    try {
      final user = UserSignUpModel(
        email: email,
        password: password,
      );

      final result = await _hiveService.signUp(user);

      if (isClosed) return;

      if (result['success'] == true) {
        emit(AuthSuccess(
          message: result['message'] ?? 'Account created successfully!',
          token: result['token'] ?? '',
          data: result['data'],
        ));
      } else {
        emit(AuthFailure(errorMessage: result['message'] ?? 'Signup failed'));
      }
    } catch (e) {
      if (isClosed) return;
      emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (isClosed) return;
    emit(AuthLoading());

    try {
      final result = await _hiveService.login(email, password);

      if (isClosed) return;

      if (result['success'] == true) {
        emit(AuthSuccess(
          message: result['message'] ?? 'Login successful!',
          token: result['token'] ?? '',
          data: result['data'],
        ));
      } else {
        emit(AuthFailure(errorMessage: result['message'] ?? 'Login failed'));
      }
    } catch (e) {
      if (isClosed) return;
      emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }
}