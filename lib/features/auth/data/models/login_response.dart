import '../../domain/entities/user.dart';

class LoginResponse {
  final bool success;
  final String code;
  final User user;
  final String token;
  final String refreshToken;
  final String sessionId;

  const LoginResponse({
    required this.success,
    required this.code,
    required this.user,
    required this.token,
    required this.refreshToken,
    required this.sessionId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Extract data from the nested data field
    final data = json['data'] as Map<String, dynamic>;
    return LoginResponse(
      success: json['success'] as bool,
      code: json['code'] as String? ?? json['message'] as String? ?? 'SUCCESS', // Support legacy message field
      user: User.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
      refreshToken: data['refreshToken'] as String,
      sessionId: data['sessionId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'code': code,
      'data': {
        'user': user.toJson(),
        'token': token,
        'refreshToken': refreshToken,
        'sessionId': sessionId,
      },
    };
  }

  @override
  String toString() {
    return 'LoginResponse(success: $success, code: $code, user: $user, token: ${token.substring(0, 20)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginResponse &&
        other.success == success &&
        other.code == code &&
        other.user == user &&
        other.token == token &&
        other.refreshToken == refreshToken &&
        other.sessionId == sessionId;
  }

  @override
  int get hashCode =>
      success.hashCode ^
      code.hashCode ^
      user.hashCode ^
      token.hashCode ^
      refreshToken.hashCode ^
      sessionId.hashCode;
}
