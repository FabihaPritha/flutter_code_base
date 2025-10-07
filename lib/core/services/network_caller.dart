import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_code_base/core/services/storage_service.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import '../models/response_data.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class NetworkCaller {
  // Singleton pattern for NetworkCaller
  NetworkCaller._internal();
  static final NetworkCaller _instance = NetworkCaller._internal();
  factory NetworkCaller() => _instance;

  final int timeoutDuration = 30;

  // Build headers with optional token
  Map<String, String> _headers({String? token}) {
    final savedToken = token ?? StorageService.getToken();
    return {
      'Authorization': savedToken ?? '',
      'Content-type': 'application/json',
    };
  }

  // GET request method
  Future<ResponseData> getRequest(String endpoint, {String? token}) async {
    log('GET Request: $endpoint');
    try {
      final response = await get(
        Uri.parse(endpoint),
        headers: _headers(token: token),
      ).timeout(Duration(seconds: timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // POST request method
  Future<ResponseData> postRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('POST Request: $endpoint');
    log('Request Body: ${jsonEncode(body)}');

    try {
      final response = await post(
        Uri.parse(endpoint),
        headers: _headers(token: token),
        body: jsonEncode(body),
      ).timeout(Duration(seconds: timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // PATCH request method
  Future<ResponseData> patchRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('PATCH Request: $endpoint');
    log('Request Body: ${jsonEncode(body)}');

    try {
      final response = await patch(
        Uri.parse(endpoint),
        headers: _headers(token: token),
        body: jsonEncode(body),
      ).timeout(Duration(seconds: timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // PUT request method
  Future<ResponseData> putRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('PUT Request: $endpoint');
    log('Request Body: ${jsonEncode(body)}');

    try {
      final response = await put(
        Uri.parse(endpoint),
        headers: _headers(token: token),
        body: jsonEncode(body),
      ).timeout(Duration(seconds: timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // DELETE request method
  Future<ResponseData> deleteRequest(String endpoint, {String? token}) async {
    log('DELETE Request: $endpoint');

    try {
      final response = await delete(
        Uri.parse(endpoint),
        headers: _headers(token: token),
      ).timeout(Duration(seconds: timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // General method for multipart requests (for file uploads like images)
  Future<ResponseData> multipartRequest(
    String endpoint, {
    required String filePath,
    String? token,
  }) async {
    log('Multipart Request: $endpoint');

    // Create the multipart request
    var request = http.MultipartRequest('PATCH', Uri.parse(endpoint));
    request.headers['Authorization'] = token ?? '';

    String fileExtension = extension(filePath).toLowerCase();
    String contentType;
    switch (fileExtension) {
      case '.jpg':
      case '.jpeg':
        contentType = 'image/jpeg';
        break;
      case '.png':
        contentType = 'image/png';
        break;
      case '.gif':
        contentType = 'image/gif';
        break;
      default:
        throw Exception("Unsupported image format: $fileExtension");
    }

    var imageFile = await http.MultipartFile.fromPath(
      'image',
      filePath,
      contentType: MediaType.parse(contentType),
    );
    request.files.add(imageFile);

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        log('Response Body: $responseBody');
        return ResponseData(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: jsonDecode(responseBody),
          errorMessage: '',
        );
      } else {
        log('Error response: ${response.statusCode}');
        return ResponseData(
          isSuccess: false,
          statusCode: response.statusCode,
          responseData: '',
          errorMessage: 'Failed to upload image: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('Error: $e');
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        responseData: '',
        errorMessage: 'An unexpected error occurred while uploading the image.',
      );
    }
  }

  // Handle successful response
  ResponseData _handleResponse(Response response) {
    log('Response Status: ${response.statusCode}');
    log('Response Body: ${response.body}');

    final decodedResponse = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decodedResponse['success'] == true) {
        return ResponseData(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: decodedResponse,
          errorMessage: '',
        );
      } else {
        return ResponseData(
          isSuccess: false,
          statusCode: response.statusCode,
          responseData: decodedResponse,
          errorMessage: decodedResponse['message'] ?? 'Unknown error occurred',
        );
      }
    } else if (response.statusCode == 400) {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: _extractErrorMessages(decodedResponse['errorSources']),
      );
    } else if (response.statusCode == 500) {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: '',
        errorMessage:
            decodedResponse['message'] ?? 'An unexpected error occurred!',
      );
    } else {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: decodedResponse['message'] ?? 'An unknown error occurred',
      );
    }
  }

  // Handle error responses
  String _extractErrorMessages(dynamic errorSources) {
    if (errorSources is List) {
      return errorSources
          .map((error) => error['message'] ?? 'Unknown error')
          .join(', ');
    }
    return 'Validation error';
  }

  // Handle any exception or network errors
  ResponseData _handleError(dynamic error) {
    log('Request Error: $error');

    if (error is ClientException) {
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        responseData: '',
        errorMessage: 'Network error occurred. Please check your connection.',
      );
    } else if (error is TimeoutException) {
      return ResponseData(
        isSuccess: false,
        statusCode: 408,
        responseData: '',
        errorMessage: 'Request timeout. Please try again later.',
      );
    } else {
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        responseData: '',
        errorMessage: 'Unexpected error occurred.',
      );
    }
  }
}
