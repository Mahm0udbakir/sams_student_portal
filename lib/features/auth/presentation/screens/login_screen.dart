import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_pressable.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showManualForm = false;

  void _toggleManualForm() {
    setState(() => _showManualForm = !_showManualForm);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final h = MediaQuery.sizeOf(context).height;
    final compact = SamsUiTokens.isCompactWidth(context);
    final useDesktopCard = size.width >= SamsUiTokens.desktopBreakpoint;
    final horizontalPadding = compact ? 16.0 : 22.0;
    final topPadding = compact ? 18.0 : 24.0;
    final bottomPadding = compact ? 12.0 : 16.0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_hero.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [SamsUiTokens.primary, Color(0xFF0A4F81)],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    SamsUiTokens.primary.withValues(alpha: 0.72),
                    const Color(0xFF02253D).withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: useDesktopCard
                ? Alignment.center
                : Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  useDesktopCard ? 20 : 0,
                  useDesktopCard ? 20 : 0,
                  useDesktopCard ? 20 : 0,
                  0,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: useDesktopCard ? h * 0.86 : h * 0.62,
                    maxWidth: 540,
                  ),
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    topPadding,
                    horizontalPadding,
                    bottomPadding,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FCFF),
                    borderRadius: useDesktopCard
                        ? BorderRadius.circular(30)
                        : const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(88),
                          ),
                    border: Border.all(
                      color: SamsUiTokens.primary.withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF011B2D).withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SamsLocaleText(
                          'Welcome back',
                          style: TextStyle(
                            color: SamsUiTokens.textPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const SamsLocaleText(
                          'Choose a quick QR sign-in or continue manually.',
                          style: TextStyle(
                            color: SamsUiTokens.textSecondary,
                            fontSize: 12.8,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: SamsTapScale(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  SamsUiTokens.radiusLg,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: SamsUiTokens.primary.withValues(
                                      alpha: 0.22,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    context.goNamed(AppRouteNames.home),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SamsUiTokens.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  minimumSize: const Size.fromHeight(52),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      SamsUiTokens.radiusLg,
                                    ),
                                  ),
                                ),
                                icon: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                label: const SamsLocaleText(
                                  'Sign-in with QR code',
                                  style: TextStyle(
                                    fontSize: 15.8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const SamsLocaleText(
                          'or',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666E7A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SamsTapScale(
                          child: TextButton(
                            onPressed: _toggleManualForm,
                            child: SamsLocaleText(
                              _showManualForm
                                  ? 'Hide manual login'
                                  : 'Login manually',
                              style: const TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                          child: _showManualForm
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    children: [
                                      TextField(
                                        decoration: InputDecoration(
                                          labelText: context.tr('Roll no.'),
                                          filled: true,
                                          fillColor: const Color(0xFFF8FAFC),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              SamsUiTokens.radiusMd,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          labelText: context.tr('Password'),
                                          filled: true,
                                          fillColor: const Color(0xFFF8FAFC),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              SamsUiTokens.radiusMd,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: double.infinity,
                                        child: SamsTapScale(
                                          child: ElevatedButton(
                                            onPressed: () => context.goNamed(
                                              AppRouteNames.home,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              minimumSize:
                                                  const Size.fromHeight(50),
                                            ),
                                            child: const SamsLocaleText(
                                              'Continue',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 8),
                        SamsTapScale(
                          child: TextButton(
                            onPressed: () =>
                                context.goNamed(AppRouteNames.signup),
                            child: const SamsLocaleText(
                              'New here? Create an account',
                              style: TextStyle(
                                color: SamsUiTokens.primary,
                                fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }
}
