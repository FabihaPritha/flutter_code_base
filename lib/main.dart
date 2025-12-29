import 'package:flutter/material.dart';
import 'package:flutter_code_base/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
void main() {
  runApp(
    // Wrap the entire app with ProviderScope
    const ProviderScope(child: MyApp()),
  );
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       routerConfig: AppRoutes.router,
//     );
//   }
// }
