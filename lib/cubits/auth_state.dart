import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;
  final String message;
  final Map<String, dynamic>? data;
  const AuthSuccess({
    required this.token,
    required this.message,
    this.data,
  });

  // Equatable uses these props to check value equality
  @override
  List<Object?> get props => [token, message, data];
}

class AuthFailure extends AuthState {
  final String errorMessage;

  const AuthFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}