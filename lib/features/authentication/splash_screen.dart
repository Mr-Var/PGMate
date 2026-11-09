import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Shown while the app starts. Continues seamlessly from the Android launch
/// screen (same blue, same mark), then animates the mark and the wordmark.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// How long the opening animation runs; startup waits at least this long.
  static const duration = Duration(milliseconds: 1100);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: SplashScreen.duration)..forward();

  late final _markScale = Tween(begin: 0.72, end: 1.0).animate(
    CurvedAnimation(
      parent: _c,
      curve: const Interval(0, 0.55, curve: Curves.easeOutBack),
    ),
  );
  late final _markFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0, 0.35, curve: Curves.easeOut),
  );
  late final _wordFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
  );
  late final _wordSlide = Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(
    CurvedAnimation(
      parent: _c,
      curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic),
    ),
  );
  late final _line = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.55, 1, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) _c.value = 1;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _markFade,
                child: ScaleTransition(
                  scale: _markScale,
                  child: Image.asset('assets/branding/logo_mark.png', width: 104, height: 104),
                ),
              ),
              const SizedBox(height: Gap.lg),
              FadeTransition(
                opacity: _wordFade,
                child: SlideTransition(
                  position: _wordSlide,
                  child: const Column(
                    children: [
                      Text(
                        'PG Manager',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rent, rooms and tenants. Offline.',
                        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13.5, color: Color(0xCCFFFFFF)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Gap.xxl),
              SizedBox(
                width: 56,
                height: 3,
                child: AnimatedBuilder(
                  animation: _line,
                  builder: (_, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _line.value,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
