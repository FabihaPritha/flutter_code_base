import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_code_base/features/authentication/providers/auth_provider.dart';

/// Login View State
/// Holds the state for the login screen
class LoginViewState {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final bool obscurePassword;

  LoginViewState({
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    this.obscurePassword = true,
  });

  LoginViewState copyWith({
    TextEditingController? emailController,
    TextEditingController? passwordController,
    GlobalKey<FormState>? formKey,
    bool? obscurePassword,
  }) {
    return LoginViewState(
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      formKey: formKey ?? this.formKey,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

/// Login ViewModel
/// Manages login screen state and business logic following MVVM pattern
class LoginViewModel extends StateNotifier<LoginViewState> {
  final Ref ref;

  LoginViewModel(this.ref)
    : super(
        LoginViewState(
          emailController: TextEditingController(),
          passwordController: TextEditingController(),
          formKey: GlobalKey<FormState>(),
        ),
      );

  @override
  void dispose() {
    state.emailController.dispose();
    state.passwordController.dispose();
    super.dispose();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Handle login
  Future<bool> login() async {
    if (state.formKey.currentState?.validate() ?? false) {
      final email = state.emailController.text.trim();
      final password = state.passwordController.text;

      // Call login from auth provider
      final success = await ref
          .read(authProvider.notifier)
          .login(email, password);

      return success;
    }
    return false;
  }

  /// Clear error from auth state
  void clearError() {
    ref.read(authProvider.notifier).clearError();
  }
}

// ========================== PROVIDER ============================ //

/// Login ViewModel Provider
final loginViewModelProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, LoginViewState>((ref) {
      return LoginViewModel(ref);
    });
