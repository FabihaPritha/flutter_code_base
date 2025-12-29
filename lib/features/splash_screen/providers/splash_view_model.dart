import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Splash View State
/// Holds the state for the splash screen
class SplashViewState {
  final bool isNavigating;
  final double progress;

  SplashViewState({this.isNavigating = false, this.progress = 0.0});

  SplashViewState copyWith({bool? isNavigating, double? progress}) {
    return SplashViewState(
      isNavigating: isNavigating ?? this.isNavigating,
      progress: progress ?? this.progress,
    );
  }
}

/// Splash ViewModel
/// Manages splash screen state and navigation logic following MVVM pattern
class SplashViewModel extends StateNotifier<SplashViewState> {
  final Ref ref;
  Timer? _timer;
  Timer? _progressTimer;

  SplashViewModel(this.ref) : super(SplashViewState());

  /// Initialize splash screen with timer
  void initialize() {
    _startProgressTimer();
    _startNavigationTimer();
  }

  /// Start progress animation timer
  void _startProgressTimer() {
    const duration = Duration(milliseconds: 50);
    const totalDuration = 3000; // 3 seconds
    const increment = 50.0 / totalDuration;

    _progressTimer = Timer.periodic(duration, (timer) {
      if (state.progress >= 1.0) {
        timer.cancel();
        return;
      }

      state = state.copyWith(
        progress: (state.progress + increment).clamp(0.0, 1.0),
      );
    });
  }

  /// Start navigation timer
  void _startNavigationTimer() {
    _timer = Timer(const Duration(seconds: 3), () {
      state = state.copyWith(isNavigating: true);
    });
  }

  /// Reset navigation state (useful if navigation is handled)
  void resetNavigationState() {
    state = state.copyWith(isNavigating: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }
}

/// Provider for SplashViewModel
final splashViewModelProvider =
    StateNotifierProvider.autoDispose<SplashViewModel, SplashViewState>(
      (ref) => SplashViewModel(ref),
    );
