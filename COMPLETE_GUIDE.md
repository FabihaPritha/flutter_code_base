# Complete Guide: Flutter with GoRouter + Riverpod (MVVM Pattern)

> **A comprehensive guide for developers migrating from GetX to GoRouter + Riverpod, or starting fresh with modern Flutter architecture.**

---

## 📚 Table of Contents

1. [Architecture Overview](#-architecture-overview)
2. [Understanding MVVM Pattern](#-understanding-mvvm-pattern)
3. [Complete Flow Explanation](#-complete-flow-explanation)
4. [GetX vs GoRouter + Riverpod](#-getx-vs-gorouter--riverpod)
5. [Project Structure](#-project-structure)
6. [Step-by-Step Implementation](#-step-by-step-implementation)
7. [Network Layer (NetworkCaller)](#-network-layer-networkcaller)
8. [Real-World Examples](#-real-world-examples)
9. [Best Practices](#-best-practices)
10. [Common Mistakes & Solutions](#-common-mistakes--solutions)
11. [Migration Checklist](#-migration-checklist)

---

## 🏗️ Architecture Overview

### What is MVVM?

**MVVM** stands for **Model-View-ViewModel**, a software architectural pattern that separates the development of the graphical user interface from the business logic.

```
┌─────────────────────────────────────────────────┐
│                    VIEW (UI)                     │
│  • Screens, Widgets                             │
│  • Displays data                                │
│  • Handles user interactions                    │
│  • NO business logic                            │
└─────────────────┬───────────────────────────────┘
                  │ watches/reads
                  ↓
┌─────────────────────────────────────────────────┐
│              VIEWMODEL (Provider)                │
│  • StateNotifier/Notifier                       │
│  • Business logic                               │
│  • State management                             │
│  • Communicates with Repository                 │
└─────────────────┬───────────────────────────────┘
                  │ calls
                  ↓
┌─────────────────────────────────────────────────┐
│              REPOSITORY (Data Layer)             │
│  • Data operations                              │
│  • API calls via NetworkCaller                  │
│  • Local storage operations                     │
│  • Returns models                               │
└─────────────────┬───────────────────────────────┘
                  │ uses
                  ↓
┌─────────────────────────────────────────────────┐
│                MODEL (Data)                      │
│  • Plain Dart classes                           │
│  • Data structures                              │
│  • JSON serialization                           │
└─────────────────────────────────────────────────┘
```

### Why MVVM over MVC for Riverpod?

| Aspect | MVC (GetX) | MVVM (Riverpod) |
|--------|------------|-----------------|
| **Separation** | Controller handles both business logic and UI updates | Clear separation: ViewModel for logic, View for UI |
| **Testability** | Harder to test due to tight coupling | Excellent - can test ViewModel without UI |
| **Reactivity** | Uses `.obs` and `.value` | Immutable state with `copyWith` |
| **State Management** | Mutable state | Immutable state (safer) |
| **Dependency Injection** | Manual bindings | Automatic via providers |
| **Reusability** | Moderate | High - ViewModels are UI-independent |

---

## 🔄 Complete Flow Explanation

Let's understand how data flows through the application with a **Login Feature** example:

### The Complete Journey

```
┌──────────────────────────────────────────────────────────────┐
│ 1. USER ACTION (View Layer)                                  │
│                                                               │
│  LoginScreen (ConsumerWidget)                                │
│  ├─ User enters email & password                            │
│  ├─ User taps "Login" button                                │
│  └─ Calls: ref.read(authProvider.notifier).login(...)       │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────┐
│ 2. VIEWMODEL LAYER (Provider/Notifier)                       │
│                                                               │
│  AuthNotifier extends StateNotifier<AuthState>               │
│  ├─ Receives login request                                   │
│  ├─ Updates state: isLoading = true                          │
│  ├─ Calls repository: _repository.login(email, password)     │
│  └─ Waits for response...                                    │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────┐
│ 3. REPOSITORY LAYER (Data Source)                            │
│                                                               │
│  AuthRepository                                               │
│  ├─ Receives login request from ViewModel                    │
│  ├─ Prepares data: {'email': email, 'password': password}   │
│  ├─ Calls NetworkCaller: _networkCaller.postRequest(...)    │
│  └─ Waits for API response...                                │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────┐
│ 4. NETWORK LAYER (NetworkCaller)                             │
│                                                               │
│  NetworkCaller                                                │
│  ├─ Makes HTTP POST request to API                           │
│  ├─ Adds authentication headers automatically                │
│  ├─ Handles token refresh if needed                          │
│  ├─ Returns ResponseData object                              │
│  └─ Contains: isSuccess, responseData, errorMessage          │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────┐
│ 5. BACK TO REPOSITORY (Parse Response)                       │
│                                                               │
│  AuthRepository                                               │
│  ├─ Receives ResponseData from NetworkCaller                 │
│  ├─ Checks: response.isSuccess?                              │
│  ├─ Parses JSON: User.fromJson(response.responseData)        │
│  └─ Returns User model to ViewModel                          │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────┐
│ 6. BACK TO VIEWMODEL (Update State)                          │
│                                                               │
│  AuthNotifier                                                 │
│  ├─ Receives User model from repository                      │
│  ├─ Updates state: AuthState(                                │
│  │    user: user,                                            │
│  │    isLoading: false,                                      │
│  │    isAuthenticated: true                                  │
│  │  )                                                         │
│  └─ Notifies all listeners (Views watching this provider)    │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────┐
│ 7. VIEW UPDATES (UI Rebuilds)                                │
│                                                               │
│  LoginScreen (ConsumerWidget)                                │
│  ├─ ref.watch(authProvider) detects state change             │
│  ├─ build() method is called automatically                   │
│  ├─ UI updates:                                              │
│  │   • Hides loading spinner                                 │
│  │   • Shows success message                                 │
│  │   • Navigates to home screen                              │
│  └─ User sees the result!                                    │
└──────────────────────────────────────────────────────────────┘
```

### Code Walkthrough

#### Step 1: View (LoginScreen)

```dart
// lib/features/authentication/views/login_screen.dart

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // WATCH: Listen to state changes and rebuild UI
    final authState = ref.watch(authProvider);

    // LISTEN: Side effects (navigation, dialogs, snackbars)
    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
      if (next.isAuthenticated) {
        context.go('/home'); // Navigate using GoRouter
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
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            
            // Show loading or button
            authState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      // READ: Call action (doesn't rebuild)
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

#### Step 2: ViewModel (AuthProvider)

```dart
// lib/features/authentication/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

// STATE CLASS (holds all the data)
class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  // copyWith: Creates a new state with updated values
  AuthState copyWith({
    User? user,
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
}

// NOTIFIER (business logic)
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState());

  // Login method
  Future<void> login(String email, String password) async {
    // Step 1: Set loading state
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Step 2: Call repository
      final user = await _repository.login(email, password);
      
      // Step 3: Update state on success
      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );
    } catch (e) {
      // Step 4: Update state on error
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Logout method
  Future<void> logout() async {
    await _repository.logout();
    state = AuthState(); // Reset to initial state
  }
}

// PROVIDER (connects ViewModel to UI)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
```

#### Step 3: Repository (AuthRepository)

```dart
// lib/features/authentication/repositories/auth_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/network_caller.dart';
import '../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final NetworkCaller _networkCaller;

  AuthRepository(this._networkCaller);

  // Login method
  Future<User> login(String email, String password) async {
    // Step 1: Prepare request data
    final requestData = {
      'email': email,
      'password': password,
    };

    // Step 2: Make API call
    final response = await _networkCaller.postRequest(
      ApiConstants.login,
      body: requestData,
    );

    // Step 3: Check response
    if (response.isSuccess && response.responseData != null) {
      // Parse and return user
      return User.fromJson(response.responseData['user']);
    } else {
      // Throw error
      throw Exception(response.errorMessage ?? 'Login failed');
    }
  }

  // Logout method
  Future<void> logout() async {
    final response = await _networkCaller.postRequest(
      ApiConstants.logout,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Logout failed');
    }
  }
}

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(NetworkCaller());
});
```

#### Step 4: Model (User)

```dart
// lib/features/authentication/models/user_model.dart

class User {
  final String id;
  final String email;
  final String name;
  final String? avatar;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
  });

  // From JSON (parsing API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
    );
  }

  // To JSON (sending data to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
    };
  }
}
```

---

## 🆚 GetX vs GoRouter + Riverpod

### Complete Comparison Table

| Feature | GetX | GoRouter + Riverpod |
|---------|------|---------------------|
| **Widget Type** | `StatelessWidget` / `StatefulWidget` | `ConsumerWidget` / `ConsumerStatefulWidget` |
| **State Management** | `GetxController` with `.obs` | `StateNotifier` with immutable state |
| **Observing State** | `Obx(() => ...)` or `GetBuilder` | `ref.watch(provider)` |
| **Reading State** | `controller.variable.value` | `ref.watch(provider)` |
| **Updating State** | `variable.value = newValue` | `state = state.copyWith(...)` |
| **Side Effects** | In controller or `ever()` | `ref.listen(provider, ...)` |
| **Dependency Injection** | `Get.put()` / `Get.lazyPut()` | Automatic via providers |
| **Finding Dependencies** | `Get.find<Controller>()` | `ref.watch(provider)` |
| **Navigation** | `Get.to()` / `Get.toNamed()` | `context.push()` / `context.go()` |
| **Go Back** | `Get.back()` | `context.pop()` |
| **Pass Data** | Arguments or parameters | Route parameters or `extra` |
| **Dialogs** | `Get.dialog()` | `showDialog(context, ...)` |
| **Snackbars** | `Get.snackbar()` | `ScaffoldMessenger.of(context)` |
| **Bottom Sheets** | `Get.bottomSheet()` | `showModalBottomSheet(context, ...)` |
| **Binding** | `Binding` class | Not needed |
| **Type Safety** | Limited (runtime) | Strong (compile-time) |
| **Web Support** | Basic | Excellent with deep linking |
| **Testing** | Good | Excellent |
| **Learning Curve** | Easy | Moderate |

### Side-by-Side Code Comparison

#### 1. Widget Declaration

```dart
// ❌ GetX
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyController>();
    return Obx(() => Text(controller.count.value.toString()));
  }
}

