import 'package:flutter/material.dart';
import 'package:flutter_code_base/features/authentication/views/login_screen.dart';
import 'package:flutter_code_base/features/splash_screen/views/splash_screen.dart';
import 'package:flutter_code_base/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

class GoRouterProvider {
  // Prevent instantiation
  GoRouterProvider._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashScreen,
    routes: [
      GoRoute(
        path: AppRoutes.splashScreen,
        name: 'splashScreen',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.loginScreen,
        name: 'loginScreen',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      // Add more routes here
    ],
  );
}
