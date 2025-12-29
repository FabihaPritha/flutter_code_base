import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_code_base/core/constants/api_constants.dart';
import 'package:flutter_code_base/core/models/response_data.dart';
import 'package:flutter_code_base/core/services/storage_service.dart';

/// API Service using Dio
/// Handles all HTTP requests with automatic token management and error handling
class ApiService {
  final Dio _dio;

  ApiService({required Dio dio}) : _dio = dio {
    _setupInterceptors();
  }

  /// Setup Dio interceptors for request/response/error handling
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to headers if available
          final token = StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            log('ApiService: Added Bearer token to request');
          }

          log('ApiService: ${options.method} ${options.path}');
          if (options.data != null) {
            log('ApiService: Request Body: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          log(
            'ApiService: Response [${response.statusCode}] ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) async {
          log(
            'ApiService: Error [${error.response?.statusCode}] ${error.requestOptions.path}',
          );

          // Handle 401 Unauthorized - Token expired
          if (error.response?.statusCode == 401) {
            log('ApiService: Token expired, attempting refresh...');

            // Try to refresh token
            final refreshed = await _attemptTokenRefresh();
            if (refreshed) {
              // Retry the original request
              log('ApiService: Retrying request after token refresh');
              return handler.resolve(await _retry(error.requestOptions));
            } else {
              // Refresh failed, logout user
              log('ApiService: Token refresh failed, logging out');
              await StorageService.clearAll();
              // You can trigger navigation to login here using a global navigation key
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Attempt to refresh the authentication token
  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = StorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        log('ApiService: No refresh token available');
        return false;
      }

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newToken = response.data['token'];
        final newRefreshToken = response.data['refresh_token'];

        if (newToken != null) {
          await StorageService.saveToken(newToken);
          if (newRefreshToken != null) {
            await StorageService.saveRefreshToken(newRefreshToken);
          }
          log('ApiService: Token refreshed successfully');
          return true;
        }
      }

      return false;
    } catch (e) {
      log('ApiService: Token refresh error: $e');
      return false;
    }
  }

  /// Retry a failed request
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Handle Dio response and convert to ResponseData
  ResponseData _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return ResponseData(
        isSuccess: true,
        statusCode: response.statusCode!,
        responseData: response.data,
      );
    } else {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode!,
        responseData: response.data,
        errorMessage: response.statusMessage ?? 'Request failed',
      );
    }
  }

  /// Handle Dio errors
  ResponseData _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ResponseData(
            isSuccess: false,
            statusCode: 408,
            errorMessage: 'Request timeout. Please try again.',
          );

        case DioExceptionType.badResponse:
          return ResponseData(
            isSuccess: false,
            statusCode: error.response?.statusCode ?? 500,
            responseData: error.response?.data,
            errorMessage:
                error.response?.data?['message'] ??
                error.response?.statusMessage ??
                'Server error',
          );

        case DioExceptionType.cancel:
          return ResponseData(
            isSuccess: false,
            statusCode: 499,
            errorMessage: 'Request cancelled',
          );

        case DioExceptionType.connectionError:
          return ResponseData(
            isSuccess: false,
            statusCode: 503,
            errorMessage: 'No internet connection. Please check your network.',
          );

        default:
          return ResponseData(
            isSuccess: false,
            statusCode: 500,
            errorMessage: error.message ?? 'An unknown error occurred',
          );
      }
    }

    return ResponseData(
      isSuccess: false,
      statusCode: 500,
      errorMessage: error.toString(),
    );
  }

  // ========================== HTTP METHODS ============================ //

  /// GET request
  Future<ResponseData> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final url = ApiConstants.createOrder;
      final response = await _dio.get(url, queryParameters: queryParameters);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// POST request
  Future<ResponseData> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final url = ApiConstants.createOrder;
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// PUT request
  Future<ResponseData> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final url = ApiConstants.createOrder;
      final response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// PATCH request
  Future<ResponseData> patch(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final url = ApiConstants.createOrder;
      final response = await _dio.patch(
        url,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// DELETE request
  Future<ResponseData> delete(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final url = ApiConstants.createOrder;
      final response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Upload file (multipart)
  Future<ResponseData> uploadFile(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final url = ApiConstants.createOrder;
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Download file
  Future<ResponseData> downloadFile(
    String endpoint,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final url = ApiConstants.createOrder;
      final response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
}

// ========================== PROVIDERS ============================ //

/// Dio Provider
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConstants.fullBaseUrl,
      connectTimeout: ApiTimeouts.connectTimeout,
      receiveTimeout: ApiTimeouts.receiveTimeout,
      sendTimeout: ApiTimeouts.sendTimeout,
      headers: ApiHeaders.defaultHeaders,
    ),
  );
});

/// Storage Service Provider
/// Note: StorageService uses static methods, so we don't need an instance provider

/// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio: dio);
});
