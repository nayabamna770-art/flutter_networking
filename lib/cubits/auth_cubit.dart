import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  /// Google Sign-In with Supabase
  Future<void> signInWithGoogle() async {
    if (isClosed) return;
    emit(AuthLoading());

    try {
      /// Replace with your Web Application Client ID from Google Cloud Console
      const webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        if (isClosed) return;
        emit(AuthInitial()); // Reset state if user cancelled the picker
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('No ID Token found from Google Sign-In.');
      }

      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (isClosed) return;

      if (response.user != null) {
        emit(AuthSuccess(
          message: 'Google Sign-In successful!',
          token: response.session?.accessToken ?? '',
          data: response.user,
        ));
      } else {
        emit(AuthFailure(errorMessage: 'Google Sign-In failed'));
      }
    } catch (e) {
      if (isClosed) return;
      emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }
}