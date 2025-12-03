import '../../domain/entities/user.dart';

class LoginResponse {
  final bool success;
  final String message;
  final User user;
  final String token;

  const LoginResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user.toJson(),
      'token': token,
    };
  }

  @override
  String toString() {
    return 'LoginResponse(success: $success, message: $message, user: $user, token: ${token.substring(0, 20)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginResponse &&
        other.success == success &&
        other.message == message &&
        other.user == user &&
        other.token == token;
  }

  @override
  int get hashCode =>
      success.hashCode ^ message.hashCode ^ user.hashCode ^ token.hashCode;
}
