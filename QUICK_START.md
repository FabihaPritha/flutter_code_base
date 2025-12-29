# Quick Start Guide: Riverpod + GoRouter with MVVM

## 📁 Project Structure (MVVM Pattern)

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart        ✅ All API endpoints
│   │   └── app_constants.dart        ✅ App-wide constants
│   ├── models/                        ✅ Shared models
│   ├── providers/                     ✅ Global providers
│   ├── services/
│   │   ├── api_service.dart          ✅ HTTP client with Riverpod
│   │   └── storage_service.dart      ✅ Local storage
│   └── utils/                         ✅ Helper functions
│
├── features/
│   └── authentication/                ✅ Example feature
│       ├── models/                    Model (Data)
│       │   └── user_model.dart
│       ├── repositories/              Repository (Data Source)
│       │   └── auth_repository.dart
│       ├── providers/                 ViewModel (Business Logic)
│       │   └── auth_provider.dart
│       └── views/                     View (UI)
│           ├── login_screen_example.dart
│           └── widgets/
│
├── routes/
│   └── app_routes.dart                ✅ GoRouter configuration
│
└── main.dart                          ✅ With ProviderScope
```

## 🎯 MVVM Pattern Explained

### What is MVVM?

**M**odel - **V**iew - **V**iewModel

1. **Model**: Data classes (User, Product, etc.)
2. **View**: UI (Screens, Widgets)
3. **ViewModel**: Business logic (Providers/Notifiers in Riverpod)
4. **Repository**: Data operations (API calls, database)

### Why MVVM over MVC for Riverpod?

- ✅ **Better separation**: ViewModel is independent of UI
- ✅ **Testable**: Can test business logic without UI
- ✅ **Reactive**: Riverpod's reactive nature fits MVVM perfectly
- ✅ **Reusable**: ViewModels can be reused across different views
- ✅ **Scalable**: Easier to maintain as app grows

## 🚀 How to Create a New Feature

### Step 1: Create Feature Structure

```bash
lib/features/your_feature/
├── models/
├── repositories/
├── providers/
└── views/
```

### Step 2: Define Your Model

```dart
// lib/features/your_feature/models/item_model.dart
class ItemModel {
  final String id;
  final String name;

  ItemModel({required this.id, required this.name});

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
```

### Step 3: Create Repository

```dart
// lib/features/your_feature/repositories/item_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_code_base/core/services/api_service.dart';
import 'package:flutter_code_base/core/constants/api_constants.dart';

class ItemRepository {
  final ApiService _apiService;

  ItemRepository(this._apiService);

  Future<List<ItemModel>> getItems() async {
    final response = await _apiService.get(ApiConstants.yourEndpoint);
    
    if (response.isSuccess) {
      final items = (response.responseData as List)
          .map((json) => ItemModel.fromJson(json))
          .toList();
      return items;
    } else {
      throw Exception(response.errorMessage ?? 'Failed to load items');
    }
  }
}

// Provider
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ItemRepository(apiService);
});
```

### Step 4: Create State and Notifier (ViewModel)

```dart
// lib/features/your_feature/providers/item_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State class
class ItemState {
  final List<ItemModel> items;
  final bool isLoading;
  final String? error;

