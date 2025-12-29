# GetX to GoRouter + Riverpod Migration Guide

## ✅ Completed Changes

### Architecture Update: MVC → MVVM
**Why MVVM?** Riverpod works best with the MVVM (Model-View-ViewModel) pattern rather than traditional MVC. MVVM provides better separation of concerns, is more testable, and aligns with Riverpod's reactive architecture.

📖 **See `ARCHITECTURE_GUIDE.md` for complete architecture documentation**
📖 **See `QUICK_START.md` for quick reference and examples**

### 1. **Dependencies Updated** (`pubspec.yaml`)
- ✅ Replaced `get: ^4.7.2` with `go_router: ^14.7.0`
- ✅ Added `flutter_riverpod: ^2.6.1` for state management

### 2. **Routing System** (`lib/routes/app_routes.dart`)
- ✅ Converted from `GetPage` to `GoRoute`
- ✅ Changed route paths to use standard URL patterns
- ✅ Created `AppRoutes.router` with GoRouter configuration

### 3. **Main App** (`lib/main.dart`)
- ✅ Changed from `MaterialApp` to `MaterialApp.router`
- ✅ Set `routerConfig: AppRoutes.router`

### 4. **Helper Functions** (`lib/core/utils/helpers/app_helper.dart`)
- ✅ Removed `Get.context!` dependencies
- ✅ Updated all methods to require `BuildContext` parameter
- ✅ Changed `Get.bottomSheet` to `showModalBottomSheet`
- ✅ Changed `Get.back()` to `Navigator.of(context).pop()`

### 5. **Device Utilities** (`lib/core/utils/device/device_utility.dart`)
- ✅ Removed `Get.context!` dependencies
- ✅ Updated all methods to require `BuildContext` parameter where needed

### 6. **Controller Bindings** (`lib/core/bindings/controller_binder.dart`)
- ✅ Marked as deprecated (not needed with GoRouter)

### 7. **State Management** (`Riverpod Setup`)
- ✅ Added `flutter_riverpod: ^2.6.1` to dependencies
- ✅ Wrapped app with `ProviderScope` in `main.dart`
- ✅ Created provider structure in `lib/core/providers/`
- ✅ Added example providers and usage examples

## 🔄 Next Steps

### 1. **Install Dependencies**
Run this command in your terminal:
```bash
flutter pub get
```

### 2. **Update Navigation Calls**
Search your codebase for any remaining GetX navigation calls and replace them:

| GetX Method | GoRouter Equivalent |
|-------------|-------------------|
| `Get.to(Screen())` | `context.push('/screen')` |
| `Get.toNamed('/route')` | `context.push('/route')` or `context.go('/route')` |
| `Get.off(Screen())` | `context.go('/screen')` |
| `Get.offNamed('/route')` | `context.go('/route')` |
| `Get.offAll(Screen())` | `context.go('/screen')` |
| `Get.back()` | `context.pop()` |
| `Get.back(result: data)` | `context.pop(data)` |

### 3. **Update Function Calls**
Methods that now require `BuildContext`:

**AppHelperFunctions:**
- `showSnackBar(context, message)` - now needs context
- `showImageSourceDialog(context)` - now needs context
- `showAlert(context, title, message)` - now needs context
- `screenSize(context)` - now needs context
- `screenHeight(context)` - now needs context
- `screenWidth(context)` - now needs context

**AppDeviceUtility:**
- `getScreenHeight(context)` - now needs context
- `getPixelRatio(context)` - now needs context
- `getStatusBarHeight(context)` - now needs context
- `getKeyboardHeight(context)` - now needs context
- `isKeyboardVisible(context)` - now needs context

### 4. **State Management** (If using GetX Controllers)
If you were using GetX for state management, you have several options:
- **✅ Riverpod** - Modern, type-safe, and recommended (CURRENTLY SETUP)
- **Provider** - Simple and recommended by Flutter team
- **Bloc** - For complex state management
- **flutter_hooks** + **hooks_riverpod** - For functional approach

## 📦 Riverpod Setup (Completed)

Riverpod has been successfully added to your project! Here's what was done:

### Installation
- ✅ Added `flutter_riverpod: ^2.6.1` to `pubspec.yaml`
- ✅ Wrapped app with `ProviderScope` in `main.dart`

### Provider Structure Created
```
lib/core/providers/
├── README.md                              # Complete Riverpod documentation
├── common/
│   ├── common_providers.dart              # Simple state providers
│   └── user_provider.dart                 # Complex state example
└── examples/
    └── riverpod_example_widget.dart       # Usage examples
```

