import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Example: User State Model
class UserState {
  final String? userId;
  final String? username;
  final String? email;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const UserState({
    this.userId,
    this.username,
    this.email,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    String? userId,
    String? username,
    String? email,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Example: User State Notifier
/// Use StateNotifier for complex state with business logic
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  /// Login method
  Future<void> login(String username, String password) async {
    // Set loading state
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Replace with your actual API call
      await Future.delayed(const Duration(seconds: 2)); // Simulating API call

      // Update state on success
      state = state.copyWith(
        userId: '123',
        username: username,
        email: '$username@example.com',
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      // Update state on error
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Logout method
  void logout() {
    state = const UserState();
  }

  /// Update profile
  void updateProfile({String? username, String? email}) {
    state = state.copyWith(username: username, email: email);
  }
}

/// User Provider
/// This is how you create a StateNotifierProvider
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
