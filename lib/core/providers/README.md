# Riverpod Providers

This directory contains all Riverpod providers for state management.

## Structure

- `common/` - Common providers used across features (theme, auth state, etc.)
- `[feature_name]/` - Feature-specific providers

## Provider Types

### 1. **Provider**
For read-only values that never change.
```dart
final apiUrlProvider = Provider<String>((ref) => 'https://api.example.com');
```

### 2. **StateProvider**
For simple state that can be modified.
```dart
final counterProvider = StateProvider<int>((ref) => 0);
```

### 3. **StateNotifierProvider**
For complex state with business logic.
```dart
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
```

### 4. **FutureProvider**
For async operations.
```dart
final userDataProvider = FutureProvider<User>((ref) async {
  final response = await http.get(Uri.parse('...'));
  return User.fromJson(jsonDecode(response.body));
});
```

### 5. **StreamProvider**
For streams of data.
```dart
final messagesProvider = StreamProvider<List<Message>>((ref) {
  return messageService.watchMessages();
});
```

## Usage Examples

### Reading a Provider
```dart
// In a ConsumerWidget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('Count: $count');
  }
}

// In a ConsumerStatefulWidget
class MyStatefulWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends ConsumerState<MyStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    final count = ref.watch(counterProvider);
    return Text('Count: $count');
  }
}
```

### Modifying State
```dart
// For StateProvider
ref.read(counterProvider.notifier).state++;

// For StateNotifierProvider
ref.read(userProvider.notifier).login(username, password);
```

### Reading Without Rebuilding
```dart
// Use ref.read() when you don't need to rebuild on changes
final count = ref.read(counterProvider);
```
