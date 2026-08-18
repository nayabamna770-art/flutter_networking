import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../data/models/user_signup_model.dart';
import '../data/services/hive_service.dart';
//import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
//import 'signup_screen.dart';

class AuthCubit extends Cubit<AuthState> {
  final LocalStorageService _hiveService;

  AuthCubit(this._hiveService) : super(AuthInitial());

  /// Web Application Client ID from Google Cloud Console (used as serverClientId on Android)
  static const String _webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

  /// Email/Password Sign Up using Hive
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
      emit(AuthFailure(
          errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Email/Password Login using Hive
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
      emit(AuthFailure(
          errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Google Sign-In with Supabase
  Future<void> signInWithGoogle() async {
    if (isClosed) return;
    emit(AuthLoading());

    try {
      // Handle Web redirect flow
      if (kIsWeb) {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
        );
        return;
      }

      // Handle Android/iOS Native flow
      final googleSignIn = GoogleSignIn.instance;

      try {
        await googleSignIn.initialize(
          serverClientId: _webClientId,
        );
      } catch (_) {}

      final googleUser = await googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('No ID Token found from Google Sign-In.');
      }

      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
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
      emit(AuthFailure(
          errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }
}