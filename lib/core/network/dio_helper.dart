import 'package:rawnaq/core/routing/app_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';
import '../di/injection_container.dart';
import '../utils/response_code_translator.dart';
import 'network_config.dart';

class DioHelper {
  static late Dio dio;

  static void init() {
    final BaseOptions baseOptions = BaseOptions(
      baseUrl: NetworkConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Only set sendTimeout for non-web platforms
    if (!kIsWeb) {
      baseOptions.sendTimeout = const Duration(
        milliseconds: AppConstants.sendTimeout,
      );
    }

    dio = Dio(baseOptions);

    if (kDebugMode) {
      print('🌐 DioHelper initialized with base URL: ${NetworkConfig.baseUrl}');
      if (NetworkConfig.isWeb) {
        print('📱 Running on Web platform');
        print('💡 If you get network errors, check NETWORK_TROUBLESHOOTING.md');
      }
    }

    dio.interceptors.add(_AuthInterceptor());
    dio.interceptors.add(_LoggingInterceptor());
    dio.interceptors.add(_ErrorInterceptor());
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get(
      url,
      queryParameters: queryParameters,
      options: options,
    );
  }

  static Future<Response> postData({
    required String url,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  static Future<Response> putData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.put(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.delete(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  static Future<Response> patchData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.patch(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  static Future<Response> uploadFile({
    required String url,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    return await dio.post(
      url,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
    );
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final storageService = getIt<StorageService>();
    final token = await storageService.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {}

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Check if the error is from a login request
      final isLoginRequest = err.requestOptions.path.contains('/login');

      if (!isLoginRequest) {
        // Only clear storage and navigate if it's not a login request
        final storageService = getIt<StorageService>();
        await storageService.clearToken();
        await storageService.clearRefreshToken();
        await storageService.clearSessionId();
        await storageService.clearUserData();

        // Navigate to login page using GoRouter
        // Use Future.microtask to ensure navigation happens on the next frame
        Future.microtask(() {
          AppRouter.router.go(AppRoutes.login);
        });
      }

      handler.next(err);
      return;
    }

    handler.next(err);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('🌐 [REQUEST] ${options.method} ${options.uri}');
      if (options.data != null) {
        print('📦 [REQUEST DATA] ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        print('🔍 [QUERY PARAMS] ${options.queryParameters}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('❌ [ERROR] ${err.type}');
      print('   URL: ${err.requestOptions.uri}');
      print('   Method: ${err.requestOptions.method}');
      if (err.response != null) {
        print('   Status Code: ${err.response?.statusCode}');
        print('   Response Data: ${err.response?.data}');
      } else {
        print('   Message: ${err.message}');
        print('   Error: ${err.error}');
      }
    }
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = AppConstants.unknownError;

    // محاولة استخراج الكود من الاستجابة وترجمته
    final responseData = err.response?.data;
    if (responseData is Map<String, dynamic>) {
      // Try to get code first, fallback to message for backward compatibility
      String? errorCode;
      if (responseData.containsKey('code')) {
        errorCode = responseData['code']?.toString();
      } else if (responseData.containsKey('message')) {
        // Support legacy message field - check if it's a code pattern
        final msg = responseData['message']?.toString();
        if (msg != null && msg.trim().isNotEmpty) {
          if (msg.contains('_') && msg == msg.toUpperCase()) {
            // Looks like a code (e.g., "ORDER_CREATED")
            errorCode = msg;
          } else {
            // It's a regular message, use it directly
            errorMessage = msg;
          }
        }
      }
      
      if (errorCode != null) {
        errorMessage = ResponseCodeTranslator.translate(errorCode);
      }
    } else {
      switch (err.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = AppConstants.timeoutError;
          break;
        case DioExceptionType.badResponse:
          switch (err.response?.statusCode) {
            case 400:
              errorMessage = 'طلب غير صالح. يرجى التحقق من البيانات.';
              break;
            case 401:
              errorMessage = AppConstants.unauthorizedError;
              break;
            case 403:
              errorMessage = 'الدخول مرفوض.';
              break;
            case 404:
              errorMessage = 'المورد غير موجود.';
              break;
            case 500:
              errorMessage = AppConstants.serverError;
              break;
            default:
              errorMessage = 'خطأ HTTP: ${err.response?.statusCode}';
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'تم إلغاء الطلب.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = NetworkConfig.getNetworkErrorMessage(
            AppConstants.networkError,
          );
          if (kDebugMode) {
            print('🚨 Connection Error Details:');
            print('   URL: ${err.requestOptions.uri}');
            print('   Method: ${err.requestOptions.method}');
            print('   Headers: ${err.requestOptions.headers}');
            print('   ${NetworkConfig.getNetworkErrorMessage("")}');
          }
          break;
        default:
          errorMessage = AppConstants.unknownError;
      }
    }

    final customError = DioException(
      requestOptions: err.requestOptions,
      error: errorMessage,
      type: err.type,
      response: err.response,
    );

    handler.next(customError);
  }
}
