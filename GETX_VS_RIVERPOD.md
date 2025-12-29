# GetX MVC vs Riverpod MVVM - Side-by-Side Comparison

## Overview

This document helps you understand the differences between GetX MVC and Riverpod MVVM patterns.

## Architecture Comparison

### GetX MVC Structure
```
lib/features/authentication/
├── controller/
│   └── auth_controller.dart       # Business logic + state
├── models/
│   └── user_model.dart            # Data
└── views/
    └── login_screen.dart          # UI
```

### Riverpod MVVM Structure
```
lib/features/authentication/
├── models/
│   └── user_model.dart            # Data (Model)
├── repositories/
│   └── auth_repository.dart       # Data operations
├── providers/
│   └── auth_provider.dart         # Business logic + state (ViewModel)
└── views/
    └── login_screen.dart          # UI (View)
```

## Code Comparison

### 1. State Management

#### GetX (Controller)
```dart
class AuthController extends GetxController {
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final response = await apiService.login(email, password);
      user.value = User.fromJson(response.data);
      isLoading.value = false;
    } catch (e) {
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  void logout() {
    user.value = null;
  }
}
```

#### Riverpod (StateNotifier + Provider)
```dart
// State class
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier (like Controller but better)
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.login(email, password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void logout() {
    state = AuthState();
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
```

**Key Differences:**
- ✅ Riverpod: Immutable state with `copyWith`
- ✅ Riverpod: Separate repository layer
- ✅ Riverpod: Automatic dependency injection
- ❌ GetX: Mutable state with `.obs` and `.value`

### 2. UI Implementation

#### GetX (View)
```dart
class LoginScreen extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Email field
          TextField(controller: emailController),
          
          // Password field
          TextField(controller: passwordController),
          
          // Login button with loading state
          Obx(() => controller.isLoading.value
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () {
                    controller.login(
                      emailController.text,
                      passwordController.text,
                    );
                  },
                  child: Text('Login'),
                ),
          ),
          
          // Display user
          Obx(() => controller.user.value != null
              ? Text('Welcome ${controller.user.value!.name}')
              : Text('Not logged in'),
          ),
        ],
      ),
    );
  }
}
```

#### Riverpod (View)
```dart
class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for side effects (navigation, dialogs)
    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      body: Column(
        children: [
          // Email field
          TextField(controller: emailController),
          
          // Password field
          TextField(controller: passwordController),
          
          // Login button with loading state
          authState.isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).login(
                      emailController.text,
                      passwordController.text,
                    );
                  },
                  child: Text('Login'),
                ),
          
          // Display user
          authState.user != null
              ? Text('Welcome ${authState.user!.name}')
              : Text('Not logged in'),
        ],
      ),
    );
  }
}
```

**Key Differences:**
- ✅ Riverpod: `ConsumerWidget` / `ConsumerStatefulWidget`
- ✅ Riverpod: `ref.watch()` for state, `ref.read()` for actions
- ✅ Riverpod: `ref.listen()` for side effects
- ❌ GetX: `Obx()` widget wrapper
- ❌ GetX: `Get.find<Controller>()`

### 3. Dependency Injection

#### GetX
```dart
// Bindings file
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

// In routes
GetPage(
  name: '/login',
  page: () => LoginScreen(),
  binding: AuthBinding(),
)

// Usage in widget
final controller = Get.find<AuthController>();
```

#### Riverpod
```dart
// Provider definition (automatic dependency injection)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // Dependencies are automatically injected through ref
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

// Usage in widget - NO Get.find() needed!
final authState = ref.watch(authProvider);
```

**Key Differences:**
- ✅ Riverpod: Automatic dependency injection, no binding classes needed
- ✅ Riverpod: Compile-time safe
- ❌ GetX: Manual binding setup
- ❌ GetX: Runtime errors if not configured properly

### 4. Navigation

#### GetX
```dart
// Navigate to new screen
Get.to(LoginScreen());

// Named route
Get.toNamed('/login');

// Replace current screen
Get.off(HomeScreen());

// Clear stack and go to screen
Get.offAll(HomeScreen());

// Go back
Get.back();

// Go back with data
Get.back(result: data);
```

