import 'dart:developer';
import 'package:flutter_code_base/core/constants/api_constants.dart';
import 'package:flutter_code_base/core/services/network_caller.dart';
import 'package:flutter_code_base/core/services/storage_service.dart';
import 'package:flutter_code_base/features/authentication/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication Repository
/// Handles all authentication-related API calls and data operations
class AuthRepository {
  final NetworkCaller _networkCaller;

  AuthRepository(this._networkCaller);

  /// Login with email and password
  Future<UserModel> login(String email, String password) async {
    log('AuthRepository: Attempting login for $email');

    final request = LoginRequest(email: email, password: password);
    final response = await _networkCaller.postRequest(
      ApiConstants.login,
      body: request.toJson(),
    );

    if (response.isSuccess && response.responseData != null) {
      // Extract token and user data from response
      final token = response.responseData['token'];
      final userData = response.responseData['user'];

      // Save token
      if (token != null) {
        await StorageService.saveToken(token);
        await StorageService.makeLoggedIn();
        log('AuthRepository: Token saved successfully');
      }

      // Parse and return user
      final user = UserModel.fromJson(userData);

      // Save user data
      await _saveUserToStorage(user);

      log('AuthRepository: Login successful for ${user.email}');
      return user;
    } else {
      throw Exception(response.errorMessage ?? 'Login failed');
    }
  }

  /// Register new user
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    log('AuthRepository: Attempting registration for $email');

    final request = RegisterRequest(
      name: name,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );

    final response = await _networkCaller.postRequest(
      ApiConstants.register,
      body: request.toJson(),
    );

    if (response.isSuccess && response.responseData != null) {
      // Extract token and user data
      final token = response.responseData['token'];
      final userData = response.responseData['user'];

      // Save token
      if (token != null) {
        await StorageService.saveToken(token);
        await StorageService.makeLoggedIn();
      }

      // Parse and return user
      final user = UserModel.fromJson(userData);
      await _saveUserToStorage(user);

      log('AuthRepository: Registration successful for ${user.email}');
      return user;
    } else {
      throw Exception(response.errorMessage ?? 'Registration failed');
    }
  }

  /// Logout
  Future<void> logout() async {
    log('AuthRepository: Logging out');

    try {
      // Call logout API (optional)
      await _networkCaller.postRequest(ApiConstants.logout);
    } catch (e) {
      log('AuthRepository: Logout API call failed: $e');
      // Continue with local logout even if API fails
    }

    // Clear local storage
    await StorageService.clearAllUserData();
    log('AuthRepository: Logout successful');
  }

  /// Get current user from storage
  Future<UserModel?> getCurrentUser() async {
    final userId = StorageService.getUserId();
    if (userId == null) return null;

    return UserModel(
      id: userId,
      name: '${StorageService.getFirstName()} ${StorageService.getLastName()}',
      email: StorageService.getEmail() ?? '',
      phoneNumber: StorageService.getPhoneNumber(),
      role: StorageService.getUserRole(),
    );
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    await StorageService.checkLoggedIn();
    return StorageService.isLoggedIn ?? false;
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    log('AuthRepository: Requesting password reset for $email');

    final response = await _networkCaller.postRequest(
      ApiConstants.forgotPassword,
      body: {'email': email},
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Password reset request failed');
    }

    log('AuthRepository: Password reset email sent');
  }

  /// Reset password with token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    log('AuthRepository: Resetting password');

    final response = await _networkCaller.postRequest(
      ApiConstants.resetPassword,
      body: {'token': token, 'newPassword': newPassword},
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Password reset failed');
    }

    log('AuthRepository: Password reset successful');
  }

  /// Save user data to local storage
  Future<void> _saveUserToStorage(UserModel user) async {
    await StorageService.saveUserId(user.id);
    await StorageService.saveEmail(user.email);

    final nameParts = user.name.split(' ');
    if (nameParts.isNotEmpty) {
      await StorageService.saveFirstName(nameParts.first);
      if (nameParts.length > 1) {
        await StorageService.saveLastName(nameParts.sublist(1).join(' '));
      }
    }

    if (user.phoneNumber != null) {
      await StorageService.savePhoneNumber(user.phoneNumber!);
    }

    if (user.role != null) {
      await StorageService.saveUserRole(user.role!);
    }
  }
}

// ========================== PROVIDER ============================ //

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(NetworkCaller());
});