// ✅ GoRouter + Riverpod
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text(count.toString());
  }
}
```

#### 2. State Management

```dart
// ❌ GetX Controller
class CounterController extends GetxController {
  final count = 0.obs;
  
  void increment() {
    count.value++;
  }
}

// Usage
final controller = Get.put(CounterController());
Obx(() => Text('${controller.count.value}'));

// ✅ Riverpod Provider
final counterProvider = StateProvider<int>((ref) => 0);

// Usage
final count = ref.watch(counterProvider);
ref.read(counterProvider.notifier).state++;
```

#### 3. Complex State

```dart
// ❌ GetX
class UserController extends GetxController {
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  
  void updateUser(User newUser) {
    user.value = newUser;
  }
}

// ✅ Riverpod
class UserState {
  final User? user;
  final bool isLoading;
  
  UserState({this.user, this.isLoading = false});
  
  UserState copyWith({User? user, bool? isLoading}) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState());
  
  void updateUser(User user) {
    state = state.copyWith(user: user);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
```

#### 4. Navigation

```dart
// ❌ GetX Navigation
Get.to(ProfileScreen());
Get.toNamed('/profile');
Get.toNamed('/profile', arguments: {'id': '123'});
Get.back();
Get.back(result: data);
Get.off(LoginScreen());
Get.offAll(HomeScreen());

// ✅ GoRouter Navigation
context.push('/profile');
context.go('/profile');
context.push('/profile', extra: {'id': '123'});
context.pop();
context.pop(data);
context.go('/login');
context.go('/home');
```

#### 5. Dependency Injection

```dart
// ❌ GetX Binding
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

GetPage(
  name: '/home',
  page: () => HomeScreen(),
  binding: HomeBinding(),
)

// ✅ Riverpod (Automatic)
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  // Dependencies automatically injected via ref
  final repository = ref.watch(repositoryProvider);
  return HomeNotifier(repository);
});