#### GoRouter (with Riverpod)
```dart
// Navigate to new screen
context.push('/login');

// Go to screen (replace)
context.go('/login');

// Go back
context.pop();

// Go back with data
context.pop(data);

// Named routes
context.pushNamed('login');

// With parameters
context.push('/profile/123');
context.push('/details', extra: {'id': '123'});
```

**Key Differences:**
- ✅ GoRouter: Web-friendly, deep linking support
- ✅ GoRouter: Type-safe navigation with go_router_builder
- ✅ GoRouter: Better browser history management
- ❌ GetX: Not optimized for web

### 5. Dialogs and Snackbars

#### GetX
```dart
// Snackbar
Get.snackbar('Title', 'Message');

// Dialog
Get.dialog(AlertDialog(content: Text('Hello')));

// Bottom Sheet
Get.bottomSheet(Container());
```

#### Riverpod + Context
```dart
// Snackbar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Message')),
);

// Dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(content: Text('Hello')),
);

// Bottom Sheet
showModalBottomSheet(
  context: context,
  builder: (context) => Container(),
);
```

**Key Differences:**
- ✅ Riverpod: Standard Flutter APIs (better IDE support)
- ✅ Riverpod: More control over dismissal behavior
- ❌ GetX: Custom APIs to learn

## Feature Comparison Table

| Feature | GetX MVC | Riverpod MVVM |
|---------|----------|---------------|
| **State Management** | `.obs` + `.value` | Immutable state + copyWith |
| **Dependency Injection** | Manual bindings | Automatic via providers |
| **Code Safety** | Runtime errors | Compile-time safe |
| **Learning Curve** | Easy (all-in-one) | Moderate (multiple concepts) |
| **Testability** | Good | Excellent |
| **Performance** | Good | Excellent |
| **Community** | Large | Growing fast |
| **Web Support** | Basic | Excellent |
| **Package Size** | Large (all features) | Small (modular) |
| **Flutter Team** | Third-party | Community-approved |
| **Boilerplate** | Less | Slightly more |
| **Type Safety** | Limited | Strong |
| **Separation of Concerns** | Good | Excellent |

## When to Use What?

### Use GetX if:
- ❌ **Not recommended for new projects**
- You have existing GetX codebase
- You need something quick and dirty
- Team is already familiar with GetX

### Use Riverpod if:
- ✅ **Recommended for all new projects**
- Building production apps
- Need strong type safety
- Want best practices
- Building for web
- Team can learn modern patterns

## Migration Path

### Phase 1: Setup (✅ Done)
1. Install Riverpod
2. Wrap app with ProviderScope
3. Setup GoRouter

### Phase 2: Convert Features (In Progress)
1. Convert one feature at a time
2. Create repository layer
3. Convert controller to notifier
4. Update UI to use ConsumerWidget
5. Test thoroughly

### Phase 3: Cleanup
1. Remove GetX dependency
2. Remove old bindings
3. Update all navigation calls
4. Final testing

## Best Practices

### Riverpod MVVM
✅ **DO:**
- Use immutable state classes
- Separate data operations into repositories
- Keep business logic in notifiers
- Use `ref.watch()` in build methods
- Use `ref.read()` in callbacks
- Use `ref.listen()` for side effects
- Create small, focused providers
- Use provider modifiers (family, autoDispose)

❌ **DON'T:**
- Use `ref.watch()` in callbacks
- Mix state management approaches
- Put UI logic in notifiers
- Forget to dispose controllers in StatefulWidget
- Create god providers (too much responsibility)

## Resources

- **Architecture Guide**: `ARCHITECTURE_GUIDE.md`
- **Quick Start**: `QUICK_START.md`
- **Migration Guide**: `MIGRATION_GUIDE.md`
- **Riverpod Docs**: https://riverpod.dev
- **GoRouter Docs**: https://pub.dev/packages/go_router

---

**Remember**: The goal is better code quality, maintainability, and developer experience. Take your time with the migration!
