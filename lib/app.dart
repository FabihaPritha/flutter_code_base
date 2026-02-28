import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_base/core/utils/theme/app_system_theme.dart';
import 'package:flutter_code_base/routes/go_router_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Set your design size (iPhone 11 Pro)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          routerConfig: GoRouterProvider.router,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final overlayStyle = Theme.of(
              context,
            ).extension<AppSystemTheme>()!.systemOverlayStyle;

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlayStyle,
              child: child!,
            );
          },
        );
      },
    );
  }
}
