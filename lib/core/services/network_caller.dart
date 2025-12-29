// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:dio/dio.dart';
// import 'package:flutter_code_base/core/services/storage_service.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart';
// import 'package:http/http.dart' as http;
// import '../models/response_data.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:path/path.dart';

// class NetworkCaller {
//   // 🔒 Singleton pattern
//   NetworkCaller._internal();
//   static final NetworkCaller _instance = NetworkCaller._internal();
//   factory NetworkCaller() => _instance;

//   final Dio _dio = Dio(
//     BaseOptions(
//       connectTimeout: const Duration(seconds: 30),
//       receiveTimeout: const Duration(seconds: 30),
//       contentType: 'application/json',
//     ),
//   );

//   // 🧾 Build headers with optional token
//   Map<String, dynamic> _headers({String? token}) {
//     final savedToken = token ?? StorageService.getToken();
//     final headers = <String, dynamic>{'Content-Type': 'application/json'};

//     log(
//       'NetworkCaller: Retrieved token: ${savedToken != null ? "Present (${savedToken.length} chars)" : "Missing"}',
//     );

//     // Add Authorization header only if token exists
//     if (savedToken != null && savedToken.isNotEmpty) {
//       headers['Authorization'] = 'Bearer $savedToken';
//       log('NetworkCaller: Added Bearer token to headers');
//     } else {
//       log('NetworkCaller: No token available, skipping Authorization header');
//     }

//     return headers;
//   }

//   // ========================== HTTP METHODS ============================ //

//   Future<ResponseData> getRequest(String endpoint, {String? token}) async {
//     log('GET Request: $endpoint');
//     try {
//       final response = await _dio.get(
//         endpoint,
//         options: Options(headers: _headers(token: token)),
//       );
//       return _handleResponse(response);
//     } catch (e) {
//       // Handle 401 error and attempt token refresh (skip for auth endpoints)
//       if (await _shouldRetryWithTokenRefresh(e) && !_isAuthEndpoint(endpoint)) {
//         log('NetworkCaller: Retrying GET request after token refresh');
//         try {
//           final retryResponse = await _dio.get(
//             endpoint,
//             options: Options(headers: _headers(token: token)),
//           );
//           return _handleResponse(retryResponse);
//         } catch (retryError) {
//           return _handleError(retryError);
//         }
//       }
//       return _handleError(e);
//     }
//   }

//   Future<ResponseData> postRequest(
//     String endpoint, {
//     Map<String, dynamic>? body,
//     String? token,
//   }) async {
//     log('POST Request: $endpoint');
//     log('Request Body: ${jsonEncode(body)}');
//     try {
//       final response = await _dio.post(
//         endpoint,
//         data: body,
//         options: Options(headers: _headers(token: token)),
//       );
//       return _handleResponse(response);
//     } catch (e) {
//       // Handle 401 error and attempt token refresh (skip for auth endpoints)
//       if (await _shouldRetryWithTokenRefresh(e) && !_isAuthEndpoint(endpoint)) {
//         log('NetworkCaller: Retrying POST request after token refresh');
//         try {
//           final retryResponse = await _dio.post(
//             endpoint,
//             data: body,
//             options: Options(headers: _headers(token: token)),
//           );
//           return _handleResponse(retryResponse);
//         } catch (retryError) {
//           return _handleError(retryError);
//         }
//       }
//       return _handleError(e);
//     }
//   }

//   Future<ResponseData> patchRequest(
//     String endpoint, {
//     Map<String, dynamic>? body,
//     String? token,
//   }) async {
//     log('PATCH Request: $endpoint');
//     try {
//       final response = await _dio.patch(
//         endpoint,
//         data: body,
//         options: Options(headers: _headers(token: token)),
//       );
//       return _handleResponse(response);
//     } catch (e) {
//       // Handle 401 error and attempt token refresh (skip for auth endpoints)
//       if (await _shouldRetryWithTokenRefresh(e) && !_isAuthEndpoint(endpoint)) {
//         log('NetworkCaller: Retrying PATCH request after token refresh');
//         try {
//           final retryResponse = await _dio.patch(
//             endpoint,
//             data: body,
//             options: Options(headers: _headers(token: token)),
//           );
//           return _handleResponse(retryResponse);
//         } catch (retryError) {
//           return _handleError(retryError);
//         }
//       }
//       return _handleError(e);
//     }
//   }