// No binding needed!
```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # Entry point with ProviderScope
├── app.dart                           # App configuration
│
├── core/                              # Shared/Core functionality
│   ├── common/
│   │   └── widgets/                   # Reusable widgets
│   │       ├── custom_button.dart
│   │       └── loading_indicator.dart
│   │
│   ├── constants/
│   │   ├── api_constants.dart         # API endpoints
│   │   ├── app_constants.dart         # App-wide constants
│   │   └── image_constants.dart       # Image paths
│   │
│   ├── models/                        # Shared models
│   │   └── response_data.dart
│   │
│   ├── providers/                     # Global providers
│   │   └── common/
│   │       ├── theme_provider.dart
│   │       └── connectivity_provider.dart
│   │
│   ├── services/                      # Services
│   │   ├── network_caller.dart        # HTTP client
│   │   ├── storage_service.dart       # Local storage
│   │   └── logger_service.dart        # Logging
│   │
│   └── utils/                         # Utilities
│       ├── helpers/
│       │   └── app_helper.dart
│       └── device/
│           └── device_utility.dart
│
├── features/                          # Feature modules
│   │
│   ├── authentication/                # Authentication feature
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   └── login_request.dart
│   │   │
│   │   ├── repositories/
│   │   │   └── auth_repository.dart   # Data operations
│   │   │
│   │   ├── providers/
│   │   │   └── auth_provider.dart     # Business logic (ViewModel)
│   │   │
│   │   └── views/
│   │       ├── login_screen.dart
│   │       ├── register_screen.dart
│   │       └── widgets/
│   │           └── login_form.dart
│   │
│   ├── home/                          # Home feature
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── providers/
│   │   └── views/
│   │
│   └── profile/                       # Profile feature
│       ├── models/
│       ├── repositories/
│       ├── providers/
│       └── views/
│
└── routes/                            # Routing
    └── app_routes.dart                # GoRouter configuration
```

