class ServerException implements Exception {
  final String message;
  final int? code;

  const ServerException({required this.message, this.code});
}

class NetworkException implements Exception {
  final String message;
  final int? code;

  const NetworkException({required this.message, this.code});
}

class CacheException implements Exception {
  final String message;
  final int? code;

  const CacheException({required this.message, this.code});
}

class ValidationException implements Exception {
  final String message;
  final int? code;

  const ValidationException({required this.message, this.code});
}

class UnauthorizedException implements Exception {
  final String message;
  final int? code;

  const UnauthorizedException({required this.message, this.code});
}

class NotFoundException implements Exception {
  final String message;
  final int? code;

  const NotFoundException({required this.message, this.code});
}

class TimeoutException implements Exception {
  final String message;
  final int? code;

  const TimeoutException({required this.message, this.code});
}