  ItemState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  ItemState copyWith({
    List<ItemModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return ItemState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier (ViewModel)
class ItemNotifier extends StateNotifier<ItemState> {
  final ItemRepository _repository;

  ItemNotifier(this._repository) : super(ItemState()) {
    loadItems(); // Load on init
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final items = await _repository.getItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshItems() async {
    await loadItems();
  }
}

// Provider
final itemProvider = StateNotifierProvider<ItemNotifier, ItemState>((ref) {
  final repository = ref.watch(itemRepositoryProvider);
  return ItemNotifier(repository);
});
```

### Step 5: Create View (UI)

```dart
// lib/features/your_feature/views/item_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemListScreen extends ConsumerWidget {
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemState = ref.watch(itemProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      body: itemState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : itemState.error != null
              ? Center(child: Text('Error: ${itemState.error}'))
              : ListView.builder(
                  itemCount: itemState.items.length,
                  itemBuilder: (context, index) {
                    final item = itemState.items[index];
                    return ListTile(
                      title: Text(item.name),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(itemProvider.notifier).refreshItems();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

## 📋 Common Patterns

### 1. Simple State (Counter, Boolean)

```dart
final counterProvider = StateProvider<int>((ref) => 0);

// Usage
final count = ref.watch(counterProvider);
ref.read(counterProvider.notifier).state++;
```

### 2. Complex State with Business Logic

```dart
class TodoState {
  final List<Todo> todos;
  final bool isLoading;
  
  TodoState({this.todos = const [], this.isLoading = false});
}

class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier() : super(TodoState());
  
  void addTodo(Todo todo) {
    state = TodoState(
      todos: [...state.todos, todo],
      isLoading: false,
    );
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier();
});
```

### 3. Async Data Loading

```dart
final userDataProvider = FutureProvider<User>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.get(ApiConstants.userProfile);
  return User.fromJson(response.responseData);
});

// Usage in UI
final userData = ref.watch(userDataProvider);

userData.when(
  data: (user) => Text(user.name),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

### 4. Listening to State Changes (Side Effects)

```dart
ref.listen(authProvider, (previous, next) {
  if (next.isAuthenticated) {
    context.go('/home');
  }
  if (next.error != null) {
    showDialog(...);
  }
});
```

## 🔄 Migration Checklist

- ✅ Riverpod installed (`flutter_riverpod: ^2.6.1`)
- ✅ App wrapped with `ProviderScope`
- ✅ API constants defined
- ✅ API service with Riverpod providers
- ✅ Example authentication feature with MVVM
- ⬜ Convert existing GetX controllers to Riverpod providers
- ⬜ Update all screens to use ConsumerWidget/ConsumerStatefulWidget
- ⬜ Replace Get.find() with ref.watch()
- ⬜ Replace Obx() with ref.watch()

## 🎓 Key Concepts

### Watch vs Read vs Listen

```dart
// WATCH - Rebuilds when value changes (use in build method)
final value = ref.watch(provider);

// READ - One-time read, no rebuild (use in callbacks/methods)
onPressed: () {
  ref.read(provider.notifier).someMethod();
}

// LISTEN - Side effects only (navigation, dialogs, snackbars)
ref.listen(provider, (previous, next) {
  if (next.hasError) showDialog(...);
});
```

### Provider Types

1. **Provider**: Read-only, never changes
2. **StateProvider**: Simple mutable state
3. **StateNotifierProvider**: Complex state with logic
4. **FutureProvider**: Async operations
5. **StreamProvider**: Stream of data

## 📚 Resources

- **Full Architecture Guide**: `ARCHITECTURE_GUIDE.md`
- **Migration Guide**: `MIGRATION_GUIDE.md`
- **Provider Examples**: `lib/core/providers/examples/`
- **Auth Example**: `lib/features/authentication/`
- **Riverpod Docs**: https://riverpod.dev
- **GoRouter Docs**: https://pub.dev/packages/go_router

## 🐛 Common Mistakes to Avoid

1. ❌ Using `ref.watch()` in callbacks
   ✅ Use `ref.read()` instead

2. ❌ Not using ConsumerWidget
   ✅ Change StatelessWidget to ConsumerWidget

3. ❌ Forgetting ProviderScope
   ✅ Wrap MyApp with ProviderScope in main.dart

4. ❌ Mixing state management libraries
   ✅ Stick with Riverpod throughout

5. ❌ Not handling loading/error states
   ✅ Always include loading and error states

## 💡 Pro Tips

1. **Use family modifiers** for parameterized providers:
```dart
final itemByIdProvider = Provider.family<Item, String>((ref, id) {
  return ref.watch(allItemsProvider).firstWhere((item) => item.id == id);
});
```

2. **Combine providers**:
```dart
final filteredItemsProvider = Provider<List<Item>>((ref) {
  final items = ref.watch(itemsProvider);
  final filter = ref.watch(filterProvider);
  return items.where((item) => item.matches(filter)).toList();
});
```

3. **Auto-dispose** providers that aren't always needed:
```dart
final dataProvider = FutureProvider.autoDispose<Data>((ref) async {
  // Will be disposed when no longer used
});
```

---

## 🎉 You're Ready!

You now have a complete Riverpod + GoRouter setup with MVVM architecture. 
Start building features following the patterns in the authentication example!