---

## 🚀 Step-by-Step Implementation

### Step 1: Setup Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.6.1
  
  # Routing
  go_router: ^14.7.0
  
  # Network
  dio: ^5.4.0
  
  # Storage
  shared_preferences: ^2.2.2
```

### Step 2: Setup Main App

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(
    // Wrap with ProviderScope (required for Riverpod)
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: AppRoutes.router, // GoRouter configuration
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### Step 3: Setup Routing

```dart
// lib/routes/app_routes.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../features/authentication/views/login_screen.dart';
import '../features/home/views/home_screen.dart';

class AppRoutes {
  // Route paths
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';

  // GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '$profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
    ],
    
    // Redirect logic (authentication guard)
    redirect: (context, state) {
      // Add your authentication logic here
      return null; // No redirect
    },
  );
}
```

### Step 4: Create a Feature (Complete Example)

Let's create a **Product List** feature:

#### 4.1: Model

```dart
// lib/features/products/models/product_model.dart

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
```

#### 4.2: Repository

```dart
// lib/features/products/repositories/product_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/network_caller.dart';
import '../../../core/constants/api_constants.dart';
import '../models/product_model.dart';

class ProductRepository {
  final NetworkCaller _networkCaller;

  ProductRepository(this._networkCaller);

  Future<List<Product>> getProducts() async {
    final response = await _networkCaller.getRequest(
      ApiConstants.products,
    );

    if (response.isSuccess && response.responseData != null) {
      final List<dynamic> data = response.responseData['products'];
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception(response.errorMessage ?? 'Failed to load products');
    }
  }

  Future<Product> getProductById(String id) async {
    final response = await _networkCaller.getRequest(
      '${ApiConstants.products}/$id',
    );

    if (response.isSuccess && response.responseData != null) {
      return Product.fromJson(response.responseData);
    } else {
      throw Exception(response.errorMessage ?? 'Failed to load product');
    }
  }
}

// Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(NetworkCaller());
});
```

#### 4.3: Provider (ViewModel)

```dart
// lib/features/products/providers/product_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

// State class
class ProductListState {
  final List<Product> products;
  final bool isLoading;
  final String? error;

  ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.error,
  });

  ProductListState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier
class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductRepository _repository;

  ProductListNotifier(this._repository) : super(ProductListState()) {
    loadProducts(); // Load on initialization
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final products = await _repository.getProducts();
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshProducts() async {
    await loadProducts();
  }
}

// Provider
final productListProvider = 
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductListNotifier(repository);
});

