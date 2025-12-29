import 'package:flutter/material.dart';
import 'package:flutter_code_base/features/authentication/views/login_screen.dart';
import 'package:flutter_code_base/features/splash_screen/views/splash_screen.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  // Route path constants
  static const String splashScreen = "/";
  static const String loginScreen = "/login";

  // Route getter methods
  static String getLoginScreen() => loginScreen;
  static String getSplashScreen() => splashScreen;

  // GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: splashScreen,
    routes: [
      GoRoute(
        path: splashScreen,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: loginScreen,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
    ],
  );
}
