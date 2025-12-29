import 'package:flutter/material.dart';
import 'package:flutter_code_base/core/common/styles/global_text_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_code_base/features/splash_screen/providers/splash_view_model.dart';
import 'package:flutter_code_base/routes/app_routes.dart';

/// Splash Screen (View)
/// Demonstrates MVVM pattern with Riverpod
/// ConsumerWidget with all logic in SplashViewModel
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the splash screen timer after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashViewModelProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final splashViewState = ref.watch(splashViewModelProvider);

    // Listen to navigation state changes
    ref.listen(splashViewModelProvider, (previous, next) {
      if (next.isNavigating && !(previous?.isNavigating ?? false)) {
        // Navigate to login screen after 3 seconds
        context.go(AppRoutes.loginScreen);
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo or Icon
              Icon(Icons.flash_on, size: 100, color: Colors.white),
              const SizedBox(height: 24),

              // App Name
              Text(
                'Flutter Code Base',
                style: getTextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              Text(
                'MVVM Architecture with Riverpod',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 48),

              // Loading Indicator
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: splashViewState.progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 16),

              // Loading Text
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
