import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_code_base/features/authentication/models/user_model.dart';
import 'package:flutter_code_base/features/authentication/repositories/auth_repository.dart';

/// Authentication State
/// Represents the current authentication state of the application
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  /// Initial state
  const AuthState.initial()
    : user = null,
      isLoading = false,
      isAuthenticated = false,
      error = null;

  /// Loading state
  const AuthState.loading()
    : user = null,
      isLoading = true,
      isAuthenticated = false,
      error = null;

  /// Authenticated state
  AuthState.authenticated(UserModel user)
    : user = user,
      isLoading = false,
      isAuthenticated = true,
      error = null;

  /// Error state
  const AuthState.error(String message)
    : user = null,
      isLoading = false,
      isAuthenticated = false,
      error = message;

  /// Copy with method
  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }

  @override
  String toString() {
    return 'AuthState(user: ${user?.email}, isLoading: $isLoading, isAuthenticated: $isAuthenticated, error: $error)';
  }
}

/// Authentication Notifier (ViewModel)
/// Manages authentication state and business logic
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  /// Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    log('AuthNotifier: Checking auth status');
    try {
      final isLoggedIn = await _repository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _repository.getCurrentUser();
        if (user != null) {
          state = AuthState.authenticated(user);
          log('AuthNotifier: User already logged in: ${user.email}');
        }
      }
    } catch (e) {
      log('AuthNotifier: Error checking auth status: $e');
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    log('AuthNotifier: Login attempt for $email');
    state = const AuthState.loading();

    try {
      final user = await _repository.login(email, password);
      state = AuthState.authenticated(user);
      log('AuthNotifier: Login successful');
      return true;
    } catch (e) {
      log('AuthNotifier: Login failed: $e');
      state = AuthState.error(e.toString());
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    log('AuthNotifier: Registration attempt for $email');
    state = const AuthState.loading();

    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
      state = AuthState.authenticated(user);
      log('AuthNotifier: Registration successful');
      return true;
    } catch (e) {
      log('AuthNotifier: Registration failed: $e');
      state = AuthState.error(e.toString());
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    log('AuthNotifier: Logout');
    try {
      await _repository.logout();
      state = const AuthState.initial();
      log('AuthNotifier: Logout successful');
    } catch (e) {
      log('AuthNotifier: Logout error: $e');
      // Still clear state even if API call fails
      state = const AuthState.initial();
    }
  }

  /// Forgot password
  Future<bool> forgotPassword(String email) async {
    log('AuthNotifier: Forgot password for $email');
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.forgotPassword(email);
      state = state.copyWith(isLoading: false);
      log('AuthNotifier: Password reset email sent');
      return true;
    } catch (e) {
      log('AuthNotifier: Forgot password failed: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    log('AuthNotifier: Reset password');
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.resetPassword(token: token, newPassword: newPassword);
      state = state.copyWith(isLoading: false);
      log('AuthNotifier: Password reset successful');
      return true;
    } catch (e) {
      log('AuthNotifier: Reset password failed: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Update user profile
  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ========================== PROVIDER ============================ //

/// Auth Provider
/// Main authentication provider used throughout the app
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

// ========================== HELPER PROVIDERS ============================ //

/// Get current user
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

/// Check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

/// Check if auth is loading
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isLoading;
});

/// Get auth error
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.error;
});