### How to Use Riverpod

**1. Change Widget Types:**
```dart
// OLD: StatelessWidget
class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) { }
}

// NEW: ConsumerWidget
class MyWidget extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) { }
}

// OLD: StatefulWidget
class MyWidget extends StatefulWidget { }
class _MyWidgetState extends State<MyWidget> { }

// NEW: ConsumerStatefulWidget
class MyWidget extends ConsumerStatefulWidget { }
class _MyWidgetState extends ConsumerState<MyWidget> { }
```

**2. Create a Provider:**
```dart
// Simple state
final counterProvider = StateProvider<int>((ref) => 0);

// Complex state with business logic
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState());
  
  void login(String username, String password) async {
    state = state.copyWith(isLoading: true);
    // Your login logic
    state = state.copyWith(user: user, isLoading: false);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
```

**3. Read/Watch Providers:**
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Watch - rebuilds when value changes
  final counter = ref.watch(counterProvider);
  
  // Read - doesn't rebuild, use in callbacks
  onPressed: () {
    ref.read(counterProvider.notifier).state++;
  }
}
```

**4. Provider Types:**
- **Provider** - For read-only values (configs, constants)
- **StateProvider** - For simple mutable state (counter, boolean)
- **StateNotifierProvider** - For complex state with logic (user auth, forms)
- **FutureProvider** - For async operations (API calls)
- **StreamProvider** - For streams (real-time data)

### Migration from GetX Controllers

**GetX Controller:**
```dart
class UserController extends GetxController {
  final user = Rx<User?>(null);
  
  void login(String username, String password) {
    // login logic
    user.value = newUser;
  }
}

// Usage
final controller = Get.find<UserController>();
Obx(() => Text(controller.user.value?.name ?? ''));
```

**Riverpod Equivalent:**
```dart
class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);
  
  void login(String username, String password) {
    // login logic
    state = newUser;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

// Usage - No need to find/inject
final user = ref.watch(userProvider);
Text(user?.name ?? '');
```

### Example Files Created
- See `lib/core/providers/examples/riverpod_example_widget.dart` for complete examples
- See `lib/core/providers/README.md` for detailed documentation
- See `lib/core/providers/common/user_provider.dart` for StateNotifier example

### Next Steps for Riverpod
1. Convert your existing GetX controllers to Riverpod providers
2. Replace `Obx()` and `GetBuilder()` with `ConsumerWidget`
3. Replace `Get.find<Controller>()` with `ref.watch(provider)`
4. Test your state management flows

### 5. **Navigation Examples**

**Simple Navigation:**
```dart
// Navigate to login screen
context.push(AppRoutes.loginScreen);

// Or using go (replaces current route)
context.go(AppRoutes.loginScreen);

// Go back
context.pop();
```

**Navigation with Parameters:**
First, update your route definition in `app_routes.dart`:
```dart
GoRoute(
  path: '/profile/:userId',
  name: 'profile',
  builder: (context, state) {
    final userId = state.pathParameters['userId'];
    return ProfileScreen(userId: userId);
  },
),
```

Then navigate:
```dart
context.push('/profile/123');
```

**Navigation with Complex Objects:**
```dart
// In route definition:
GoRoute(
  path: '/details',
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>;
    return DetailsScreen(data: data);
  },
),

// Navigate:
context.push('/details', extra: {'id': '123', 'name': 'John'});
```

### 6. **Testing**
After migration:
- Test all navigation flows
- Verify all dialogs and bottom sheets work
- Check that all screen transitions are smooth
- Ensure back button behavior is correct

## 📝 Notes

- GoRouter provides better deep linking support
- GoRouter has built-in support for nested navigation
- GoRouter integrates well with web applications
- You can add guards/redirects easily with GoRouter's `redirect` parameter

## 🐛 Common Issues

### Issue: "context.push is not defined"
**Solution:** Make sure to import go_router:
```dart
import 'package:go_router/go_router.dart';
```

### Issue: "BuildContext not available"
**Solution:** Ensure you're calling navigation methods inside a Widget's build method or pass context as a parameter.

### Issue: Routes not working
**Solution:** Check that your route paths start with `/` and match the paths you're navigating to.

## 📚 Resources

- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter Navigation Guide](https://docs.flutter.dev/development/ui/navigation)
- [GoRouter Examples](https://github.com/flutter/packages/tree/main/packages/go_router/example)
