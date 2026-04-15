import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/ui/sams_lottie_assets.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _animateIn = false;

  @override
  void initState() {
    super.initState();

    // Trigger fade/scale animation shortly after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _animateIn = true);
    });

    // Navigate to login after 3 seconds.
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.goNamed(AppRouteNames.login);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.35,
      height: 1.28,
    );

    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.white.withValues(alpha: 0.84),
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              SamsUiTokens.primary,
              Color(0xFF0A4F81),
              Color(0xFFEAF3FB),
            ],
            stops: [0.0, 0.56, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -90,
                right: -70,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -50,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SamsUiTokens.primary.withValues(alpha: 0.22),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: AnimatedOpacity(
                    opacity: _animateIn ? 1 : 0,
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOut,
                    child: AnimatedSlide(
                      offset: _animateIn ? Offset.zero : const Offset(0, 0.06),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 212,
                            height: 212,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.62),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF021623,
                                  ).withValues(alpha: 0.24),
                                  blurRadius: 26,
                                  offset: const Offset(0, 14),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/sams_logo.png',
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.school_rounded,
                                size: 110,
                                color: SamsUiTokens.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SamsLocaleText(
                            'Sadat Academy for\nManagement Sciences',
                            textAlign: TextAlign.center,
                            style: titleStyle,
                          ),
                          const SizedBox(height: 10),
                          SamsLocaleText(
                            'SAMS Student Portal',
                            textAlign: TextAlign.center,
                            style: subtitleStyle,
                          ),
                          const SizedBox(height: 14),
                          Opacity(
                            opacity: 0.9,
                            child: SizedBox(
                              width: 112,
                              height: 112,
                              child: RepaintBoundary(
                                child: Lottie.asset(
                                  SamsLottieAssets.splashAcademicLight,
                                  fit: BoxFit.contain,
                                  repeat: true,
                                  animate: true,
                                  frameRate: FrameRate.composition,
                                  filterQuality: FilterQuality.low,
                                  addRepaintBoundary: true,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 34,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