//   Future<ResponseData> putRequest(
//     String endpoint, {
//     Map<String, dynamic>? body,
//     String? token,
//   }) async {
//     log('PUT Request: $endpoint');
//     try {
//       final response = await _dio.put(
//         endpoint,
//         data: body,
//         options: Options(headers: _headers(token: token)),
//       );
//       return _handleResponse(response);
//     } catch (e) {
//       // Handle 401 error and attempt token refresh (skip for auth endpoints)
//       if (await _shouldRetryWithTokenRefresh(e) && !_isAuthEndpoint(endpoint)) {
//         log('NetworkCaller: Retrying PUT request after token refresh');
//         try {
//           final retryResponse = await _dio.put(
//             endpoint,
//             data: body,
//             options: Options(headers: _headers(token: token)),
//           );
//           return _handleResponse(retryResponse);
//         } catch (retryError) {
//           return _handleError(retryError);
//         }
//       }
//       return _handleError(e);
//     }
//   }

//   Future<ResponseData> deleteRequest(
//     String endpoint, {
//     Map<String, dynamic>? body,
//     String? token,
//   }) async {
//     log('DELETE Request: $endpoint');
//     try {
//       final response = await _dio.delete(
//         endpoint,
//         data: body,
//         options: Options(headers: _headers(token: token)),
//       );
//       return _handleResponse(response);
//     } catch (e) {
//       // Handle 401 error and attempt token refresh (skip for auth endpoints)
//       if (await _shouldRetryWithTokenRefresh(e) && !_isAuthEndpoint(endpoint)) {
//         log('NetworkCaller: Retrying DELETE request after token refresh');
//         try {
//           final retryResponse = await _dio.delete(
//             endpoint,
//             data: body,
//             options: Options(headers: _headers(token: token)),
//           );
//           return _handleResponse(retryResponse);
//         } catch (retryError) {
//           return _handleError(retryError);
//         }
//       }
//       return _handleError(e);
//     }
//   }

//   // ========================== MULTIPART (FILE UPLOAD) ============================ //

//   Future<ResponseData> multipartRequest(
//     String endpoint, {
//     required String filePath,
//     String? token,
//   }) async {
//     log('Multipart Request: $endpoint');

//     final fileExtension = extension(filePath).toLowerCase();
//     String contentType;
//     switch (fileExtension) {
//       case '.jpg':
//       case '.jpeg':
//         contentType = 'image/jpeg';
//         break;
//       case '.png':
//         contentType = 'image/png';
//         break;
//       case '.gif':
//         contentType = 'image/gif';
//         break;
//       default:
//         throw Exception("Unsupported image format: $fileExtension");
//     }

//     final formData = FormData.fromMap({
//       'profile_picture': await MultipartFile.fromFile(
//         filePath,
//         contentType: DioMediaType.parse(contentType),
//       ),
//     });

//     try {
//       final response = await _dio.patch(
//         endpoint,
//         data: formData,
//         options: Options(
//           headers: {
//             ..._headers(token: token),
//             'Content-Type': 'multipart/form-data',
//           },
//         ),
//       );
//       return _handleResponse(response);
//     } catch (e) {
//       // Handle 401 error and attempt token refresh (skip for auth endpoints)
//       if (await _shouldRetryWithTokenRefresh(e) && !_isAuthEndpoint(endpoint)) {
//         log('NetworkCaller: Retrying multipart request after token refresh');
//         try {
//           final retryFormData = FormData.fromMap({
//             'profile_picture': await MultipartFile.fromFile(
//               filePath,
//               contentType: DioMediaType.parse(contentType),
//             ),
//           });

//           final retryResponse = await _dio.patch(
//             endpoint,
//             data: retryFormData,
//             options: Options(
//               headers: {
//                 ..._headers(token: token),
//                 'Content-Type': 'multipart/form-data',
//               },
//             ),
//           );
//           return _handleResponse(retryResponse);
//         } catch (retryError) {
//           return _handleError(retryError);
//         }
//       }
//       return _handleError(e);
//     }
//   }

//   // ========================== RESPONSE HANDLING ============================ //

//   ResponseData _handleResponse(Response response) {
//     log('Response Status: ${response.statusCode}');
//     log('Response Data: ${response.data}');