// Single product provider (using family)
final productDetailProvider = 
    FutureProvider.family<Product, String>((ref, id) async {
  final repository = ref.read(productRepositoryProvider);
  return await repository.getProductById(id);
});
```

#### 4.4: View

```dart
// lib/features/products/views/product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(productListProvider.notifier).refreshProducts();
            },
          ),
        ],
      ),
      body: _buildBody(context, ref, productState),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ProductListState state,
  ) {
    if (state.isLoading && state.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(productListProvider.notifier).refreshProducts();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(productListProvider.notifier).refreshProducts();
      },
      child: ListView.builder(
        itemCount: state.products.length,
        itemBuilder: (context, index) {
          final product = state.products[index];
          return ListTile(
            leading: product.imageUrl != null
                ? Image.network(product.imageUrl!, width: 50, height: 50)
                : const Icon(Icons.image),
            title: Text(product.name),
            subtitle: Text('\$${product.price}'),
            onTap: () {
              context.push('/products/${product.id}');
            },
          );
        },
      ),
    );
  }
}
```

---

## 🌐 Network Layer (NetworkCaller)

### Understanding NetworkCaller

NetworkCaller is a wrapper around Dio that provides:
- ✅ Automatic token management
- ✅ Token refresh on expiry
- ✅ Comprehensive error handling
- ✅ Request/response logging
- ✅ File upload/download support

### NetworkCaller Methods

```dart
// GET Request
final response = await networkCaller.getRequest(
  '/api/products',
  queryParameters: {'page': 1, 'limit': 10},
);

// POST Request
final response = await networkCaller.postRequest(
  '/api/products',
  body: {'name': 'Product', 'price': 99.99},
);

// PUT Request (full update)
final response = await networkCaller.putRequest(
  '/api/products/123',
  body: {'name': 'Updated Product', 'price': 199.99},
);

// PATCH Request (partial update)
final response = await networkCaller.patchRequest(
  '/api/products/123',
  body: {'price': 149.99},
);

// DELETE Request
final response = await networkCaller.deleteRequest(
  '/api/products/123',
);

// File Upload (Multipart)
final response = await networkCaller.multipartRequest(
  '/api/upload',
  filePath: '/path/to/image.jpg',
  additionalData: {'description': 'Product image'},
);

// File Download
final response = await networkCaller.downloadFile(
  '/api/download/invoice.pdf',
  savePath: '/path/to/save/invoice.pdf',
);
```

### ResponseData Structure

```dart
class ResponseData {
  final bool isSuccess;
  final int statusCode;
  final dynamic responseData;
  final String? errorMessage;

  ResponseData({
    required this.isSuccess,
    required this.statusCode,
    this.responseData,
    this.errorMessage,
  });
}
```

### Using NetworkCaller in Repository

```dart
class UserRepository {
  final NetworkCaller _networkCaller;

  UserRepository(this._networkCaller);

  Future<User> getUserProfile() async {
    final response = await _networkCaller.getRequest(
      ApiConstants.userProfile,
    );

    if (response.isSuccess && response.responseData != null) {
      return User.fromJson(response.responseData);
    } else {
      throw Exception(response.errorMessage ?? 'Failed to load profile');
    }
  }

  Future<User> updateProfile(Map<String, dynamic> updates) async {
    final response = await _networkCaller.patchRequest(
      ApiConstants.userProfile,
      body: updates,
    );

    if (response.isSuccess && response.responseData != null) {
      return User.fromJson(response.responseData);
    } else {
      throw Exception(response.errorMessage ?? 'Failed to update profile');
    }
  }
}
```

---

## 💡 Real-World Examples

### Example 1: Form with Validation

```dart
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/home');
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || !value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            authState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(authProvider.notifier).register(
                              _nameController.text,
                              _emailController.text,
                              _passwordController.text,
                            );
                      }
                    },
                    child: const Text('Register'),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

### Example 2: List with Pull-to-Refresh

```dart
class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoState = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(todoListProvider.notifier).refreshTodos();
        },
        child: todoState.isLoading && todoState.todos.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: todoState.todos.length,
                itemBuilder: (context, index) {
                  final todo = todoState.todos[index];
                  return CheckboxListTile(
                    title: Text(todo.title),
                    value: todo.isCompleted,
                    onChanged: (value) {
                      ref.read(todoListProvider.notifier).toggleTodo(todo.id);
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/todos/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Example 3: Combining Multiple Providers

```dart
// Combining user data with settings
final userWithSettingsProvider = Provider<UserWithSettings>((ref) {
  final user = ref.watch(userProvider);
  final settings = ref.watch(settingsProvider);
  
  return UserWithSettings(
    user: user.user,
    isDarkMode: settings.isDarkMode,
    language: settings.language,
  );
});

