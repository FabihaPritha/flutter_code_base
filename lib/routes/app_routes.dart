import 'package:flutter_code_base/features/authentication/views/login_screen.dart';
import 'package:flutter_code_base/features/splash_screen/views/splash_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  // Route path constants
  static String splashScreen = "/splashScreen";
  static String loginScreen = "/loginScreen";

  // Route getter methods
  static String getLoginScreen() => loginScreen;
  static String getSplashScreen() => splashScreen;

  // Route definitions for GetX navigation
  static List<GetPage> routes = [
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: splashScreen, page: () => SplashScreen()),
  ];
}
