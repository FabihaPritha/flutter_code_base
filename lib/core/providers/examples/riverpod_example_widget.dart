import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_code_base/core/providers/common/common_providers.dart';
import 'package:flutter_code_base/core/providers/common/user_provider.dart';

/// Example Widget demonstrating Riverpod usage
///
/// IMPORTANT: Change your widgets from StatelessWidget to ConsumerWidget
/// or from StatefulWidget to ConsumerStatefulWidget

class RiverpodExampleWidget extends ConsumerWidget {
  const RiverpodExampleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers to rebuild when they change
    final counter = ref.watch(counterProvider);
    final userState = ref.watch(userProvider);
    final isDarkMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Example'),
        actions: [
          // Toggle theme
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              // Modify state using ref.read()
              ref.read(themeModeProvider.notifier).state = !isDarkMode;
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Counter Example
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Counter Example',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Count: $counter',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Decrement counter
                            ref.read(counterProvider.notifier).state--;
                          },
                          child: const Text('-'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Increment counter
                            ref.read(counterProvider.notifier).state++;
                          },
                          child: const Text('+'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Reset counter
                            ref.read(counterProvider.notifier).state = 0;
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User State Example
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User State Example',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (userState.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (userState.isAuthenticated)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User ID: ${userState.userId}'),
                          Text('Username: ${userState.username}'),
                          Text('Email: ${userState.email}'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(userProvider.notifier).logout();
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          const Text('Not logged in'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Simulate login
                              ref
                                  .read(userProvider.notifier)
                                  .login('john_doe', 'password123');
                            },
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    if (userState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Error: ${userState.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of ConsumerStatefulWidget
/// Use this when you need a StatefulWidget with Riverpod
class RiverpodStatefulExample extends ConsumerStatefulWidget {
  const RiverpodStatefulExample({super.key});

  @override
  ConsumerState<RiverpodStatefulExample> createState() =>
      _RiverpodStatefulExampleState();
}

class _RiverpodStatefulExampleState
    extends ConsumerState<RiverpodStatefulExample> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access ref using widget.ref or just ref
    final counter = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stateful Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Counter: $counter'),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Enter a number'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(_controller.text) ?? 0;
                ref.read(counterProvider.notifier).state = value;
              },
              child: const Text('Set Counter'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of using Consumer widget for partial rebuilds
/// Use Consumer when you only want to rebuild part of your widget tree
class PartialRebuildExample extends StatelessWidget {
  const PartialRebuildExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partial Rebuild Example')),
      body: Column(
        children: [
          const Text('This text won\'t rebuild'),
          // Only this Consumer will rebuild when counter changes
          Consumer(
            builder: (context, ref, child) {
              final counter = ref.watch(counterProvider);
              return Text('Counter: $counter');
            },
          ),
          const Text('This text won\'t rebuild either'),
        ],
      ),
    );
  }
}