// Using in widget
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userWithSettings = ref.watch(userWithSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(userWithSettings.user?.name ?? 'Profile'),
      ),
      body: Column(
        children: [
          Text('Dark Mode: ${userWithSettings.isDarkMode}'),
          Text('Language: ${userWithSettings.language}'),
        ],
      ),
    );
  }
}
```

### Example 4: File Upload with Progress

```dart
class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  String? _filePath;
  double _uploadProgress = 0.0;

  Future<void> _pickFile() async {
    // File picker logic
    setState(() {
      _filePath = '/path/to/file.jpg';
    });
  }

  Future<void> _uploadFile() async {
    if (_filePath == null) return;

    try {
      final response = await NetworkCaller().multipartRequest(
        '/api/upload',
        filePath: _filePath!,
        onSendProgress: (sent, total) {
          setState(() {
            _uploadProgress = sent / total;
          });
        },
      );

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload File')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Pick File'),
            ),
            if (_filePath != null) ...[
              const SizedBox(height: 20),
              Text('Selected: $_filePath'),
              const SizedBox(height: 20),
              LinearProgressIndicator(value: _uploadProgress),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadFile,
                child: const Text('Upload'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## ✅ Best Practices

### 1. Provider Organization

```dart
// ✅ DO: Separate providers by concern
final userRepositoryProvider = Provider<UserRepository>(...);
final userProvider = StateNotifierProvider<UserNotifier, UserState>(...);

// ❌ DON'T: Mix repository and state in one provider
```

### 2. State Immutability

```dart
// ✅ DO: Use copyWith for immutable state
state = state.copyWith(user: newUser);

// ❌ DON'T: Mutate state directly
state.user = newUser; // This won't work!
```

### 3. Error Handling

```dart
// ✅ DO: Handle errors in try-catch
try {
  final data = await _repository.getData();
  state = state.copyWith(data: data, isLoading: false);
} catch (e) {
  state = state.copyWith(error: e.toString(), isLoading: false);
}

// ❌ DON'T: Ignore errors
final data = await _repository.getData();
state = state.copyWith(data: data);
```

### 4. Widget Rebuilds

```dart
// ✅ DO: Use ref.watch in build method
@override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(provider);
  return Text(state.value);
}

// ❌ DON'T: Use ref.watch in callbacks
onPressed: () {
  final state = ref.watch(provider); // Wrong!
}

// ✅ DO: Use ref.read in callbacks
onPressed: () {
  ref.read(provider.notifier).doSomething();
}
```

### 5. Side Effects

```dart
// ✅ DO: Use ref.listen for side effects
ref.listen(authProvider, (previous, next) {
  if (next.isAuthenticated) {
    context.go('/home');
  }
});

// ❌ DON'T: Navigate in build method
if (authState.isAuthenticated) {
  context.go('/home'); // Can cause issues!
}
```

### 6. Provider Disposal

```dart
// ✅ DO: Use autoDispose for temporary data
final tempDataProvider = FutureProvider.autoDispose<Data>((ref) async {
  return await fetchData();
});

// For permanent data (user session, settings)
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
```

### 7. Testing

```dart
// ✅ DO: Override providers in tests
final container = ProviderContainer(
  overrides: [
    userRepositoryProvider.overrideWithValue(MockUserRepository()),
  ],
);

final state = container.read(userProvider);
```

---

## ⚠️ Common Mistakes & Solutions

### Mistake 1: Using ref.watch in callbacks

```dart
// ❌ WRONG
onPressed: () {
  final count = ref.watch(counterProvider); // Rebuilds widget unnecessarily
  print(count);
}

// ✅ CORRECT
onPressed: () {
  final count = ref.read(counterProvider);
  print(count);
}
```

### Mistake 2: Not handling loading and error states

```dart
// ❌ WRONG
Widget build(BuildContext context, WidgetRef ref) {
  final data = ref.watch(dataProvider);
  return Text(data.value); // What if loading or error?
}

// ✅ CORRECT
Widget build(BuildContext context, WidgetRef ref) {
  final dataState = ref.watch(dataProvider);
  
  if (dataState.isLoading) {
    return CircularProgressIndicator();
  }
  
  if (dataState.error != null) {
    return Text('Error: ${dataState.error}');
  }
  
  return Text(dataState.value);
}
```

### Mistake 3: Forgetting ProviderScope

```dart
// ❌ WRONG
void main() {
  runApp(MyApp());
}

// ✅ CORRECT
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Mistake 4: Not using ConsumerWidget

```dart
// ❌ WRONG
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // No access to ref!
  }
}

