import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../core/routes/app_router.dart';
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              SamsUiTokens.brandRed,
              SamsUiTokens.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedOpacity(
            opacity: _animateIn ? 1 : 0,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            child: AnimatedScale(
              scale: _animateIn ? 1 : 0.95,
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/sams_logo.png',
                          width: 186,
                          height: 186,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, __, ___) => Container(
                            width: 168,
                            height: 168,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              size: 92,
                              color: Colors.white,
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
        ),
      ),
    );
  }
}
