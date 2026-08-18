import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../data/models/user_signup_model.dart';
import '../data/services/hive_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LocalStorageService _hiveService;

  AuthCubit(this._hiveService) : super(AuthInitial());

  static const String _webClientId =
      'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

  /// Google Sign-In with Supabase
  Future<void> signInWithGoogle() async {
    if (isClosed) return;
    emit(AuthLoading());

    try {
      // 1. Web-Specific Authentication Flow
      if (kIsWeb) {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'io.supabase.flutter://login-callback/',
        );
        return;
      }

      // 2. Mobile Native Authentication Flow (Android / iOS)
      final googleSignIn = GoogleSignIn.instance;

      try {
        await googleSignIn.initialize(
          clientId: _webClientId,
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
        emit(
          AuthSuccess(
            message: 'Google Sign-In successful!',
            token: response.session?.accessToken ?? '',
            data: response.user,
          ),
        );
      } else {
        emit(AuthFailure(errorMessage: 'Google Sign-In failed'));
      }
    } catch (e) {
      if (isClosed) return;
      emit(
        AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  // ... (signUp and login methods stay unchanged)
}