// ✅ CORRECT
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myProvider);
    return Text(state);
  }
}
```

### Mistake 5: Mutating state directly

```dart
// ❌ WRONG
class MyNotifier extends StateNotifier<MyState> {
  void updateName(String name) {
    state.name = name; // Won't trigger rebuild!
  }
}

// ✅ CORRECT
class MyNotifier extends StateNotifier<MyState> {
  void updateName(String name) {
    state = state.copyWith(name: name);
  }
}
```

---

## 📋 Migration Checklist

### Phase 1: Setup ✅
- [x] Install `flutter_riverpod` and `go_router`
- [x] Wrap app with `ProviderScope`
- [x] Setup `GoRouter` configuration
- [x] Update `MaterialApp` to `MaterialApp.router`

### Phase 2: Core Updates ✅
- [x] Update helper functions to use `BuildContext`
- [x] Remove GetX dependencies from utility classes
- [x] Setup NetworkCaller
- [x] Create core providers

### Phase 3: Feature Migration (Per Feature)
- [ ] Create feature folder structure (models, repositories, providers, views)
- [ ] Convert models (usually no changes needed)
- [ ] Create repository for data operations
- [ ] Convert GetX controller to Riverpod StateNotifier
- [ ] Update UI to use ConsumerWidget/ConsumerStatefulWidget
- [ ] Replace `Obx()` with `ref.watch()`
- [ ] Replace `Get.find()` with `ref.watch()` or `ref.read()`
- [ ] Update navigation from `Get.to()` to `context.push()`
- [ ] Test feature thoroughly

### Phase 4: Navigation Updates
- [ ] Replace all `Get.to()` with `context.push()`
- [ ] Replace all `Get.back()` with `context.pop()`
- [ ] Replace all `Get.toNamed()` with `context.pushNamed()`
- [ ] Update route parameters and arguments

### Phase 5: Cleanup
- [ ] Remove GetX from `pubspec.yaml`
- [ ] Remove all GetX imports
- [ ] Remove binding classes
- [ ] Run `flutter pub get`
- [ ] Fix any remaining errors
- [ ] Run tests
- [ ] Update documentation

---

## 🎓 Key Takeaways

1. **MVVM Pattern**: Separates concerns better than MVC for reactive apps
2. **Immutable State**: Safer and more predictable than mutable state
3. **Automatic DI**: No need for manual binding classes
4. **Type Safety**: Compile-time checks prevent runtime errors
5. **Better Testing**: Easy to mock and test individual components
6. **Web Ready**: GoRouter provides excellent web support
7. **Repository Pattern**: Clean separation between data and business logic
8. **Provider Types**: Choose the right provider for your use case

---

## 📚 Additional Resources

### Documentation
- [Riverpod Official Docs](https://riverpod.dev)
- [GoRouter Official Docs](https://pub.dev/packages/go_router)
- [Flutter MVVM Architecture](https://docs.flutter.dev/development/data-and-backend/state-mgmt)

### Video Tutorials
- [Riverpod 2.0 Complete Guide](https://www.youtube.com/results?search_query=riverpod+2.0+tutorial)
- [GoRouter Deep Dive](https://www.youtube.com/results?search_query=gorouter+flutter)

### Community
- [Flutter Dev Discord](https://discord.gg/flutter)
- [r/FlutterDev Subreddit](https://reddit.com/r/FlutterDev)

---

## 🎉 Conclusion

You now have a complete understanding of:
- ✅ MVVM architecture pattern
- ✅ Complete flow from UI to Network layer
- ✅ Differences between GetX and GoRouter + Riverpod
- ✅ How to implement features from scratch
- ✅ Best practices and common pitfalls
- ✅ Real-world examples

**Start building amazing Flutter apps with modern architecture!** 🚀

---

*Last Updated: December 29, 2025*
