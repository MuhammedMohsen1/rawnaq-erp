import 'package:dio/dio.dart';
import 'dio_helper.dart';
import '../error/exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await DioHelper.getData(
        url: endpoint,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await DioHelper.postData(
        url: endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await DioHelper.putData(
        url: endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await DioHelper.patchData(
        url: endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await DioHelper.deleteData(
        url: endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> uploadFile(
    String endpoint, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await DioHelper.uploadFile(
        url: endpoint,
        formData: formData,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw TimeoutException(
            message: 'Connection timeout occurred',
            code: error.response?.statusCode,
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message =
              error.response?.data?['message'] ??
              error.response?.statusMessage ??
              'Server error occurred';

          switch (statusCode) {
            case 401:
              throw UnauthorizedException(message: message, code: statusCode);
            case 404:
              throw NotFoundException(message: message, code: statusCode);
            case 422:
              throw ValidationException(message: message, code: statusCode);
            default:
              throw ServerException(message: message, code: statusCode);
          }
        case DioExceptionType.connectionError:
          throw NetworkException(
            message: 'Network connection error',
            code: error.response?.statusCode,
          );
        case DioExceptionType.cancel:
          throw NetworkException(
            message: 'Request was cancelled',
            code: error.response?.statusCode,
          );
        default:
          throw ServerException(
            message: error.message ?? 'Unknown error occurred',
            code: error.response?.statusCode,
          );
      }
    } else {
      throw ServerException(message: error.toString());
    }
  }
}
