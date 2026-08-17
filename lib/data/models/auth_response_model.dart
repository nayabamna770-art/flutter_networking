class AuthResponseModel {
  final String? accessToken;
  final String? tokenType;
  final int? id;
  final String? email;
  final bool? isActive;

  AuthResponseModel({
    this.accessToken,
    this.tokenType,
    this.id,
    this.email,
    this.isActive,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String?,
      tokenType: json['token_type'] as String?,
      id: json['id'] as int?,
      email: json['email'] as String?,
      isActive: json['is_active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'id': id,
      'email': email,
      'is_active': isActive,
    };
  }
}