# Architecture Guide: Riverpod + GoRouter

## 🏗️ Recommended Architecture

For **Riverpod + GoRouter**, we recommend **Feature-First Architecture with MVVM pattern**, which is cleaner and more maintainable than traditional MVC for Flutter apps with Riverpod.

### Why Not Traditional MVC with Riverpod?

**Traditional MVC Issues:**
- **Controller** in MVC was tied to GetX's controller concept
- Riverpod doesn't use "Controllers" - it uses **Providers** and **Notifiers**
- MVC's tight coupling doesn't work well with Riverpod's reactive approach

### ✅ Recommended: Feature-First + MVVM

```
lib/
├── core/                           # Shared/Core functionality
│   ├── common/                     # Common widgets
│   │   └── widgets/
│   ├── constants/                  # Constants
│   │   ├── api_constants.dart     # API endpoints
│   │   ├── app_constants.dart     # App-wide constants
│   │   └── image_constants.dart   # Image paths
│   ├── models/                     # Shared models
│   │   └── response_data.dart
│   ├── providers/                  # Global providers
│   │   └── common/
│   │       ├── common_providers.dart
│   │       └── theme_provider.dart
│   ├── services/                   # Services (API, Storage, etc.)
│   │   ├── network_caller.dart
│   │   ├── storage_service.dart
│   │   └── api_service.dart
│   ├── utils/                      # Utilities
│   │   ├── helpers/
│   │   └── device/
│   └── websocketMethod/           # WebSocket
│
├── features/                       # Feature modules
│   ├── authentication/            # Authentication feature
│   │   ├── models/                # Feature-specific models
│   │   │   ├── user_model.dart
│   │   │   └── login_request.dart
│   │   ├── providers/             # Feature providers (ViewModel)
│   │   │   ├── auth_provider.dart
│   │   │   └── auth_state.dart
│   │   ├── repositories/          # Data layer
│   │   │   └── auth_repository.dart
│   │   └── views/                 # UI (View)
│   │       ├── login_screen.dart
│   │       ├── register_screen.dart
│   │       └── widgets/
│   │           └── login_form.dart
│   │
│   └── profile/                   # Profile feature
│       ├── models/
│       ├── providers/
│       ├── repositories/
│       └── views/
│
├── routes/                        # Routing
│   └── app_routes.dart
│
└── main.dart                      # Entry point
```

## 📋 Layer Responsibilities

### 1. **Model** (Data Layer)
- Plain Dart classes representing data
- JSON serialization/deserialization
- Data validation

**Example:**
```dart
class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
```

### 2. **Repository** (Data Source Layer)
- Handles data operations (API calls, local storage)
- Abstracts data sources from business logic
- Returns models to providers

**Example:**
```dart
class AuthRepository {
  final ApiService _apiService;
  
  AuthRepository(this._apiService);

  Future<User> login(String email, String password) async {
    final response = await _apiService.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return User.fromJson(response.data);
  }

  Future<void> logout() async {
    await _apiService.post(ApiConstants.logout);
  }
}
```

### 3. **Provider/Notifier** (ViewModel/Business Logic)
- Manages state
- Contains business logic
- Interacts with repositories
- Notifies UI of state changes

**Example:**
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

// Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _repository.login(email, password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState();
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final repository = AuthRepository(apiService);
  return AuthNotifier(repository);
});
```

### 4. **View** (UI Layer)
- Displays UI
- Listens to providers
- Handles user interactions
- No business logic (only UI logic)

**Example:**
```dart
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen to state changes
    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
      if (next.user != null) {
        context.go('/home');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (authState.isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).login(
                        _emailController.text,
                        _passwordController.text,
                      );
                },
                child: const Text('Login'),
              ),
          ],
        ),
      ),
    );
  }
}
```

## 🔄 Data Flow

```
View (UI)
   ↓ (user action)
Provider/Notifier (ViewModel)
   ↓ (calls)
Repository (Data Source)
   ↓ (API call)
API Service
   ↓ (returns)
Repository
   ↓ (returns Model)
Provider/Notifier (updates state)
   ↓ (notifies)
View (rebuilds)
```

## 📝 Comparison: GetX MVC vs Riverpod MVVM

| Aspect | GetX MVC | Riverpod MVVM |
|--------|----------|---------------|
| **State Management** | GetxController with .obs | StateNotifier with state |
| **UI Rebuild** | Obx(() => ...) | ref.watch(provider) |
| **Dependency Injection** | Get.put(), Get.find() | Providers (automatic) |
| **Navigation** | Get.to() | context.push() |
| **Controller Access** | Get.find<Controller>() | ref.watch(provider) |
| **Reactivity** | .value, .update() | state = newState |

## 🎯 Best Practices

### 1. **Feature Isolation**
Each feature should be self-contained with its own models, providers, repositories, and views.

### 2. **Provider Naming**
```dart
// State class: [Feature]State
class AuthState { }

// Notifier: [Feature]Notifier
class AuthNotifier extends StateNotifier<AuthState> { }

// Provider: [feature]Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);
```

### 3. **Dependency Injection**
```dart
// Service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthRepository(apiService);
});

// State provider (depends on repository)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
```

### 4. **Error Handling**
Always include error states in your state classes:
```dart
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  
  bool get hasError => error != null;
  bool get isAuthenticated => user != null;
}
```

### 5. **Listen vs Watch**
```dart
// Watch - rebuilds widget when state changes
final authState = ref.watch(authProvider);

// Read - for one-time reads (in callbacks)
onPressed: () {
  ref.read(authProvider.notifier).login();
}

// Listen - for side effects (navigation, dialogs)
ref.listen(authProvider, (previous, next) {
  if (next.error != null) {
    showDialog(...);
  }
});
```

## 🚀 Getting Started

1. **Create a new feature:**
   - Create folder structure: `models/`, `providers/`, `repositories/`, `views/`
   - Define your models
   - Create repository for data operations
   - Create state and notifier for business logic
   - Create provider
   - Build UI with ConsumerWidget

2. **Add API endpoints:**
   - Add to `lib/core/constants/api_constants.dart`

3. **Create reusable widgets:**
   - Add to `lib/core/common/widgets/`

## 📚 Resources

- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
