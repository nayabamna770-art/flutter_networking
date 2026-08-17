import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/user_signup_model.dart';
import '../data/services/api_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiService _apiService;

  AuthCubit(this._apiService) : super(AuthInitial());

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    if (isClosed) return;
    emit(AuthLoading());

    final user = UserSignUpModel(
      email: email,
      password: password,
    );

    final result = await _apiService.signUp(user);

    // Guard against emitting state if cubit was closed while waiting for HTTP call
    if (isClosed) return;

    if (result['success'] == true) {
      emit(AuthSuccess(
        message: result['message'],
        token: result['token'] ?? '',
        data: result['data'],
      ));
    } else {
      emit(AuthFailure(errorMessage: result['message']));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (isClosed) return;
    emit(AuthLoading());

    final result = await _apiService.login(email, password);

    if (isClosed) return;

    if (result['success'] == true) {
      emit(AuthSuccess(
        message: result['message'],
        token: result['token'] ?? '',
        data: result['data'],
      ));
    } else {
      emit(AuthFailure(errorMessage: result['message']));
    }
  }
}