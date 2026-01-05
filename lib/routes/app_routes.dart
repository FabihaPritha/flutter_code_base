class AppRoutes {
    AppRoutes._();
    
  // Route path constants
  static const String splashScreen = "/";
  static const String loginScreen = "/login";

  // Route getter methods
  static String getLoginScreen() => loginScreen;
  static String getSplashScreen() => splashScreen;

  // // GoRouter configuration
  // static final GoRouter router = GoRouter(
  //   initialLocation: splashScreen,
  //   routes: [
  //     GoRoute(
  //       path: splashScreen,
  //       name: 'splash',
  //       builder: (BuildContext context, GoRouterState state) {
  //         return const SplashScreen();
  //       },
  //     ),
  //     GoRoute(
  //       path: loginScreen,
  //       name: 'login',
  //       builder: (BuildContext context, GoRouterState state) {
  //         return const LoginScreen();
  //       },
  //     ),
  //   ],
  // );
}
