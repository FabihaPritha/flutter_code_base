/// API Constants
/// All API endpoints should be defined here
class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://api.example.com';

  // API Version
  static const String apiVersion = '/api/v1';

  // Full Base URL
  static const String fullBaseUrl = '$baseUrl$apiVersion';

  // ==================== Authentication Endpoints ====================
  static const String login = '$fullBaseUrl/auth/login';
  static const String register = '$fullBaseUrl/auth/register';
  static const String logout = '$fullBaseUrl/auth/logout';
  static const String refreshToken = '$fullBaseUrl/auth/refresh';
  static const String forgotPassword = '$fullBaseUrl/auth/forgot-password';
  static const String resetPassword = '$fullBaseUrl/auth/reset-password';
  static const String verifyEmail = '$fullBaseUrl/auth/verify-email';

  // ==================== User Endpoints ====================
  static const String userProfile = '$fullBaseUrl/user/profile';
  static const String updateProfile = '$fullBaseUrl/user/profile';
  static const String changePassword = '$fullBaseUrl/user/change-password';
  static const String uploadAvatar = '$fullBaseUrl/user/avatar';

  // ==================== Example: Product Endpoints ====================
  static const String products = '$fullBaseUrl/products';
  static String productDetails(String id) => '$fullBaseUrl/products/$id';
  static const String createProduct = '$fullBaseUrl/products';
  static String updateProduct(String id) => '$fullBaseUrl/products/$id';
  static String deleteProduct(String id) => '$fullBaseUrl/products/$id';

  // ==================== Example: Order Endpoints ====================
  static const String orders = '$fullBaseUrl/orders';
  static String orderDetails(String id) => '$fullBaseUrl/orders/$id';
  static const String createOrder = '$fullBaseUrl/orders';
  static String cancelOrder(String id) => '$fullBaseUrl/orders/$id/cancel';

  // ==================== Add Your Endpoints Here ====================
  // static const String yourEndpoint = '$fullBaseUrl/your-endpoint';

  // ==================== Helper Methods ====================

  /// Get full URL for an endpoint
  // static String getFullUrl(String endpoint) {
  //   if (endpoint.startsWith('http')) {
  //     return endpoint; // Already a full URL
  //   }
  //   return '$fullBaseUrl$endpoint';
  // }

  /// Get URL with query parameters
  // static String getUrlWithParams(String endpoint, Map<String, dynamic> params) {
  //   final uri = Uri.parse(getFullUrl(endpoint));
  //   final newUri = uri.replace(
  //     queryParameters: params.map(
  //       (key, value) => MapEntry(key, value.toString()),
  //     ),
  //   );
  //   return newUri.toString();
  // }
}

/// API Response Codes
class ApiResponseCodes {
  static const int success = 200;
  static const int created = 201;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int serverError = 500;
}

/// API Headers
class ApiHeaders {
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String accept = 'Accept';

  static const String applicationJson = 'application/json';
  static const String multipartFormData = 'multipart/form-data';

  /// Get default headers
  static Map<String, String> get defaultHeaders => {
    contentType: applicationJson,
    accept: applicationJson,
  };

  /// Get authorized headers
  static Map<String, String> getAuthorizedHeaders(String token) => {
    ...defaultHeaders,
    authorization: 'Bearer $token',
  };
}

/// API Timeouts
class ApiTimeouts {
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