//     final data = response.data is String
//         ? jsonDecode(response.data)
//         : response.data;

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       // Handle different response formats
//       if (data is List) {
//         // If response is a List (like subscription plans API), it's successful
//         return ResponseData(
//           isSuccess: true,
//           statusCode: response.statusCode!,
//           responseData: data,
//           errorMessage: '',
//         );
//       } else if (data is Map<String, dynamic>) {
//         // Check if success field exists and is true, or if no success field exists (assume success)
//         if (!data.containsKey('success') || data['success'] == true) {
//           return ResponseData(
//             isSuccess: true,
//             statusCode: response.statusCode!,
//             responseData: data,
//             errorMessage: '',
//           );
//         } else {
//           return ResponseData(
//             isSuccess: false,
//             statusCode: response.statusCode!,
//             responseData: data,
//             errorMessage: data['message'] ?? 'Unknown error occurred',
//           );
//         }
//       } else {
//         // For other data types, assume success
//         return ResponseData(
//           isSuccess: true,
//           statusCode: response.statusCode!,
//           responseData: data,
//           errorMessage: '',
//         );
//       }
//     } else if (response.statusCode == 400) {
//       return ResponseData(
//         isSuccess: false,
//         statusCode: response.statusCode!,
//         responseData: data,
//         errorMessage: data is Map<String, dynamic>
//             ? _extractErrorMessages(data['errorSources'])
//             : 'Bad Request',
//       );
//     } else if (response.statusCode == 500) {
//       return ResponseData(
//         isSuccess: false,
//         statusCode: response.statusCode!,
//         responseData: '',
//         errorMessage: data is Map<String, dynamic>
//             ? (data['message'] ?? 'Internal Server Error')
//             : 'Internal Server Error',
//       );
//     } else {
//       return ResponseData(
//         isSuccess: false,
//         statusCode: response.statusCode!,
//         responseData: data,
//         errorMessage: data is Map<String, dynamic>
//             ? (data['message'] ?? 'Unexpected error occurred')
//             : 'Unexpected error occurred',
//       );
//     }
//   }

//   String _extractErrorMessages(dynamic errorSources) {
//     if (errorSources is List) {
//       return errorSources
//           .map((e) => e['message'] ?? 'Unknown error')
//           .join(', ');
//     }
//     return 'Validation error';
//   }

//   // ========================== TOKEN REFRESH HELPERS ============================ //

//   /// Check if the error is 401 and attempt token refresh
//   // Future<bool> _shouldRetryWithTokenRefresh(dynamic error) async {
//   //   if (error is DioException && error.response?.statusCode == 401) {
//   //     log('NetworkCaller: Received 401, attempting token refresh...');

//   //     // Use LoginService to refresh token
//   //     try {
//   //       final loginService = LoginService();
//   //       final refreshResult = await loginService.refreshAccessToken();

//   //       if (refreshResult.isSuccess) {
//   //         log('NetworkCaller: Token refresh successful, will retry request');
//   //         return true;
//   //       } else {
//   //         log(
//   //           'NetworkCaller: Token refresh failed - ${refreshResult.errorMessage}',
//   //         );
//   //         // Clear stored data and force re-login
//   //         await StorageService.clearAllUserData();
//   //         return false;
//   //       }
//   //     } catch (e) {
//   //       log('NetworkCaller: Error during token refresh - $e');
//   //       return false;
//   //     }
//   //   }

//   //   return false;
//   // }

//   /// Check if the endpoint is an auth endpoint (to avoid infinite loops)
//   bool _isAuthEndpoint(String endpoint) {
//     return endpoint.contains('/auth/login/') ||
//         endpoint.contains('/auth/register/') ||
//         endpoint.contains('/auth/logout/') ||
//         endpoint.contains('/auth/token/refresh/');
//   }

//   // ========================== ERROR HANDLING ============================ //

//   ResponseData _handleError(dynamic error) {
//     log('Request Error: $error');

//     if (error is DioException) {
//       switch (error.type) {
//         case DioExceptionType.connectionTimeout:
//         case DioExceptionType.receiveTimeout:
//           return ResponseData(
//             isSuccess: false,
//             statusCode: 408,
//             responseData: '',
//             errorMessage: 'Request timeout. Please try again later.',
//           );

//         case DioExceptionType.badResponse:
//           final statusCode = error.response?.statusCode ?? 500;
//           String errorMessage = 'Server returned an error response.';

//           if (statusCode == 401) {
//             errorMessage = 'Authentication failed. Please login again.';
//           } else if (statusCode == 403) {
//             errorMessage =
//                 'Access forbidden. You may not have permission to access this resource.';
//           } else if (error.response?.data != null &&
//               error.response!.data is Map) {
//             errorMessage =
//                 error.response!.data['message'] ??
//                 error.response!.data['detail'] ??
//                 errorMessage;
//           }

//           log(
//             'NetworkCaller: BadResponse - Status: $statusCode, Message: $errorMessage',
//           );
//           log('NetworkCaller: Response data: ${error.response?.data}');

//           return ResponseData(
//             isSuccess: false,
//             statusCode: statusCode,
//             responseData: error.response?.data ?? '',
//             errorMessage: errorMessage,
//           );

//         case DioExceptionType.connectionError:
//           return ResponseData(
//             isSuccess: false,
//             statusCode: 500,
//             responseData: '',
//             errorMessage:
//                 'Network connection failed. Please check your internet connection.',
//           );

//         default:
//           return ResponseData(
//             isSuccess: false,
//             statusCode: 500,
//             responseData: '',
//             errorMessage: 'Unexpected error occurred.',
//           );
//       }
//     }

//     return ResponseData(
//       isSuccess: false,
//       statusCode: 500,
//       responseData: '',
//       errorMessage: 'Unknown error occurred.',
//     );
//   }
// }
