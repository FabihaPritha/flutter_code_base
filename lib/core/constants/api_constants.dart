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
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // ==================== User Endpoints ====================
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';
  static const String uploadAvatar = '/user/avatar';

  // ==================== Example: Product Endpoints ====================
  static const String products = '/products';
  static String productDetails(String id) => '/products/$id';
  static const String createProduct = '/products';
  static String updateProduct(String id) => '/products/$id';
  static String deleteProduct(String id) => '/products/$id';

  // ==================== Example: Order Endpoints ====================
  static const String orders = '/orders';
  static String orderDetails(String id) => '/orders/$id';
  static const String createOrder = '/orders';
  static String cancelOrder(String id) => '/orders/$id/cancel';

  // ==================== Add Your Endpoints Here ====================
  // static const String yourEndpoint = '/your-endpoint';

  // ==================== Helper Methods ====================

  /// Get full URL for an endpoint
  static String getFullUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint; // Already a full URL
    }
    return '$fullBaseUrl$endpoint';
  }

  /// Get URL with query parameters
  static String getUrlWithParams(String endpoint, Map<String, dynamic> params) {
    final uri = Uri.parse(getFullUrl(endpoint));
    final newUri = uri.replace(
      queryParameters: params.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
    return newUri.toString();
  }
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
