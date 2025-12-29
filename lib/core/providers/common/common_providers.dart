import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Example: Simple counter state provider
/// Use StateProvider for simple state that can be modified
final counterProvider = StateProvider<int>((ref) => 0);

/// Example: Theme mode provider
/// Use StateProvider for simple enums or boolean values
final themeModeProvider = StateProvider<bool>(
  (ref) => false,
); // false = light, true = dark

/// Example: Loading state provider
/// Useful for showing global loading indicators
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Example: Config provider
/// Use Provider for read-only values
final apiBaseUrlProvider = Provider<String>((ref) {
  // You can return different URLs based on build mode
  return 'https://api.example.com';
});
